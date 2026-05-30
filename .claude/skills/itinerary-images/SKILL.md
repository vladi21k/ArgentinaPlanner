---
name: itinerary-images
description: 'Add, replace, download, and validate images in the Argentina trip itinerary. Use when adding a photo gallery to a destination section, replacing external image URLs with locally-stored files, downloading Wikimedia Commons or other images to the repo, or ensuring generated HTML shows the images from itinerary.md. Always download images to the appropriate destination folder under assets/images and run the itinerary-render workflow after changing itinerary.md. Triggers: add images, add photos, download images, replace image URLs, photo gallery, add photos to itinerary, image section, photo tiles, update images.'
---

# Itinerary Images

## When to Use
- Adding a new photo gallery section to a destination that does not yet have one
- Replacing external image URLs (Wikimedia Commons, OpenStreetMap) with locally downloaded files
- Downloading all external images in a section or across the whole itinerary
- Validating that existing image references in both files resolve correctly
- Ensuring generated HTML pages show the image references from `itinerary.md`

## Critical Sync Rule
**`itinerary.md` is the source of truth.** Never hand-edit generated HTML to
change an image reference. Make the image change in `itinerary.md`, then use
`../itinerary-render/SKILL.md` to regenerate `itinerary-gmap.html` and
`itinerary-leaflet.html` in the same commit.

Static map images referenced in `itinerary.md` are also included in the
generated HTML pages.

## Image Storage Convention
Consult [image-conventions.md](./references/image-conventions.md) for:
- Folder structure (`assets/images/<destination-slug>/`)
- Destination slug mapping table
- Exact MD and HTML format templates
- File naming rules

## Procedure

### Step 1: Identify Scope
Determine from context:
- **Destination**: Which section of the itinerary (Buenos Aires, Iguazú, etc.)
- **Action type**:
  - *Add new*: Destination has no `<div class="photo-tiles">` block yet → create one from scratch
  - *Replace existing*: Destination already has images with external URLs → download and swap paths
  - *Download all*: Process every external image URL across the whole itinerary

### Step 2: Discover Image URLs
For **replacing existing** or **download all**:
- Scan `itinerary.md` for `![...](http...)` or embedded `<img src="http...">`
  references in the target destination section
- Build a list of `{ alt, url, filename }` objects

For **adding new**:
- Identify 4–6 representative Wikimedia Commons images for the destination
- Use `https://commons.wikimedia.org/wiki/Special:FilePath/<filename>` URL pattern
- Suggest URLs to the user and confirm before downloading

### Step 3: Validate URLs Before Downloading
For **every** image URL:
1. Run an HTTP HEAD request:
   ```powershell
   Invoke-WebRequest -Method Head -Uri "<url>" -UseBasicParsing
   ```
2. Require HTTP 200 (or 301/302 redirect that resolves to 200) — reject anything else
3. Confirm `Content-Type` starts with `image/`
4. Log each result: ✓ valid / ✗ broken

**Do not download any image that fails validation.** Report broken URLs to the user and skip them.

### Step 4: Download to Repo
For each validated image URL:
1. Determine destination slug from [image-conventions.md](./references/image-conventions.md)
2. Create folder if needed: `assets/images/<destination-slug>/`
3. Derive filename: use the last path segment of the URL, lowercased (e.g. `Skyline_Puerto_Madero.jpg` → `skyline_puerto_madero.jpg`)
4. Download:
   ```powershell
   Invoke-WebRequest -Uri "<url>" -OutFile "assets/images/<slug>/<filename>"
   ```
5. **Post-download validation**:
   - File size > 0 bytes
   - Extension matches a known image type: `.jpg`, `.jpeg`, `.png`, `.webp`, `.gif`
   - If file size < 5 KB, flag as suspicious (may be an error page, not an image)

Report any download failures before proceeding to Step 5.

### Step 5: Update Markdown And Render HTML
Update `itinerary.md`, then regenerate both HTML outputs. Include all three
documents in the same commit.

**In `itinerary.md`**:
- Replace each external URL with the local path: `./assets/images/<slug>/<filename>`
- For a new section, insert the photo block immediately after the destination tagline and before the map line:
  ```markdown
  ![Alt text 1](./assets/images/<slug>/image1.jpg)
  ![Alt text 2](./assets/images/<slug>/image2.jpg)
  ![Alt text 3](./assets/images/<slug>/image3.jpg)
  ![Alt text 4](./assets/images/<slug>/image4.jpg)
  ![Alt text 5](./assets/images/<slug>/image5.jpg)
  ```

**Generate HTML outputs**:
```powershell
python .\render_itinerary_html.py
```

### Step 6: Final Verification
After rendering:
1. Confirm the affected image paths appear in both generated HTML files.
2. Confirm every local path `./assets/images/<slug>/<filename>` exists on disk
3. Load `itinerary-leaflet.html` locally and check that the images render.
4. Report a summary: N images downloaded, N files updated, any skipped items.
