# Image Conventions

Reference for the `itinerary-images` skill. Contains all format templates, naming rules, and destination mappings.

---

## Folder Structure

```
assets/
└── images/
    ├── buenos-aires/
    ├── iguazu/
    ├── peninsula-valdes/
    ├── ushuaia/
    ├── el-calafate/
    ├── el-chalten/
    ├── bariloche/
    ├── mendoza/
    └── maps/            ← static map images (MD only)
```

---

## Destination Slug Mapping

| Destination name (itinerary)  | Folder slug          | HTML section id      |
|-------------------------------|----------------------|----------------------|
| Buenos Aires                  | `buenos-aires`       | `buenos-aires`       |
| Puerto Iguazú / Iguazú Falls  | `iguazu`             | `iguazu`             |
| Buenos Aires (transit day)    | `buenos-aires`       | `ba-transit`         |
| Puerto Madryn / Península Valdés | `peninsula-valdes` | `madryn`           |
| Ushuaia                       | `ushuaia`            | `ushuaia`            |
| El Calafate                   | `el-calafate`        | `calafate`           |
| El Chaltén                    | `el-chalten`         | `chalten`            |
| Bariloche                     | `bariloche`          | `bariloche`          |
| Mendoza                       | `mendoza`            | `mendoza`            |
| Overview / trip-wide map      | `maps`               | n/a                  |

---

## File Naming Rules

1. Use the **last path segment** of the source URL as the filename
2. Lowercase the entire filename: `Skyline_Puerto_Madero.jpg` → `skyline_puerto_madero.jpg`
3. Replace spaces with underscores if any remain
4. Preserve the original extension (`.jpg`, `.jpeg`, `.png`, `.webp`, `.gif`)
5. If two images from different sources would produce the same filename, prefix with a short descriptor: `ba_skyline_puerto_madero.jpg`

### Examples

| Source URL | Downloaded path |
|---------------------------------------------------------------------------|--------------------------------------|
| `https://commons.wikimedia.org/wiki/Special:FilePath/Skyline_Puerto_Madero.jpg` | `assets/images/buenos-aires/skyline_puerto_madero.jpg` |
| `https://commons.wikimedia.org/wiki/Special:FilePath/Casa_rosada_2.jpg` | `assets/images/buenos-aires/casa_rosada_2.jpg` |
| `https://staticmap.openstreetmap.de/staticmap.php?center=-34.6...` | `assets/images/maps/map_buenos_aires.png` ← use a descriptive name for query-string URLs |

> **Note**: OpenStreetMap static map URLs use query strings with no filename in the path. Generate a descriptive filename: `map_<destination-slug>.png`

---

## MD Format Templates

### Photo block (after destination tagline, before map line)
```markdown
![Alt text 1](./assets/images/<slug>/image1.jpg)
![Alt text 2](./assets/images/<slug>/image2.jpg)
![Alt text 3](./assets/images/<slug>/image3.jpg)
![Alt text 4](./assets/images/<slug>/image4.jpg)
![Alt text 5](./assets/images/<slug>/image5.jpg)
```

### Static map image (MD only — HTML uses Leaflet, not an img tag)
```markdown
![Destination city map](./assets/images/maps/map_<slug>.png)
```

---

## HTML Format Templates

### photo-tiles block (after `<p class="dest-tagline">`, before `<div class="map-wrap">`)
```html
<div class="photo-tiles">
  <div><img src="./assets/images/<slug>/image1.jpg" alt="Alt text 1" /></div>
  <div><img src="./assets/images/<slug>/image2.jpg" alt="Alt text 2" /></div>
  <div><img src="./assets/images/<slug>/image3.jpg" alt="Alt text 3" /></div>
  <div><img src="./assets/images/<slug>/image4.jpg" alt="Alt text 4" /></div>
  <div><img src="./assets/images/<slug>/image5.jpg" alt="Alt text 5" /></div>
</div>
```

> The first `<div>` inside `.photo-tiles` is always the hero/feature image (CSS gives it `grid-row: 1 / 3`). Put the most visually striking image first.

### Map: HTML uses Leaflet, NOT a static image
The HTML file renders destination maps via an interactive Leaflet map:
```html
<div class="map-wrap map-dest" id="map-<section-id>"></div>
```
**Do not add or replace this with an `<img>` tag.** Only the MD file uses static map images.

---

## Sync Checklist

After every image update, verify:

- [ ] Number of `![...]` lines in MD photo block == number of `<div><img>` lines in HTML photo-tiles block
- [ ] Every `./assets/images/<slug>/<filename>` path exists on disk
- [ ] MD alt text matches HTML `alt=""` attribute for each corresponding image
- [ ] No external `http://` or `https://` URLs remain in photo block or static map line (MD)
- [ ] No external `http://` or `https://` URLs remain in photo-tiles `<img src>` (HTML)
