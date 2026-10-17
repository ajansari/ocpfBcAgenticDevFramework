# The icon standard, the SVG skeleton, the preview page, the checks

## The standard

| Rule | Value | Why |
|---|---|---|
| Canvas | 300 × 300, `viewBox="0 0 300 300"` | Microsoft accepts 216–350 px for the listing; 300 is Ops § Intake's size |
| Shape | square with rounded corners, radius 54 (18 %) | the shape every BC extension icon shares in Extension Management |
| Background | transparent outside the rounded square | BC draws the icon on white and on colored Role Center tiles |
| Safe area | nothing within 20 px of the edge | the corner radius and BC's own 32 px rendering clip it |
| Legibility | the motif reads at 32 px; a word mark is 44 px tall or more, two to four characters, bold | BC shows the icon at 32 px in lists |
| Palette | one color, two colors, or one linear gradient between two colors; strong contrast between motif and background | flat colors survive scaling; gradients only as background |
| Fonts | `Arial, Helvetica, sans-serif`, `font-weight="700"` | the renderers (Quick Look, a headless browser) have them; nothing else is guaranteed |
| Forbidden | raster images, filters, blur, drop shadows, photorealism, more than three colors, text under 44 px, anything outside the clip path | lost or ugly at 32 px; opaque corners |
| Output | `images/AppIcon.png` (300 × 300, RGBA — PNG color type 6) with `images/AppIcon.svg` beside it | PNG is what `app.json`'s `logo` needs; the SVG is the source |

## The SVG skeleton

Replace the colors, the motif, and the optional word mark; keep the clip path and the sizes.

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="300" height="300" viewBox="0 0 300 300">
  <defs>
    <clipPath id="tile"><rect width="300" height="300" rx="54" ry="54"/></clipPath>
    <!-- two-color gradient background; for one color use a plain fill, for two colors two shapes -->
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#0F6CBD"/>
      <stop offset="1" stop-color="#0A7C85"/>
    </linearGradient>
  </defs>
  <g clip-path="url(#tile)">
    <rect width="300" height="300" fill="url(#bg)"/>
    <!-- motif: a few bold shapes, high contrast, inside x,y 20..280 — e.g. a document with a check -->
    <rect x="86" y="62" width="128" height="176" rx="14" fill="#FFFFFF"/>
    <rect x="110" y="98" width="80" height="14" rx="7" fill="#0F6CBD"/>
    <rect x="110" y="128" width="80" height="14" rx="7" fill="#0F6CBD"/>
    <path d="M118 190 l22 22 l44 -52" fill="none" stroke="#0A7C85" stroke-width="18" stroke-linecap="round" stroke-linejoin="round"/>
    <!-- optional word mark, 2–4 characters, ≥ 44 px, bold -->
    <!-- <text x="150" y="262" text-anchor="middle" font-family="Arial, Helvetica, sans-serif" font-weight="700" font-size="46" fill="#FFFFFF">KSD</text> -->
  </g>
</svg>
```

**Isometric 3D variant:** draw the motif as a top face (a parallelogram or rotated square), a left
face, and a right face of one shape — the top in the lighter color, the left in the base color, the
right in a darker shade (mix the base with 20–30 % black) — with no gradients on the faces; the
three flat tones give the depth. Keep the whole shape inside the safe area.

**One color:** a plain background `fill="#<color>"` and a white (or near-black, on a light color)
motif. **Two colors:** background in one, motif in the other, or the background split diagonally
into two shapes with a white motif.

## The preview page — `images/icon-preview.html`

Written only when no renderer on the machine can produce the PNG, or when the human wants to see
the icon at BC's sizes. It embeds the SVG inline (paste the file's contents where marked), shows
it at 300, 64, and 32 px on a white and a dark tile, and its button draws the SVG on a canvas and
downloads `AppIcon.png` with transparency. The human saves the download into `images/`.

```html
<!doctype html>
<html lang="en"><head><meta charset="utf-8"><title>App icon preview</title>
<style>
  body{font-family:Arial,Helvetica,sans-serif;margin:32px;background:#f4f4f4;color:#222}
  .row{display:flex;gap:32px;align-items:flex-end;flex-wrap:wrap;margin:24px 0}
  .tile{padding:16px;border-radius:12px;display:flex;gap:16px;align-items:flex-end}
  .light{background:#fff;border:1px solid #ddd}.dark{background:#1f1f1f}
  img{display:block} button{font:inherit;padding:10px 18px;border-radius:8px;border:1px solid #0F6CBD;background:#0F6CBD;color:#fff;cursor:pointer}
  small{color:#666}
</style></head><body>
<h1>App icon preview</h1>
<p>300 px, 64 px, and 32 px — the sizes Business Central uses. Corners must stay transparent on both tiles.</p>
<div class="row">
  <div class="tile light"><img id="a" width="300" height="300"><img id="b" width="64" height="64"><img id="c" width="32" height="32"></div>
  <div class="tile dark"><img id="d" width="300" height="300"><img id="e" width="64" height="64"><img id="f" width="32" height="32"></div>
</div>
<p><button id="save">Save as PNG (300 × 300, transparent)</button> <small>downloads <code>AppIcon.png</code> — save it into <code>images/</code></small></p>
<script type="text/plain" id="svg"><!-- PASTE THE SVG FILE'S CONTENTS HERE --></script>
<script>
  const svg=document.getElementById('svg').textContent.trim();
  const url=URL.createObjectURL(new Blob([svg],{type:'image/svg+xml'}));
  for(const id of ['a','b','c','d','e','f']) document.getElementById(id).src=url;
  document.getElementById('save').onclick=()=>{const img=new Image();img.onload=()=>{const c=document.createElement('canvas');c.width=300;c.height=300;c.getContext('2d').drawImage(img,0,0,300,300);const a=document.createElement('a');a.download='AppIcon.png';a.href=c.toDataURL('image/png');a.click();};img.src=url;};
</script>
</body></html>
```

## The checks, before showing the icon

- **Size and alpha, from the PNG header** (no library): `python3 -c "import struct;b=open('images/AppIcon.png','rb').read();print(struct.unpack('>II',b[16:24]),b[25])"` must print `(300, 300) 6` — width, height, and color type 6 (RGBA). PowerShell: `$b=[IO.File]::ReadAllBytes('images/AppIcon.png'); [BitConverter]::ToUInt32($b[19..16],0); [BitConverter]::ToUInt32($b[23..20],0); $b[25]`. A color type of 2 (RGB) means the background is opaque: redo the render with the next rung of the ladder.
- **Corners transparent:** the renderers above honor the clip path; if a corner pixel is painted, the SVG has a shape outside `<g clip-path="url(#tile)">` — move it inside.
- **Reads at 32 px:** open the preview page, or scale the PNG down mentally — if the motif needs more than one glance, simplify it: fewer shapes, thicker strokes, higher contrast.
- **No text under 44 px, two to four characters** when a word mark was asked for.
- **The file paths:** `images/AppIcon.svg`, `images/AppIcon.png`; after acceptance also `src/logo/AppLogo.png` and `"logo": "src/logo/AppLogo.png"` in `app.json`.
