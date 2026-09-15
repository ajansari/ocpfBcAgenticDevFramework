---
name: al-mcp-setup
description: Connect the AI to Microsoft's AL tools (build, compile, symbols, diagnostics, publish, tests) for a Business Central AL project, with nothing to install, using the AL Language extension already on the machine. Use when the user asks to "set up the AL MCP server", "connect the AL tools", "check AL tooling", "why can't you compile", or when the OCPF start skill reaches its tooling step.
---

# Connect the AL tools, zero-install

**The rule: use what's already on the machine first.** Anyone developing AL already has the **AL
Language extension** in VS Code. It ships Microsoft's AL tools and the .NET runtime they need. So:
- Don't install .NET, a NuGet tool, or anything else while the AL extension is present.
- Never ask the human to edit `PATH`, shell profiles, or environment variables.

The AL extension exposes its tools in two ways. Which one applies depends on the tool you're
running in.

## Step 1: Which tool are you running in?

### GitHub Copilot Chat in VS Code: nothing to set up

The AL Language extension provides its AL tools to Copilot Chat directly: `al_build`,
`al_publish`, `al_downloadsymbols`, `al_symbolsearch`, `al_getdiagnostics`, `al_getnextobjectid`,
`al_symbolrelations`, `al_debug`, `al_setbreakpoint`, `al_snapshotdebugging`.
- **If you have those tools,** tell the human the AL tools are ready. Record
  `"alMcp": "al-extension-tools"` in `.ocpf/framework.json` if it exists, and stop.
- **If you don't,** the AL Language extension isn't installed or isn't active yet. Ask the human to
  install **AL Language extension for Microsoft Dynamics 365 Business Central** from the Extensions
  view, or to open an `.al` file so it activates. Stop there. Every AL developer needs that
  extension anyway, and there's nothing else to do.

### Claude Code, GitHub Copilot CLI, or another local MCP host: register the AL MCP Server once per project

These tools can't see the AL extension's Copilot tools, but they can run the AL extension's own
**AL MCP Server** (`altool launchmcpserver`, 16 tools, including `al_compile`, `al_build`,
`al_symbolsearch`, and `al_addproject`). Continue with Step 2.

### Cloud session (Claude Code on the web, Copilot cloud agent): no VS Code there

Skip to [Cloud sessions](#cloud-sessions).

## Step 2: Check it isn't already connected

If this session already has tools such as `al_compile` and `al_addproject`, the server is connected.
Record `"alMcp": "al-extension-mcp"` and stop.

## Step 3: Offer it with one question

Ask once, through the options mechanism:
- **Connect the AL tools for this project (recommended).** Uses the AL Language extension already
  installed; nothing is installed. Adds a small launcher script and one MCP entry to the project.
- **Not now.** Record `"alMcp": "deferred"`. The runbook offers it again when BUILD starts.

## Step 4: Connect

1. **Copy the launcher for this operating system** from this skill's `scripts/` folder into the
   project's `scripts/` folder (create it if needed). Copy exactly; don't rewrite.
   - **macOS or Linux:** `al-mcp.sh`
   - **Windows:** `al-mcp.cmd` **and** `al-mcp-resolve.ps1` (the `.cmd` calls the `.ps1`)

   The launcher looks up the newest AL extension and its .NET runtime every time it starts, so AL
   extension updates never break it. If Microsoft's `al` .NET tool happens to be installed, it
   uses that instead.
2. **Add `scripts/` to the project's `.gitignore`** if it isn't there. It's framework plumbing, not
   the client's deliverable (runbook ALL ALONG → Repository Hygiene).
3. **Add the `al` server to `.mcp.json` in the project root.** Create the file if needed. If it
   exists, add this one entry and keep everything else; never overwrite other servers.
   - **macOS or Linux:**
     ```json
     { "mcpServers": { "al": { "command": "sh", "args": ["scripts/al-mcp.sh"] } } }
     ```
   - **Windows:**
     ```json
     { "mcpServers": { "al": { "command": "cmd.exe", "args": ["/c", "scripts\\al-mcp.cmd"] } } }
     ```

   Claude Code and Copilot CLI both read `.mcp.json` from the project root.
4. **Check the launcher before telling the human it works.** Run it with `--help`, for example
   `sh scripts/al-mcp.sh --help` or `scripts\al-mcp.cmd --help`, and confirm it prints the
   `launchmcpserver` usage.
   - **If it prints an `OCPF AL MCP launcher:` message instead,** relay that message; it says
     exactly what's missing, usually that the AL extension isn't installed.
   - **If the extension is installed but its .NET runtime isn't there yet,** ask the human to open
     an `.al` file in VS Code once so the extension provisions it, then check again.
5. **Tell the human what to expect:** approval clicks only, no typing or installs.
   - **While you work:** the tool may ask permission before you edit `.mcp.json` (Claude Code
     treats it as a sensitive file) or run the launcher check. Say so before you start, so the
     prompt isn't a surprise.
   - **Afterwards, approve the new `al` server when the tool asks.** In Claude Code, that happens
     the next time a session starts in this folder; start a new session, or run `/mcp`. In Copilot
     CLI, restart the session (`/restart`).
6. **Record the outcome** as `"alMcp": "al-extension-mcp"` in `.ocpf/framework.json`.
7. **Once connected,** add the project with `al_addproject` (the project root), as the runbook's AL
   MCP Server section describes.

## Cloud sessions

Cloud environments have no VS Code, so there's no AL extension to use. Here, and only here,
Microsoft's `al` .NET tool is the route. Install it in the environment's **setup script**, not in
the chat. The launcher then finds `al` on `PATH`.

- **Claude Code on the web:** add to the cloud environment's setup script:
  ```bash
  dotnet tool install --global Microsoft.Dynamics.BusinessCentral.Development.Tools
  echo 'export PATH="$PATH:$HOME/.dotnet/tools"' >> ~/.bashrc
  ```
- **Copilot cloud agent:** add to `.github/workflows/copilot-setup-steps.yml`:
  ```yaml
  - uses: actions/setup-dotnet@v5
    with:
      dotnet-version: "8.0.x"
  - run: |
      dotnet tool install --global Microsoft.Dynamics.BusinessCentral.Development.Tools
      echo "$HOME/.dotnet/tools" >> "$GITHUB_PATH"
  ```

Cloud sessions can compile but can't complete Business Central's interactive sign-in, so
publishing stays a local step.

## Terminal-only machine without VS Code

This is rare for AL work. If there's no AL extension, offer Microsoft's `al` .NET tool:
```
dotnet tool install --global Microsoft.Dynamics.BusinessCentral.Development.Tools
```
It needs a .NET 8+ SDK from Microsoft's standard installer, which also puts the tools folder on
`PATH`. **Installing is an approval** (Operating Rule 6b). Don't run it without a yes.

## Signing in

Tools that reach a live Business Central environment (publish, downloading non-global symbols)
open an interactive Microsoft sign-in the first time they're used in a session. That's expected.
