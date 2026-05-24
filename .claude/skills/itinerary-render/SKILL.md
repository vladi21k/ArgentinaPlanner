---
name: itinerary-render
description: 'Regenerate served itinerary HTML pages from itinerary.md after route, schedule, pricing, facts, or content changes. Use whenever itinerary.md has changed or when itinerary-gmap.html or itinerary-leaflet.html is reported as stale.'
argument-hint: 'Optional: verify a specific updated section after rendering'
---

# Itinerary HTML Renderer

## Source Of Truth

`itinerary.md` is the canonical itinerary. The browser pages are generated
artifacts and must not be maintained as separate copies of the plan.

## Procedure

1. Make requested itinerary content changes in `itinerary.md`.
2. Regenerate both served HTML pages:

   ```powershell
   python .\render_itinerary_html.py
   ```

3. Verify that:
   - `itinerary-gmap.html` and `itinerary-leaflet.html` contain the current
     route dates and day headings from `itinerary.md`.
   - stale removed destinations or dates no longer appear.
   - local asset references resolve in the rendered browser page.
4. When a local server is running, reload
   `http://127.0.0.1:8000/itinerary-leaflet.html` and inspect the changed
   section visually.

## Notes

- The renderer intentionally uses the generated map images referenced by the
  Markdown source, keeping page content in one place.
- `itinerary-images` remains applicable for sourcing and validating image
  assets before regenerating HTML.
