---
name: itinerary-render
description: 'Regenerate served itinerary HTML pages from itinerary.md. MUST use after any modification to itinerary.md, including route, schedule, pricing, factual, text, link, map, or image-reference edits, and whenever itinerary-gmap.html or itinerary-leaflet.html is reported as stale.'
---

# Itinerary HTML Renderer

## Source Of Truth

`itinerary.md` is the canonical itinerary. The browser pages are generated
artifacts and must not be maintained as separate copies of the plan.

## Mandatory Trigger

Treat any staged or unstaged change to `itinerary.md` as incomplete until this
workflow has run. Do not commit or push an `itinerary.md` change without also
regenerating and checking in both generated HTML outputs.

## Procedure

1. Make requested itinerary content changes in `itinerary.md`.
2. Regenerate both served HTML pages before reviewing, committing, or pushing:

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
5. Include `itinerary-gmap.html` and `itinerary-leaflet.html` in the same
   commit as the triggering `itinerary.md` change.

## Notes

- The renderer intentionally uses the generated map images referenced by the
  Markdown source, keeping page content in one place.
- `itinerary-images` remains applicable for sourcing and validating image
  assets before regenerating HTML.
- Do not hand-edit generated HTML content to implement itinerary changes; edit
  `itinerary.md` and rerun the renderer.
