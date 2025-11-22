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
  @max_dimension 2400
  @max_height 3000
  @jpeg_quality 85

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
  Optimizes an image file for web display.

  Performs:
  - Resizing to max 2400×3000px (maintains aspect ratio)
  - EXIF stripping (removes camera data, keeps orientation)
  - JPEG compression at 85% quality
  - Color space conversion to sRGB

  Returns {:ok, optimized_path, stats} where stats contains:
  - :original_size - Original file size in bytes
  - :optimized_size - New file size in bytes
  - :savings_percent - Percentage reduction
  - :original_dimensions - Original width×height
  - :new_dimensions - New width×height
  - :was_resized - Boolean indicating if resize occurred

  The optimized file is written to a temporary location.
  Caller is responsible for moving/uploading and cleaning up.
  """
  def optimize_for_web(file_path) do
    original_size = File.stat!(file_path).size

    with {:ok, image} <- Image.open(file_path),
         {:ok, original_dims} <- get_dimensions(image),
         {:ok, processed_image, was_resized} <- resize_if_needed(image, original_dims),
         {:ok, optimized_image} <- prepare_for_web(processed_image),
         {:ok, output_path} <- write_optimized(optimized_image, file_path) do

      optimized_size = File.stat!(output_path).size
      savings_percent = Float.round((1 - optimized_size / original_size) * 100, 1)

      {:ok, new_dims} = get_dimensions(optimized_image)

      stats = %{
        original_size: original_size,
        optimized_size: optimized_size,
        savings_percent: savings_percent,
        original_dimensions: "#{original_dims.width}×#{original_dims.height}",
        new_dimensions: "#{new_dims.width}×#{new_dims.height}",
        was_resized: was_resized
      }

      Logger.info("ImageProcessor: Optimized image - #{stats.original_dimensions} → #{stats.new_dimensions}, " <>
                  "#{format_bytes(original_size)} → #{format_bytes(optimized_size)} (#{stats.savings_percent}% smaller)")

      {:ok, output_path, stats}
    else
      {:error, reason} ->
        Logger.error("ImageProcessor: Failed to optimize image: #{inspect(reason)}")
        {:error, reason}
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
      {height, width, _bands} ->
        {:ok, %{width: width, height: height}}

      {height, width} ->
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

  # Optimization helper functions

  defp resize_if_needed(image, %{width: width, height: height}) do
    # Ensure dimensions are integers
    width = if is_float(width), do: round(width), else: width
    height = if is_float(height), do: round(height), else: height

    cond do
      width > @max_dimension or height > @max_height ->
        # Calculate new dimensions maintaining aspect ratio
        {new_width, new_height} =
          if width > height do
            # Landscape or square - limit by width
            new_w = min(width, @max_dimension)
            new_h = round(height * new_w / width)
            # Check if height still exceeds limit
            if new_h > @max_height do
              {round(width * @max_height / height), @max_height}
            else
              {new_w, new_h}
            end
          else
            # Portrait - limit by height
            new_h = min(height, @max_height)
            new_w = round(width * new_h / height)
            # Check if width still exceeds limit
            if new_w > @max_dimension do
              {@max_dimension, round(height * @max_dimension / width)}
            else
              {new_w, new_h}
            end
          end

        case Image.thumbnail(image, new_width, height: new_height) do
          {:ok, resized} -> {:ok, resized, true}
          error -> error
        end

      true ->
        {:ok, image, false}
    end
  end

  defp prepare_for_web(image) do
    with {:ok, srgb_image} <- ensure_srgb(image),
         {:ok, stripped_image} <- strip_exif(srgb_image) do
      {:ok, stripped_image}
    end
  end

  defp ensure_srgb(image) do
    # Convert to sRGB color space if needed
    case Image.to_colorspace(image, :srgb) do
      {:ok, converted} -> {:ok, converted}
      # If already in sRGB or conversion not possible, return original
      _ -> {:ok, image}
    end
  end

  defp strip_exif(image) do
    # Remove EXIF data to reduce file size
    # Note: Image library automatically handles orientation before stripping
    case Image.remove_metadata(image) do
      {:ok, stripped} -> {:ok, stripped}
      # If metadata removal fails, continue with original
      _ -> {:ok, image}
    end
  end

  defp write_optimized(image, original_path) do
    # Generate temp output path
    ext = Path.extname(original_path)
    # Default to .jpg if no extension
    ext = if ext == "", do: ".jpg", else: ext

    base = Path.basename(original_path, ext)
    temp_dir = System.tmp_dir!()
    output_path = Path.join(temp_dir, "#{base}_optimized_#{:rand.uniform(100_000)}#{ext}")

    # Write with JPEG optimization if JPEG or no extension, otherwise use defaults
    write_options =
      if ext in [".jpg", ".jpeg", ".JPG", ".JPEG"] do
        [quality: @jpeg_quality, strip_metadata: true]
      else
        [strip_metadata: true]
      end

    case Image.write(image, output_path, write_options) do
      {:ok, _} -> {:ok, output_path}
      error -> error
    end
  end

  defp format_bytes(bytes) when bytes < 1024, do: "#{bytes}B"
  defp format_bytes(bytes) when bytes < 1024 * 1024 do
    "#{Float.round(bytes / 1024, 1)}KB"
  end
  defp format_bytes(bytes) do
    "#{Float.round(bytes / (1024 * 1024), 1)}MB"
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
