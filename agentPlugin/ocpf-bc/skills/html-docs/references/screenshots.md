# Screenshots for the help site

Screenshots turn a user guide into something a person can follow with their eyes. They are the
human's to take (the agent has no Business Central session), so the skill asks for them early,
tells the human exactly where to put them, renames them to names that say what they show, and
places each one where the guide talks about it.

## Where they go

`docs/screenshots/` — tracked in git like every other project document (Ops § Repository Hygiene
never ignores `docs/`), served by GitHub Pages beside `docs/index.html`. The human drops the files
in with whatever names the capture tool gave them (`Screenshot 2026-10-19 at 09.14.22.png`,
`image (3).png`, `Capture.PNG`); the agent renames them. PNG preferred; JPEG and WebP are fine.
**Nothing goes under `images/`** — that folder is the app icon's (Ops § Intake → *The app icon*).

## What to ask for

Say what would help, as a list the human can tick off, taken from the User Guide's task sections —
one screenshot per thing the guide tells the reader to look at or click: the setup page or wizard
with its fields filled (test data, never a real key or customer), the card with the action visible,
each dialog or page the task opens, the result (the message, the updated field, the log), the
list pages the guide names. Ask for the page at a sensible width — the browser maximised, the
page's own zoom at 100 % — and for Business Central's standard theme, light, so the page looks
the same as the reader's. Tell the human not to crop out the page title or the action bar: a
reader orients on them.

## Renaming — the rule

Every file in `docs/screenshots/` gets a name that says **what the picture shows**, in this shape:

```
<page-or-object>-<what-is-happening>.png     all lowercase, words joined by hyphens, ASCII only
```

Examples: `setup-page.png`, `wizard-2-api-key.png`, `customer-card-validate-address-action.png`,
`suggested-address-window.png`, `validation-log-list.png`, `error-not-set-up.png`. A numbered
sequence keeps the number right after the thing it sequences (`wizard-1-welcome`, `wizard-2-…`).
No dates, no "Screenshot", no spaces, no parentheses, no capitals — a URL carries every one of
these badly, and a reader of the folder should know the file from its name.

**How the agent knows what a picture shows:** it looks at it (the file read tool shows images).
For each file: open it, say in one line what page and state it shows, propose the name. Then one
box with the whole list — *Rename all as proposed (recommended)* / *I'll adjust some — tell me
which* — and only then rename (`git mv` when the file is tracked, else `mv`), never a file at a
time, never without the human seeing the list. A screenshot the agent can't make sense of is asked
about by name, not guessed at.

## Placing them

Each screenshot is referenced from the Markdown source — the User Guide, the Documentation, the
FAQ — with a relative path from that document's folder and an alt text that describes the
picture for a reader who can't see it:

```markdown
![Google Address Validation Setup page with the API key entered](../screenshots/setup-page.png)
```

(`../screenshots/` from `docs/4-prove/`; `screenshots/` from a flat `docs/` on a feature project.)
The build rewrites the path for the site. Put the image **right after the sentence that tells the
reader to open or look at the thing it shows**, never in a gallery at the end; one per step at
most. The Markdown stays complete without the pictures — a reader of the repository on a phone
still gets the text.

**Unused and missing.** After the build: a file in `docs/screenshots/` no document references is
listed to the human (keep it for later or delete it — their call); a reference to a file that
isn't there is a build warning (`missing image`) and is fixed before the site is called done.
