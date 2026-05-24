"""Render the canonical Markdown itinerary into the two served HTML pages."""

from __future__ import annotations

from pathlib import Path

try:
    import markdown
except ImportError as exc:
    raise SystemExit(
        "Python-Markdown is required. Install it with: python -m pip install markdown"
    ) from exc


ROOT = Path(__file__).resolve().parent
SOURCE = ROOT / "itinerary.md"
OUTPUTS = (ROOT / "itinerary-gmap.html", ROOT / "itinerary-leaflet.html")


TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Argentina Adventure - December 2026 / January 2027</title>
  <style>
    *, *::before, *::after {{ box-sizing: border-box; }}
    html {{ scroll-behavior: smooth; }}
    body {{
      margin: 0;
      font-family: "Segoe UI", system-ui, -apple-system, sans-serif;
      background: #f7f4ef;
      color: #1a1a1a;
      line-height: 1.65;
    }}
    a {{ color: #1a5fa8; }}
    a:hover {{ text-decoration: underline; }}
    .hero {{
      background: linear-gradient(135deg, #00205b 0%, #0055a4 60%, #74aadd 100%);
      color: #fff;
      padding: 3rem 1.5rem 2.25rem;
      text-align: center;
    }}
    .hero h1 {{
      font-size: clamp(2rem, 5vw, 2.6rem);
      margin: 0 0 0.45rem;
      letter-spacing: -0.04em;
    }}
    .hero p {{ margin: 0; font-size: 1.08rem; opacity: 0.9; }}
    .source-note {{
      max-width: 980px;
      margin: 0 auto;
      padding: 0.7rem 1.5rem;
      font-size: 0.86rem;
      color: #5d554d;
      background: #efe8dd;
    }}
    .layout {{
      max-width: 1120px;
      margin: 0 auto;
      padding: 1.5rem;
      display: grid;
      grid-template-columns: minmax(190px, 245px) minmax(0, 1fr);
      gap: 2rem;
      align-items: start;
    }}
    aside {{
      position: sticky;
      top: 1.25rem;
      background: #fff;
      border: 1px solid #e4ddd4;
      border-radius: 8px;
      padding: 0.9rem 1rem;
      max-height: calc(100vh - 2.5rem);
      overflow-y: auto;
    }}
    aside .label {{
      color: #00205b;
      font-weight: 700;
      margin-bottom: 0.45rem;
    }}
    aside ul {{ margin: 0.2rem 0 0 1rem; padding: 0; }}
    aside li {{ margin: 0.3rem 0; font-size: 0.87rem; }}
    aside a {{ text-decoration: none; color: #4b4743; }}
    main {{
      min-width: 0;
      background: #fff;
      border-radius: 10px;
      padding: clamp(1.1rem, 3vw, 2.4rem);
      box-shadow: 0 2px 10px rgba(0, 0, 0, 0.04);
    }}
    main > h1:first-child {{ display: none; }}
    h2 {{
      color: #00205b;
      font-size: 1.75rem;
      margin: 2.4rem 0 1rem;
      padding-top: 0.4rem;
      border-bottom: 2px solid #e4ddd4;
      padding-bottom: 0.35rem;
    }}
    h3 {{
      color: #14253c;
      font-size: 1.42rem;
      margin: 2.2rem 0 0.65rem;
    }}
    h4 {{
      font-size: 1.12rem;
      margin: 1.65rem 0 0.55rem;
      color: #27231f;
    }}
    p {{ margin: 0.7rem 0; }}
    hr {{ border: 0; border-top: 1px solid #e4ddd4; margin: 1.7rem 0; }}
    blockquote {{
      margin: 1rem 0;
      padding: 0.65rem 0.95rem;
      background: #fffbeb;
      border-left: 4px solid #f59e0b;
      border-radius: 0 6px 6px 0;
      color: #413a33;
    }}
    blockquote p {{ margin: 0.35rem 0; }}
    ul, ol {{ padding-left: 1.5rem; }}
    li {{ margin: 0.3rem 0; }}
    table {{
      width: 100%;
      border-collapse: collapse;
      margin: 1rem 0 1.45rem;
      font-size: 0.92rem;
    }}
    th {{
      color: #fff;
      background: #00205b;
      text-align: left;
      font-weight: 600;
      padding: 0.55rem 0.7rem;
    }}
    td {{
      border-bottom: 1px solid #e4ddd4;
      padding: 0.48rem 0.7rem;
      vertical-align: top;
    }}
    tr:nth-child(even) td {{ background: #faf7f3; }}
    img {{
      display: block;
      max-width: 100%;
      height: auto;
      border-radius: 7px;
      margin: 0.75rem 0;
    }}
    table img {{
      width: 100%;
      margin: 0;
      border-radius: 4px;
      max-height: 270px;
      object-fit: cover;
    }}
    table:has(img) td {{
      padding: 3px;
      border: 0;
      background: transparent !important;
    }}
    main > p > img {{
      width: 100%;
      max-height: 510px;
      object-fit: contain;
      background: #f2eee7;
      border: 1px solid #e4ddd4;
    }}
    .footer {{
      text-align: center;
      color: #746c63;
      padding: 0 1rem 2rem;
      font-size: 0.87rem;
    }}
    @media (max-width: 820px) {{
      .layout {{ display: block; padding: 0.8rem; }}
      aside {{ position: static; margin-bottom: 0.8rem; max-height: none; }}
      main {{ padding: 1.1rem; }}
      table {{ display: block; overflow-x: auto; }}
    }}
    @media print {{
      .hero {{ -webkit-print-color-adjust: exact; print-color-adjust: exact; }}
      .source-note, aside {{ display: none; }}
      .layout {{ display: block; padding: 0; }}
      main {{ box-shadow: none; }}
    }}
  </style>
</head>
<body>
  <header class="hero">
    <h1>Argentina Adventure</h1>
    <p>4 friends &middot; 26 nights &middot; Dec 9, 2026 to Jan 4, 2027</p>
  </header>
  <div class="source-note">Generated from <strong>itinerary.md</strong>. Edit the Markdown source and rerun <code>python render_itinerary_html.py</code>.</div>
  <div class="layout">
    <aside aria-label="Itinerary contents">
      <div class="label">Contents</div>
      {toc}
    </aside>
    <main>
      {content}
    </main>
  </div>
  <footer class="footer">Argentina Adventure itinerary - generated from the canonical Markdown plan</footer>
</body>
</html>
"""


def render() -> None:
    source = SOURCE.read_text(encoding="utf-8-sig")
    renderer = markdown.Markdown(
        extensions=["extra", "toc", "sane_lists"],
        extension_configs={"toc": {"permalink": False, "toc_depth": "2-4"}},
        output_format="html5",
    )
    content = renderer.convert(source)
    page = TEMPLATE.format(toc=renderer.toc, content=content)
    for output in OUTPUTS:
        output.write_text(page, encoding="utf-8", newline="\n")
        print(f"Rendered {output.name} from {SOURCE.name}")


if __name__ == "__main__":
    render()
