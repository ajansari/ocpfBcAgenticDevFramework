---
name: app-icon
description: Create the app icon of a Business Central extension when the human has none - on every OCPF BC Agentic Development Framework journey (Full PRE-01, Lite Step 1, Build-a-Feature's identity box) and on request. Asks the style (isometric 3D or flat 2D), the colors (one color, two colors, or a two-color gradient, and which), the content (image only, or a word mark with an image), and any special description, then has the Main model draw the icon as an SVG to the framework's standard - square, rounded corners, transparent background, 300 x 300 - renders it to PNG with nothing to install, shows it, and offers to accept it or make another. An accepted icon is stored in images/ and becomes app.json's logo. Use when the identity question's answer is "Create one for me", when the user says "make me an app icon", "design an icon for this app", "I don't have a logo", or runs /ocpf-bc:app-icon.
---

# App icon — create one when the human has none

**Follow `Ops § Intake → *The app icon*`** for where the file goes and how it is resized; this skill
adds the one thing that section assumed the human would bring: the image itself. Every journey
asks the icon question in its identity box (Box 0) and offers **Create one for me** beside *Use
`images/<file>`*, *Yes — I'll provide an image*, and *No icon*; this skill is that option. It also
runs on its own (`/ocpf-bc:app-icon`) on any project with an `app.json`.

**The standard, non-negotiable** (`references/icon-standard.md` has the SVG skeleton and the checks):
a **square** icon, **rounded corners** (an 18 % radius: 54 px on 300), a **transparent
background** outside the rounded square, drawn to a **300 × 300** canvas, legible at 32 px (Business
Central shows it at 32 px in Extension Management and the Role Center, 48–64 px in the app list, up
to 300 px on AppSource), no text smaller than 44 px tall, nothing within 20 px of the edge. Output is
one PNG — `images/AppIcon.png` — with its SVG source beside it.

The **Main model** does everything here: asks, draws, renders, shows, revises. No sub-agent.
Every question goes through the options mechanism (Ops § Asking and Approvals): `AskUserQuestion`
in Claude Code, `askQuestions` in GitHub Copilot Chat, `ask_user` in the Copilot CLI (with *I'll
type it* where a typed answer is possible). Two to four options per question, the recommended one
first.

## Step 1: Know the app

Read, don't ask: `app.json` (name, publisher), the problem statement or intake answer if the journey
has one (`docs/1-define/ProblemStatement.md`, `docs/ProblemStatement.md`, `requirements/`), the
object names under `src/` if any. From them, write down in one line what the app is about — the
icon's subject when the human gives no description. Check `images/` first: an image already there
is offered by the identity box, not redrawn.

## Step 2: Ask, in one box (four questions)

1. **Style?** — **Flat 2D (recommended — crisp at 32 px)** / *Isometric 3D* (a simple extruded
   shape with two shaded faces; no photorealism).
2. **Colors?** — *One color* / **Two colors (recommended)** / *A two-color gradient*. In the
   question's text, propose the colors: the publisher's brand colors if the human has named any
   (Ops § Intake → *Forbidden sources* — propose only what they wrote, never a color pulled from a
   website or an email signature), else a pairing suited to the app's subject (for example deep
   blue `#0F6CBD` with teal `#0A7C85`), each named with its hex value; free text takes the human's
   own.
