# Image Optimization Guide

This guide explains how to optimize images for the Olivia Gallery application.

## Current Implementation

The application currently includes:

- **Lazy Loading**: Images use `loading="lazy"` attribute for automatic browser-level lazy loading
- **Responsive Sizing**: Images adapt to different screen sizes using CSS
- **Optimized Component**: `.artwork_image` component in `core_components.ex` provides consistent image rendering

## Recommended Image Specifications

### Artwork Images

For best quality and performance:

- **Format**: JPEG for photographs, PNG for images with transparency
- **Dimensions**:
  - Full size: 2000px on longest side (for detail viewing)
  - Display size: 1200px on longest side (for gallery views)
  - Thumbnails: 600px on longest side (for list views)
- **Quality**: 85-90% JPEG quality
- **Color Space**: sRGB
- **File Size**: Aim for < 500KB for display images, < 150KB for thumbnails

### Series Cover Images

- **Aspect Ratio**: 16:9 (horizontal orientation works best)
- **Dimensions**: 1600x900px recommended
- **Format**: JPEG
- **Quality**: 85% JPEG quality
- **File Size**: < 400KB

## Manual Image Optimization

Before uploading images through the admin interface, optimize them using these tools:

### macOS / Linux

#### Using ImageMagick

```bash
# Install ImageMagick
# macOS: brew install imagemagick
# Ubuntu: sudo apt-get install imagemagick

# Resize and optimize an artwork image
magick input.jpg -resize 2000x2000\> -quality 85 -strip output.jpg

# Create a thumbnail
magick input.jpg -resize 600x600\> -quality 80 -strip thumbnail.jpg

# Batch process all images in a folder
for img in *.jpg; do
  magick "$img" -resize 1200x1200\> -quality 85 -strip "optimized_$img"
done
```

#### Using Sharp (Node.js)

```bash
# Install sharp
npm install -g sharp-cli

# Resize and optimize
sharp -i input.jpg -o output.jpg --resize 1200 --quality 85
```

### Windows

#### Using XnConvert (Free GUI Tool)

1. Download from https://www.xnview.com/en/xnconvert/
2. Add your images
3. Set Actions:
   - Resize: Longest side = 1200px, Keep aspect ratio
   - Quality: 85
4. Convert

### Online Tools

