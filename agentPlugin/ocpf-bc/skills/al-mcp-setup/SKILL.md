---
name: al-mcp-setup
description: Connect the AI to Microsoft's AL tools (build, compile, symbols, diagnostics, publish, tests) for a Business Central AL project, with nothing to install, using the AL Language extension already on the machine. Use when the user asks to "set up the AL MCP server", "connect the AL tools", "check AL tooling", "why can't you compile", or when the OCPF start skill reaches its tooling step.
---

# Connect the AL tools, zero-install

**The rule: use what's already on the machine first.** Anyone developing AL already has the **AL
Language extension** in VS Code. It ships Microsoft's AL tools and the .NET runtime they need. So:
- Don't install .NET, a NuGet tool, or anything else while the AL extension is present.
- Never ask the human to edit `PATH`, shell profiles, or environment variables.

**You do the setup; the human only approves.** The human's part is limited to the AI tool's own
permission prompts.
- **Never send the human to the Command Palette for this.** The AL Language extension has no
  command that sets up or registers an AL MCP Server. Its only MCP commands sign in to the
  separate Profiling and Snapshot servers.
- **Never use a third-party bridge extension** (such as the *AL Language Model Tools — MCP Bridge*
  VSIX), and don't depend on one that's already registered. It isn't on the Marketplace, and it
  needs VS Code relaunched with a proposed API enabled.

The AL extension exposes its tools in two ways. Which one applies depends on the tool you're
running in.

## Step 1: Which tool are you running in?

### GitHub Copilot Chat in VS Code: nothing to set up

The AL Language extension provides its AL tools to Copilot Chat directly: `al_build`,
`al_publish`, `al_downloadsymbols`, `al_symbolsearch`, `al_getdiagnostics`, `al_getnextobjectid`,
`al_symbolrelations`, `al_debug`, `al_setbreakpoint`, `al_snapshotdebugging`.
- **If you have those tools,** tell the human the AL tools are ready. Record
  `"alMcp": "al-extension-tools"` in `.ocpf/framework.json` if it exists, and stop. (The runbook
  turns on Microsoft's code analyzers for these tools later, in `.vscode/settings.json` at
  scaffolding — ALL ALONG → Analyzers. Nothing to do for that here.)
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
Before stopping, make sure the project's `scripts/` folder has this operating system's analyzer
compile script (`al-analyze.sh`, or `al-analyze.cmd` and `al-analyze-resolve.ps1` on Windows) —
the runbook's mandatory compile needs it, and the server's own compile tools don't apply
analyzers. Copy any that are missing, as in Step 4.1. Then record `"alMcp": "al-extension-mcp"`
and stop.

## Step 3: Say what you're doing — don't ask

Connecting the AL tools is the agent's job, not a decision for the human (runbook Operating Rule
6d). Tell the human in one sentence: you're connecting Microsoft's AL tools using the AL Language
extension already installed, nothing will be installed, and a few small scripts plus one MCP entry
will be added to the project. Then continue.

If the human says to hold off, record `"alMcp": "deferred"` and stop. The runbook needs these tools
at the end of intake anyway, to download symbols before design (full framework Step 01 §1.10, Lite
end of Step 1), and connects them then.

## Step 4: Connect

1. **Copy the launcher, the one-shot helper, and the analyzer compile script for this operating
   system** from this skill's `scripts/` folder into the project's `scripts/` folder (create it if
   needed). Copy exactly; don't rewrite.
   - **macOS or Linux:** `al-mcp.sh`, `al-mcp-call.sh`, and `al-analyze.sh`
   - **Windows:** `al-mcp.cmd`, `al-mcp-resolve.ps1` (the `.cmd` calls it), `al-mcp-call.ps1`,
     `al-analyze.cmd`, and `al-analyze-resolve.ps1` (the analyze `.cmd` calls it)

   The launcher looks up the newest AL extension and its .NET runtime every time it starts, so AL
   extension updates never break it. If Microsoft's `al` .NET tool happens to be installed, it
   uses that instead. The helper runs one AL MCP Server tool through the launcher and exits
   (step 5). The analyzer script runs the runbook's mandatory compile with Microsoft's code
   analyzers attached, because the AL MCP Server's own `al_build`/`al_compile` tools don't apply
   them (runbook ALL ALONG → Analyzers).
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
   - **If the extension is installed but its .NET runtime isn't there yet,** the AL extension has
     never started on this machine. Ask the human to open this project folder in VS Code once
     (it starts when the folder has an `app.json`), then check again. This is the only broken
     case that needs the human.
5. **Keep working in this session: no restart, nothing for the human to do.** Claude Code and
   Copilot CLI load MCP servers when a session starts, so the new `al` server appears in the next
   session. Until then, call any AL MCP Server tool through the helper. It starts the server with
   the project loaded, runs one tool, prints the JSON-RPC response, and exits:
   - **macOS or Linux:** `sh scripts/al-mcp-call.sh . al_getpackagedependencies`
   - **Windows:** `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\al-mcp-call.ps1 . al_getpackagedependencies`

   Arguments go in a third, JSON parameter, for example
   `sh scripts/al-mcp-call.sh . al_downloadsymbols '{"globalSourcesOnly":true}'`. Each call takes a
   few seconds. **If the project already has `app.json`,** run the first example now to confirm
   the server answers, and if `.alpackages/` is missing, download symbols with the second: the
   runbook needs them before DESIGN (ALL ALONG → Symbols). **In a new, empty folder,** the step 4
   check is enough for now. The runbook writes `app.json` and downloads symbols at the end of
   intake.
6. **Tell the human what to expect, in one or two sentences:** approval clicks only.
   - **While you work:** the tool may ask permission before you edit `.mcp.json` (Claude Code
     treats it as a sensitive file) or run a script.
   - **Next session:** Claude Code asks once to approve the project's new `al` server.
   - Don't mention `/mcp`, restarts, or the Command Palette. Nothing is waiting on them.
7. **Record the outcome** as `"alMcp": "al-extension-mcp"` in `.ocpf/framework.json`.
8. **Once the server's tools are in the session,** add the project with `al_addproject` (the
   project root), as the runbook's AL MCP Server section describes.

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

Copy `al-analyze.sh` into the project's `scripts/` folder, as in Step 4.1. It finds the `al`
tool's own analyzers and a .NET runtime it can run on, so the mandatory compile runs with
analyzers here too.

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
