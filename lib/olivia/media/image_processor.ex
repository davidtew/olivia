defmodule Olivia.Media.ImageProcessor do
  @moduledoc """
  Handles image processing tasks for the media quarantine workflow:
  - Thumbnail generation
  - Metadata extraction (EXIF, dimensions, colors)
  - Perceptual hashing for duplicate detection
  """

  require Logger

  @thumbnail_size 400
  @medium_size 1200

  @doc """
  Processes an uploaded image file and returns extracted data.

  Returns a map with:
  - :width, :height - Image dimensions
  - :metadata - EXIF and other metadata
  - :phash - Perceptual hash for duplicate detection
  - :thumbnails - Map of {:thumb_path, :medium_path} temporary files

  The caller is responsible for uploading the thumbnail files and cleaning up temp files.
  """
  def process_image(file_path) do
    with {:ok, image} <- Image.open(file_path),
         {:ok, dimensions} <- get_dimensions(image),
         {:ok, metadata} <- extract_metadata(image, file_path),
         {:ok, phash} <- calculate_phash(image),
         {:ok, thumbnails} <- generate_thumbnails(image, file_path) do
      {:ok,
       %{
         width: dimensions.width,
         height: dimensions.height,
         metadata: metadata,
         phash: phash,
         thumbnails: thumbnails
       }}
    else
      {:error, reason} ->
        Logger.error("ImageProcessor: Failed to process image: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Extracts just dimensions from an image file.
  Useful for quick dimension checks without full processing.
  """
  def get_image_dimensions(file_path) do
    with {:ok, image} <- Image.open(file_path),
         {:ok, dimensions} <- get_dimensions(image) do
      {:ok, dimensions}
    end
  end

  @doc """
  Calculates similarity between two perceptual hashes.
  Returns a float between 0 (different) and 1 (identical).
  """
  def hash_similarity(hash1, hash2) when is_binary(hash1) and is_binary(hash2) do
    # Convert hex strings to binary for comparison
    bin1 = Base.decode16!(hash1, case: :lower)
    bin2 = Base.decode16!(hash2, case: :lower)

    # Calculate Hamming distance
    distance = hamming_distance(bin1, bin2)
    max_distance = byte_size(bin1) * 8

    # Convert to similarity score (1 = identical, 0 = completely different)
    1.0 - distance / max_distance
  end

  def hash_similarity(_, _), do: 0.0

  # Private functions

  defp get_dimensions(image) do
    case Image.shape(image) do
      {:ok, {height, width, _bands}} ->
        {:ok, %{width: width, height: height}}

      {:ok, {height, width}} ->
        {:ok, %{width: width, height: height}}

      error ->
        Logger.warning("ImageProcessor: Could not get dimensions: #{inspect(error)}")
        {:ok, %{width: nil, height: nil}}
    end
  end

  defp extract_metadata(image, file_path) do
    metadata = %{}

    # Extract EXIF data if available
    metadata =
      case Image.exif(image) do
        {:ok, exif} when is_map(exif) and map_size(exif) > 0 ->
          # Extract commonly useful EXIF fields
          Map.merge(metadata, %{
            "exif" => %{
              "camera_make" => get_in(exif, [:make]),
              "camera_model" => get_in(exif, [:model]),
              "date_taken" => get_in(exif, [:datetime_original]) || get_in(exif, [:datetime]),
              "exposure_time" => get_in(exif, [:exposure_time]),
              "f_number" => get_in(exif, [:f_number]),
              "iso" => get_in(exif, [:iso_speed_ratings]),
              "focal_length" => get_in(exif, [:focal_length]),
              "gps_latitude" => get_in(exif, [:gps_latitude]),
              "gps_longitude" => get_in(exif, [:gps_longitude])
            }
          })

        _ ->
          metadata
      end

    # Get file stats
    metadata =
      case File.stat(file_path) do
        {:ok, stat} ->
          Map.put(metadata, "file_modified", stat.mtime)

        _ ->
          metadata
      end

    # Extract dominant colors (sample from center of image)
    metadata =
      case extract_dominant_colors(image) do
        {:ok, colors} ->
          Map.put(metadata, "dominant_colors", colors)

        _ ->
          metadata
      end

    {:ok, metadata}
  end

  defp extract_dominant_colors(image) do
    # Resize to small size for color analysis
    with {:ok, small} <- Image.thumbnail(image, 50),
         {:ok, {height, width, _}} <- Image.shape(small) do
      # Get average color (simple approach)
      case Image.average(small) do
        {:ok, avg_colors} when is_list(avg_colors) ->
          # Format as hex color
          hex =
            avg_colors
            |> Enum.take(3)
            |> Enum.map(&round/1)
            |> Enum.map(&min(255, max(0, &1)))
            |> Enum.map(&Integer.to_string(&1, 16))
            |> Enum.map(&String.pad_leading(&1, 2, "0"))
            |> Enum.join("")

          {:ok, ["#" <> hex]}

        _ ->
          {:ok, []}
      end
    else
      _ -> {:ok, []}
    end
  end

  defp calculate_phash(image) do
    # Generate perceptual hash using average hash algorithm
    # 1. Resize to 8x8
    # 2. Convert to grayscale
    # 3. Calculate average
    # 4. Generate hash based on above/below average

    with {:ok, small} <- Image.thumbnail(image, 8, height: 8),
         {:ok, gray} <- Image.to_colorspace(small, :bw),
         {:ok, avg} <- Image.average(gray) do
      # Get pixel values
      case Image.to_list(gray) do
        {:ok, pixels} ->
          avg_val = if is_list(avg), do: hd(avg), else: avg

          # Flatten and create hash
          hash =
            pixels
            |> List.flatten()
            |> Enum.map(fn
              val when is_list(val) -> hd(val)
              val -> val
            end)
            |> Enum.map(fn val -> if val >= avg_val, do: 1, else: 0 end)
            |> bits_to_hex()

          {:ok, hash}

        error ->
          Logger.warning("ImageProcessor: Could not calculate phash: #{inspect(error)}")
          {:ok, nil}
      end
    else
      error ->
        Logger.warning("ImageProcessor: Phash calculation failed: #{inspect(error)}")
        {:ok, nil}
    end
  end

  defp bits_to_hex(bits) do
    bits
    |> Enum.chunk_every(8)
    |> Enum.map(fn chunk ->
      chunk
      |> Enum.with_index()
      |> Enum.reduce(0, fn {bit, idx}, acc -> acc + bit * :math.pow(2, 7 - idx) end)
      |> round()
      |> Integer.to_string(16)
      |> String.pad_leading(2, "0")
    end)
    |> Enum.join("")
    |> String.downcase()
  end

  defp generate_thumbnails(image, original_path) do
    # Generate unique temp filenames
    base = Path.basename(original_path, Path.extname(original_path))
    ext = Path.extname(original_path)
    temp_dir = System.tmp_dir!()

    thumb_path = Path.join(temp_dir, "#{base}_thumb_#{:rand.uniform(100_000)}#{ext}")
    medium_path = Path.join(temp_dir, "#{base}_medium_#{:rand.uniform(100_000)}#{ext}")

    with {:ok, thumb} <- Image.thumbnail(image, @thumbnail_size),
         {:ok, _} <- Image.write(thumb, thumb_path),
         {:ok, medium} <- Image.thumbnail(image, @medium_size),
         {:ok, _} <- Image.write(medium, medium_path) do
      {:ok, %{thumb_path: thumb_path, medium_path: medium_path}}
    else
      error ->
        # Clean up any created files
        File.rm(thumb_path)
        File.rm(medium_path)
        Logger.error("ImageProcessor: Failed to generate thumbnails: #{inspect(error)}")
        {:error, :thumbnail_generation_failed}
    end
  end

  defp hamming_distance(bin1, bin2) do
    bin1
    |> :binary.bin_to_list()
    |> Enum.zip(:binary.bin_to_list(bin2))
    |> Enum.reduce(0, fn {b1, b2}, acc ->
      xor = Bitwise.bxor(b1, b2)
      acc + count_bits(xor)
    end)
  end

  defp count_bits(0), do: 0

  defp count_bits(n) do
    count_bits(Bitwise.band(n, n - 1)) + 1
  end
end
