---
name: itinerary-images
description: 'Add, replace, download, and validate images in the Argentina trip itinerary. Use when adding a photo gallery to a destination section, replacing external image URLs with locally-stored files, downloading Wikimedia Commons or other images to the repo, or ensuring both itinerary.md and itinerary.html show the same images. Always downloads images to assets/images/<destination>/ rather than using remote URLs. Always updates both files together. Triggers: add images, add photos, download images, replace image URLs, photo gallery, add photos to itinerary, image section, photo tiles, update images.'
argument-hint: 'Destination name (e.g. Mendoza, Bariloche) and action (add new / replace existing / download all)'
---

# Itinerary Images

## When to Use
- Adding a new photo gallery section to a destination that does not yet have one
- Replacing external image URLs (Wikimedia Commons, OpenStreetMap) with locally downloaded files
- Downloading all external images in a section or across the whole itinerary
- Validating that existing image references in both files resolve correctly
- Ensuring `itinerary.md` and `itinerary.html` are in sync after any image change

## Critical Sync Rule
**`itinerary.md` and `itinerary.html` must always be updated together.** Never change an image reference in one file without making the equivalent change in the other. The MD uses markdown `![alt](path)` syntax; the HTML uses `<div class="photo-tiles">` with `<img src="path" alt="..." />` entries. Both render the same images for each destination.

> **Exception**: Static map images appear only in `itinerary.md` (as `![alt](staticmap-url)`). The HTML uses interactive Leaflet map containers (`<div class="map-wrap map-dest">`) — those are not `<img>` tags and are not affected by this skill.

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
- Scan `itinerary.md` for `![...](http...)` references in the target destination section
- Confirm the matching `<img src="http...">` entries in `itinerary.html` for the same section
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

### Step 5: Update Both Files Atomically
Update `itinerary.md` first, then `itinerary.html`. Both updates must happen in the same response.

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

**In `itinerary.html`**:
- Replace each `<img src="http...">` with `<img src="./assets/images/<slug>/<filename>" />`
- For a new section, insert the `<div class="photo-tiles">` block immediately after the `<p class="dest-tagline">` element:
  ```html
  <div class="photo-tiles">
    <div><img src="./assets/images/<slug>/image1.jpg" alt="Alt text 1" /></div>
    <div><img src="./assets/images/<slug>/image2.jpg" alt="Alt text 2" /></div>
    <div><img src="./assets/images/<slug>/image3.jpg" alt="Alt text 3" /></div>
    <div><img src="./assets/images/<slug>/image4.jpg" alt="Alt text 4" /></div>
    <div><img src="./assets/images/<slug>/image5.jpg" alt="Alt text 5" /></div>
  </div>
  ```

### Step 6: Final Verification
After both files are updated:
1. Count image references in the destination's MD photo block vs. HTML photo-tiles block — numbers must match
2. Confirm every local path `./assets/images/<slug>/<filename>` exists on disk
3. Report a summary: N images downloaded, N files updated, any skipped items