3. **Content?** — **An image only (recommended — a word mark is unreadable at 32 px)** / *A word
   mark and an image* (two to four letters at most, the app's initials or a short word, set large).
4. **Anything the icon must show or avoid?** — **Use your best understanding of what the app is
   about** (say in the option's description what that understanding is, from Step 1) / *I'll
   describe it* (free text: a motif, a symbol to avoid, a reference).

In Copilot CLI, one question at a time in this order. Record the four answers in the project's
record (`docs/0-project/ProjectMemory.md` in Full; the Lite parameter row's note; `feature.json`
on Build-a-Feature) as the icon brief.

## Step 3: Draw it — an SVG, to the standard

Write `images/AppIcon.svg` yourself, whole, from `references/icon-standard.md`'s skeleton: the
300 × 300 `viewBox`, the `clipPath` rounded rectangle every painted element sits inside, the
background fill (one color, two colors as two shapes, or the `linearGradient`), the motif as a
few bold geometric shapes (a document, a box, a gear, a truck, a tag, a shield, a chart —
whatever Step 1 and the answers call for) with strong contrast against the background, the
optional word mark in a bold sans-serif at 44 px or more. **Nothing outside the clip path; no
raster images; no fonts the renderer may lack beyond `Arial, Helvetica, sans-serif`; no filters
or effects a 32 px render loses.** Say in one line what you drew and why it stands for the app.

## Step 4: Render it to PNG — nothing to install — and show it

The zero-install ladder (Rule 6d; Ops § Asking and Approvals). Stop at the first that exists;
every one of these produces a 300 × 300 PNG with a transparent background from the SVG:

| Where | Command | Note |
|---|---|---|
| **macOS** | `qlmanage -t -s 300 -o images images/AppIcon.svg` then `mv images/AppIcon.svg.png images/AppIcon.png` | Quick Look's thumbnailer, on every Mac; verified October 16, 2026: 300 × 300 RGBA |
| **Any OS with Chrome or Edge** | `"<browser>" --headless=new --screenshot="<abs>/images/AppIcon.png" --window-size=300,300 --default-background-color=00000000 --hide-scrollbars --disable-gpu "file://<abs>/images/AppIcon.svg"` | macOS: `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome` or `/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge`; Windows: `C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe` or Chrome under `Program Files`; Linux: `google-chrome`, `microsoft-edge`, `chromium`. The transparent default background is what keeps the corners clear. Verified on Edge, October 16, 2026 |
| **ImageMagick / librsvg / Inkscape, if on `PATH`** | `magick images/AppIcon.svg -background none images/AppIcon.png` · `rsvg-convert -w 300 -h 300 images/AppIcon.svg -o images/AppIcon.png` · `inkscape images/AppIcon.svg -w 300 -h 300 -o images/AppIcon.png` | only when already installed; never install for this |
| **Python with cairosvg present** | `python3 -c "import cairosvg; cairosvg.svg2png(url='images/AppIcon.svg', write_to='images/AppIcon.png', output_width=300, output_height=300)"` | `python3 -c "import cairosvg"` must succeed first |
| **Otherwise** | write `images/icon-preview.html` from the reference file (it embeds the SVG, shows it at 300, 64, and 32 px on light and dark, and has a **Save as PNG** button that draws it on a canvas and downloads `AppIcon.png`), open it, and ask the human to click the button and save into `images/` | the one case with a human step; say so plainly |

Check the result before showing it: the PNG header says 300 × 300 and color type 6 (RGBA) — the
reference file has the one-line check; a color type without alpha means the background is not
transparent and the render is redone with the next rung. Then **open it** with the OS default
opener (`open` / `start` / `xdg-open`) — the preview page when it was written, else the PNG — so
the human sees it at once.

## Step 5: Accept, or make another

One box: **Accept this icon** / *Make another — I'll say what to change* (free text: the motif,
the colors, bolder, simpler, add the initials) / *Make another — your call*. On a change, update
the SVG, re-render, show, ask again; keep the previous attempt as `images/AppIcon-<n>.svg/.png` so
the human can go back to it (*Other* with the number). On **Accept**:

1. `images/AppIcon.png` and `images/AppIcon.svg` stay (the source, for the next change of mind);
   delete the numbered rejects unless the human wants them kept.
2. Place it as the app icon exactly as Ops § Intake → *The app icon* says: copy the PNG to
   `src/logo/AppLogo.png` and write `"logo": "src/logo/AppLogo.png"` into `app.json` (keep every
   other value). Say both paths in one line. `images/` and `src/logo/` are the project's and
   tracked (Ops § Repository Hygiene).
3. Record *icon created by the agent, accepted <date>, brief: <the four answers>* where the
   journey keeps its record; the dashboard shows the icon at its next refresh.

## What this skill never does

Never fetches an image or a color from the web, a brand site, or an email signature; never installs
a renderer; never writes anything but `images/AppIcon*.svg`, `images/AppIcon*.png`,
`images/icon-preview.html`, `src/logo/AppLogo.png`, and `app.json`'s `logo`; never sets `logo`
before the human accepted; never asks in prose.