- **TinyPNG** (https://tinypng.com/) - Great for PNG and JPEG compression
- **Squoosh** (https://squoosh.app/) - Google's image compression tool with visual comparison
- **ImageOptim** (https://imageoptim.com/) - Mac-only but excellent

## Automated Optimization Pipeline

### Option 1: Pre-Upload Optimization (Recommended for Now)

Since the application doesn't have built-in image processing, optimize images before upload:

1. Use one of the tools above to resize/optimize
2. Upload the optimized image through the admin interface
3. The image component will handle lazy loading and responsive display

### Option 2: Add Server-Side Processing (Future Enhancement)

To add automatic image optimization, you would need to:

#### 1. Add Image Processing Library

Add to `mix.exs`:

```elixir
defp deps do
  [
    # ... existing deps
    {:mogrify, "~> 0.9.3"}  # ImageMagick wrapper
  ]
end
```

#### 2. Create Image Processor Module

Create `lib/olivia/image_processor.ex`:

```elixir
defmodule Olivia.ImageProcessor do
  @moduledoc """
  Handles image processing and optimization.
  Requires ImageMagick to be installed on the system.
  """

  def optimize(input_path, output_path, opts \\ []) do
    max_width = Keyword.get(opts, :max_width, 2000)
    quality = Keyword.get(opts, :quality, 85)

    Mogrify.open(input_path)
    |> Mogrify.resize_to_limit("#{max_width}x#{max_width}")
    |> Mogrify.quality(to_string(quality))
    |> Mogrify.strip()
    |> Mogrify.save(path: output_path)

    :ok
  end

  def create_thumbnail(input_path, output_path, size \\ 600) do
    Mogrify.open(input_path)
    |> Mogrify.resize_to_limit("#{size}x#{size}")
    |> Mogrify.quality("80")
    |> Mogrify.strip()
    |> Mogrify.save(path: output_path)

    :ok
  end

  def create_variants(input_path, base_name) do
    variants = [
      {base_name <> "_full.jpg", max_width: 2000, quality: 90},
      {base_name <> "_display.jpg", max_width: 1200, quality: 85},
      {base_name <> "_thumb.jpg", max_width: 600, quality: 80}
    ]

    Enum.map(variants, fn {output, opts} ->
      optimize(input_path, output, opts)
      output
    end)
  end
end
```

#### 3. Update Uploads Module

Modify `lib/olivia/uploads.ex` to process images before upload:

```elixir
def upload_artwork_image(file_path, series_slug, filename) do
  # Create temporary directory for variants
  temp_dir = System.tmp_dir!()
  base_name = Path.join(temp_dir, Path.rootname(filename))

  # Create optimized variants
  [full, display, thumb] = ImageProcessor.create_variants(file_path, base_name)

  # Upload each variant
  full_key = artwork_key(series_slug, "full_" <> filename)
  display_key = artwork_key(series_slug, "display_" <> filename)
  thumb_key = artwork_key(series_slug, "thumb_" <> filename)

  with {:ok, full_url} <- upload_file(full, full_key, "image/jpeg"),
       {:ok, display_url} <- upload_file(display, display_key, "image/jpeg"),
       {:ok, thumb_url} <- upload_file(thumb, thumb_key, "image/jpeg") do

    # Clean up temp files
    File.rm(full)
    File.rm(display)
    File.rm(thumb)

    {:ok, %{full: full_url, display: display_url, thumb: thumb_url}}
  end
end
```

### Option 3: Use External Service (imgproxy or similar)

#### Setup imgproxy (Docker)

```bash
# Start imgproxy container
docker run -d \\
  -p 8080:8080 \\
  -e IMGPROXY_KEY=$(echo -n "secret" | xxd -p -c 256) \\
  -e IMGPROXY_SALT=$(echo -n "salt" | xxd -p -c 256) \\
  -e IMGPROXY_USE_S3=true \\
  -e IMGPROXY_S3_ENDPOINT=https://fly.storage.tigris.dev \\
  -e AWS_ACCESS_KEY_ID=your_key \\
  -e AWS_SECRET_ACCESS_KEY=your_secret \\
  darthsim/imgproxy
```

#### Create imgproxy Helper

Create `lib/olivia_web/helpers/image_helper.ex`:

```elixir
defmodule OliviaWeb.ImageHelper do
  @imgproxy_url "https://imgproxy.yourdomain.com"
  @imgproxy_key Application.compile_env(:olivia, :imgproxy_key)
  @imgproxy_salt Application.compile_env(:olivia, :imgproxy_salt)

  def resize_url(source_url, width, height, opts \\ []) do
    quality = Keyword.get(opts, :quality, 85)
    format = Keyword.get(opts, :format, "jpg")

    path = "/rs:fill:#{width}:#{height}/q:#{quality}/plain/#{source_url}@#{format}"
    signature = sign_path(path)

    "#{@imgproxy_url}/#{signature}#{path}"
  end

  def artwork_url(image_url, size \\ :display) do
    dimensions = case size do
      :full -> {2000, 2000}
      :display -> {1200, 1200}
      :thumb -> {600, 600}
    end

    {width, height} = dimensions
    resize_url(image_url, width, height)
  end

  defp sign_path(path) do
    # imgproxy signature implementation
    # See: https://docs.imgproxy.net/signing_the_url
  end
end
```

## WebP Format Support

Modern browsers support WebP, which offers better compression. To use:

### 1. Create WebP Versions

```bash
# Using cwebp (install: brew install webp)
cwebp -q 80 input.jpg -o output.webp
```

### 2. Update Image Component

Modify `.artwork_image` component to use `<picture>` element:

```heex
<picture>
  <source srcset={webp_src(@src)} type="image/webp">
  <img src={@src} alt={@alt} loading={@loading} class={@class}>
</picture>
```

## Performance Monitoring

### Metrics to Track

- Page load time
- Time to First Contentful Paint (FCP)
- Largest Contentful Paint (LCP)
- Total image payload size

### Tools

- **Lighthouse** (Chrome DevTools) - Overall performance audit
- **WebPageTest** - Detailed loading analysis
- **GTmetrix** - Performance monitoring and recommendations

### Target Metrics

- **LCP**: < 2.5 seconds
- **Total page weight**: < 1MB for gallery pages
- **Individual images**: < 500KB for display, < 150KB for thumbnails

## Best Practices

1. **Always optimize before upload** - Use the manual tools above
2. **Maintain original files** - Keep high-res originals separate from web versions
3. **Use appropriate formats**: JPEG for photos, PNG for graphics/logos, WebP when possible
4. **Test on slow connections** - Use Chrome DevTools network throttling
5. **Monitor file sizes** - Regularly audit uploaded images
6. **Consider lazy loading** - Already implemented in the application!
7. **Use CDN** - Consider Cloudflare or similar for faster delivery

## Storage Costs

### Tigris Pricing (as of 2024)

- Storage: $0.02/GB/month
- Bandwidth: $0.05/GB (first 10TB/month free on Fly.io)

### Estimation

- 100 artworks @ 500KB each = 50MB = $0.001/month
- 100 artworks @ 2MB each (unoptimized) = 200MB = $0.004/month

**Optimization saves both costs and loading time!**

## Conclusion

Until server-side processing is implemented:

1. **Manually optimize all images before upload**
2. **Use the provided tools and specifications**
3. **Monitor performance with Lighthouse**
4. **Consider implementing automated processing in the future**

The current `.artwork_image` component handles responsive display and lazy loading, so focus optimization efforts on file size and dimensions.

---

Last updated: November 2025
