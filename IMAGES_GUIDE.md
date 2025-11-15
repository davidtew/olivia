# Image Upload & Management Guide

## Current Image System

### How It Works

Images are uploaded **individually per artwork or series** through the admin interface. There is currently **no central gallery view** - each image is attached directly to its artwork/series.

### Upload Locations

1. **Artworks**: `/admin/artworks/new` or `/admin/artworks/:id/edit`
   - Each artwork can have one image
   - Upload via the "Artwork Image" section in the form

2. **Series**: `/admin/series/new` or `/admin/series/:id/edit`
   - Each series can have one cover image
   - Upload via the "Cover Image" section in the form

### Viewing Uploaded Images

- **Admin List Views**: `/admin/artworks` and `/admin/series` show thumbnails
- **Admin Show Pages**: `/admin/artworks/:id` and `/admin/series/:id` show full images
- **Public Pages**: Artwork detail pages, series pages, and homepage feature images

## Storage Options

### Option 1: Local File Storage (Development - Recommended for Now!)

Perfect for tweaking and experimenting without needing S3/Tigris.

**Setup:**

1. Set environment variable:
   ```bash
   export UPLOADS_STORAGE=local
   ```

2. Restart your Phoenix server:
   ```bash
   # Stop current server (Ctrl+C)
   mix phx.server
   ```

3. Upload images through the admin interface as normal

**Where files are stored:**
- Location: `priv/static/uploads/`
- Structure: `artworks/{series-slug}/{filename}.jpg` or `series/{series-slug}/{filename}.jpg`
- Served at: `http://localhost:4000/uploads/...`

**Advantages:**
- ✅ No S3/Tigris credentials needed
- ✅ Instant uploads
- ✅ Easy to experiment and delete
- ✅ Can see files directly in your file system
- ✅ Free!

### Option 2: S3/Tigris Storage (Production)

For production deployment with cloud storage.

**Setup:**

1. Leave `UPLOADS_STORAGE` unset (or set to "s3")

2. Set S3/Tigris credentials:
   ```bash
   export AWS_ACCESS_KEY_ID=your_key
   export AWS_SECRET_ACCESS_KEY=your_secret
   export UPLOADS_BUCKET=olivia-gallery
   export UPLOADS_PUBLIC_URL=https://fly.storage.tigris.dev/olivia-gallery
   ```

**Advantages:**
- ✅ Scalable cloud storage
- ✅ CDN-backed delivery
- ✅ Works across multiple servers
- ✅ Automatic backups (with Tigris/S3)

## Image Upload Workflow

### Creating a New Artwork with Image

1. Go to `/admin/artworks/new`
2. Fill in artwork details:
   - Title (e.g., "Evening Light")
   - Select series (optional)
   - Year, medium, dimensions
   - Price (optional)
   - Description in Markdown
3. Scroll to **"Artwork Image"** section
4. Click "Choose File" and select your image
5. Wait for upload progress bar
6. Click **"Save Artwork"**
7. Image is uploaded and associated with the artwork

### Editing an Artwork's Image

1. Go to `/admin/artworks`
2. Click **"Edit"** on the artwork
3. Current image is displayed (if exists)
4. To replace: Click "Choose File" and upload new image
5. To remove: Click **"Remove current image"** button
6. Click **"Save Artwork"**

### Supported Image Formats

- JPG/JPEG
- PNG
- WEBP

**Max file size**: 10MB
**Recommended dimensions**: 1200×1600px (or similar 3:4 ratio for artworks)

## Image Organization

### File Naming

Images are automatically renamed to prevent conflicts:
- Format: `{timestamp}_{random_hash}.{extension}`
- Example: `1731665432_a3f2e1b4c5d6e7f8.jpg`

### Folder Structure

**Artworks**:
```
priv/static/uploads/
  └── artworks/
      ├── quiet-rituals/
      │   ├── 1731665432_a3f2e1b4c5d6e7f8.jpg
      │   └── 1731665789_b4c5d6e7f8a3f2e1.jpg
      └── urban-landscapes/
          └── 1731666123_c5d6e7f8a3f2e1b4.jpg
```

**Series**:
```
priv/static/uploads/
  └── series/
      ├── quiet-rituals/
      │   └── 1731665000_d6e7f8a3f2e1b4c5.jpg
      └── urban-landscapes/
          └── 1731666000_e7f8a3f2e1b4c5d6.jpg
```

## Future Enhancements (Not Yet Implemented)

### Potential Future Features:

1. **Media Library / Gallery View**
   - Central admin page showing all uploaded images
   - Grid view of all images
   - Ability to select and assign images to artworks
   - Bulk upload functionality

2. **Multiple Images per Artwork**
   - Support for artwork detail shots
   - Image gallery on artwork pages
   - Reordering images

3. **Automatic Image Optimization**
   - Server-side resize on upload
   - Generate multiple sizes (thumbnail, medium, large)
   - Convert to WebP automatically

4. **Image Metadata**
   - Tags for organizing images
   - Search functionality
   - Alt text management

## Tips & Best Practices

### Before Uploading

1. **Optimize images first** (see IMAGE_OPTIMIZATION.md)
   - Resize to appropriate dimensions
   - Compress to reduce file size
   - Keep originals in a separate folder

2. **Naming convention** (optional but helpful)
   - Use descriptive original filenames
   - Example: `evening-light-2024.jpg`

### During Development

1. **Use local storage** while experimenting
2. **Create test artworks** to verify image display
3. **Check different screen sizes** in the browser
4. **Review image quality** on public pages

### Before Production

1. **Switch to S3/Tigris** storage
2. **Re-upload optimized images** if needed
3. **Test upload/delete functionality**
4. **Verify images load on public pages**

## Troubleshooting

### Images Not Uploading

1. Check file size (must be < 10MB)
2. Verify file format (JPG, PNG, or WEBP only)
3. Check server logs for errors
4. Ensure uploads directory exists and is writable

### Images Not Displaying

1. **Local storage**: Check `priv/static/uploads/` folder exists
2. **S3 storage**: Verify AWS credentials are set
3. Check browser console for 404 errors
4. Verify image URL in database is correct

### Images Uploading to Wrong Location

1. Check `UPLOADS_STORAGE` environment variable
2. Restart Phoenix server after changing storage settings
3. Verify series is selected when uploading artwork images

## Quick Reference

### Environment Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `UPLOADS_STORAGE` | `local` or `s3` | Choose storage backend |
| `AWS_ACCESS_KEY_ID` | Your key | S3/Tigris authentication |
| `AWS_SECRET_ACCESS_KEY` | Your secret | S3/Tigris authentication |
| `UPLOADS_BUCKET` | Bucket name | S3/Tigris bucket |
| `UPLOADS_PUBLIC_URL` | Public URL | S3/Tigris CDN URL |

### Admin URLs

- Artwork list: http://localhost:4000/admin/artworks
- New artwork: http://localhost:4000/admin/artworks/new
- Series list: http://localhost:4000/admin/series
- New series: http://localhost:4000/admin/series/new

---

**Current Status**: Local file storage is ready to use! Set `UPLOADS_STORAGE=local` and start uploading.
