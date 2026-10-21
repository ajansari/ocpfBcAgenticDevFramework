# OCPF BC Agentic Development Framework — the live dashboard renderer, PowerShell port.
# Renders ProjectDashboard.html (project root, tracked in git - never under the ignored ocpfFramework/state/)
# for one project from the state the framework already keeps
# (app.json, framework.json, usage.json, ProjectProgress.md — the step table, or Build-a-Feature's feature table — the step files, pricing.json, waiting.json,
# the sub-agent definitions, the usage script's -Json output, and — in Claude Code — the transcripts).
# Mirrors ocpf-dashboard.py (the Python script is the reference implementation); exercised on PowerShell 7
# on macOS; needs PowerShell 7 (pwsh) on every OS, and the dashboard skill's hook proof (Ops § Dashboard → 3) is what proves it on each machine. Internal variables avoid the parameter names (names are case-insensitive).
#   pwsh ocpf-dashboard.ps1 -Project <root> [-Open] [-Quiet] [-Refresh 30] [-Toast "text"] [-Live]
#   pwsh ocpf-dashboard.ps1 -Project <root> -WaitingJson '<hook input>'    # a question opened
#   pwsh ocpf-dashboard.ps1 -Project <root> -ClearWaiting                   # it was answered
#   pwsh ocpf-dashboard.ps1 -Project <root> -CloseProject                   # the human said Done: completed state, clocks stopped
#   pwsh ocpf-dashboard.ps1 -Project <root> -Event who,text                 # append a feed event
param(
  [string]$Project = ".", [switch]$Open, [switch]$Quiet, [int]$Refresh = 30, [string]$Toast, [switch]$Live,
  [string]$WaitingJson, [switch]$ClearWaiting, [switch]$CloseProject, [string[]]$Event, [int]$Throttle = 0, [string]$Theme
)
$ErrorActionPreference = "Stop"
try {
$root = (Resolve-Path $Project).Path
$stateDir = Join-Path $root "ocpfFramework/state"
if (-not (Test-Path (Join-Path $root "ocpfFramework"))) { if ($Quiet) { exit 0 }; Write-Error "$root has no ocpfFramework/ folder — not an OCPF project"; exit 1 }
New-Item -ItemType Directory -Force -Path $stateDir | Out-Null
if ($Throttle -gt 0 -and -not ($WaitingJson -or $ClearWaiting -or $Event -or $Open -or $CloseProject)) { $pg = Join-Path $root "ProjectDashboard.html"; if ((Test-Path $pg) -and (((Get-Date) - (Get-Item $pg).LastWriteTime).TotalSeconds -lt $Throttle)) { exit 0 }; if ((Test-Path "$pg.tmp") -and (((Get-Date) - (Get-Item "$pg.tmp").LastWriteTime).TotalSeconds -lt 120)) { exit 0 } }
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
function Load-Json($p, $d) { if (Test-Path $p) { try { Get-Content $p -Raw | ConvertFrom-Json -AsHashtable } catch { $d } } else { $d } }
function Read-Text($p) { if (Test-Path $p) { Get-Content $p -Raw } else { "" } }
function Parse-Ts($s) { if (-not $s) { return $null }; if ($s -is [datetime]) { return $s.ToUniversalTime() }; try { return ([datetimeoffset]::Parse($s)).UtcDateTime } catch { return $null } }
function NowUtc { [datetime]::UtcNow }
function Iso($d) { $d.ToString("yyyy-MM-ddTHH:mm:ssZ") }
$FULL = @(@("PRE-01","DEFINE"),@("PRE-02","DEFINE"),@("01","DEFINE"),@("02","DESIGN"),@("03","DESIGN"),@("04","DESIGN"),@("05","BUILD"),@("06","BUILD"),@("07","BUILD"),@("08","PROVE"),@("09","PROVE"),@("10","PROVE"),@("11","PROVE"),@("12","PROVE"))
$LITE = @(@("STEP-1","DEFINE"),@("STEP-2","DESIGN"),@("STEP-3","BUILD"),@("STEP-4","BUILD"),@("STEP-5","BUILD"),@("STEP-6","PROVE"),@("STEP-7","PROVE"))
$PHASES = @("DEFINE","DESIGN","BUILD","PROVE")
# Build-a-Feature (edition "feature"): no step files; one row per object, read from usage.json's windows and the feature table
$FEATURE_PHASES = @("INTAKE","BUILD","REVIEW","PACKAGE")  # the review is offered before the package
$FEATURE_GATES = @{
  "INTAKE" = @("The one intake question answered and the plan said back, object by object.", "The F00 window closed with its usage rows.")
  "BUILD" = @("Asked: what the object is and what it holds.", "Confirmed: fields, types, and the key confirmed in one box.", "Built: the file written whole from the Standards Guide and the patterns library.", "Compiled: 0 errors / 0 warnings with the analyzers.",
             "Documented: its section in docs/Documentation.md, its row in docs/FeatureRegister.md and docs/DataModel.md, its ChangeLog line.", "Closed: usage rows written and pasted; the companion box answered.")
  "PACKAGE" = @("Version moved per Ops § Packaging → Version numbers; the package in outputAppPackage/; Shipped in filled on every row it holds.")
  "REVIEW" = @("Standards Guide, BCQuality, and the AL Guidelines read against this session's files; findings presented once; approved fixes compiled clean.") }
function Feature-Phase($sid) { if ($sid -eq "F00") { "INTAKE" } elseif ($sid -eq "FPK") { "PACKAGE" } elseif ($sid -eq "FRV") { "REVIEW" } else { "BUILD" } }
function Blank($v) { -not $v -or "$v" -in "—","-" }
$SHORT = @{ "PRE-01"="State the Problem"; "PRE-02"="Gap Analysis"; "01"="Intake Sheet"; "02"="FRD"; "03"="TDD"; "04"="Sanity Check"; "05"="Plan the Code"; "06"="Code Generation"; "07"="Compile & Package"; "08"="Gap-Fit Test"; "09"="Code Review"; "10"="Update Design Docs"; "11"="Document the Code"; "12"="Release for Testing"; "STEP-1"="Define & Lock"; "STEP-2"="Design Doc"; "STEP-3"="Plan & Scaffold"; "STEP-4"="Generate"; "STEP-5"="Compile & Test"; "STEP-6"="Review & Finalize"; "STEP-7"="Release for Testing" }

# ---- events / waiting (hook entry points) ----
$evPath = Join-Path $stateDir "dashboard-events.jsonl"
function Add-Event($who, $text) { ([ordered]@{ at = (Iso (NowUtc)); who = $who; text = $text } | ConvertTo-Json -Compress) | Add-Content -Path $evPath -Encoding utf8 }
if ($WaitingJson) {
  if ($WaitingJson -eq "-") { $WaitingJson = ($input | Out-String); if (-not $WaitingJson.Trim()) { try { $WaitingJson = [Console]::In.ReadToEnd() } catch { } } }
  try { $inp = $WaitingJson | ConvertFrom-Json -AsHashtable } catch { $inp = @{} }
  $ti = if ($inp.tool_input) { $inp.tool_input } elseif ($inp.toolInput) { $inp.toolInput } else { $inp }
  $qs = @(); if ($ti.questions) { $qs = @($ti.questions) } elseif ($ti.question) { $qs = @($ti) }
  if ($qs.Count) { $q = $qs[0]
    $opts = @(foreach ($o in @($q.options)) { [ordered]@{ label = ($o.label ?? $o.title ?? "$o"); description = ($o.description ?? "") } })
    $w = [ordered]@{ since = (Iso (NowUtc)); question = ($q.question ?? $q.header ?? "A question is waiting"); options = $opts; count = $qs.Count }
    $w | ConvertTo-Json -Depth 5 | Set-Content -Path (Join-Path $stateDir "waiting.json") -Encoding utf8
    Add-Event "Agent" ("asked: " + "$($w.question)".Substring(0, [Math]::Min(80, "$($w.question)".Length))) }
}
if ($ClearWaiting) { $wp = Join-Path $stateDir "waiting.json"; if (Test-Path $wp) { $w = Load-Json $wp @{}; $w["clearedAt"] = Iso (NowUtc); $w | ConvertTo-Json -Depth 5 | Set-Content -Path $wp -Encoding utf8; Add-Event "You" "answered" } }
if ($Event -and $Event.Count -ge 2) { Add-Event $Event[0] $Event[1] }
# The human said the project is done (v5.9.5.0): stamp projectClosedAt, close every open window there, log it.
$mk0 = Load-Json (Join-Path $root "ocpfFramework/framework.json") @{}
if ($CloseProject -and "$($mk0.edition)".ToLower() -ne "feature") { Add-Event "Agent" "-CloseProject ignored — a Full or Lite project closes at its last step (Ops § Dashboard → 6)"; $CloseProject = $false }  # a Build-a-Feature run inside a Full or Lite project never closes the host
if ($CloseProject) { $up = Join-Path $stateDir "usage.json"; $u = Load-Json $up @{}; if (-not $u.projectClosedAt) { $u["projectClosedAt"] = Iso (NowUtc) }
  foreach ($s in @($u.steps)) { if ($s.startedAt -and -not $s.completedAt) { $s["completedAt"] = $u.projectClosedAt } }
  $u | ConvertTo-Json -Depth 8 | Set-Content -Path $up -Encoding utf8; Add-Event "You" "closed the project — completed" }
if ($Live -or $Theme) { $dj = Load-Json (Join-Path $stateDir "dashboard.json") @{}; if ($Live) { $dj["hooks"] = $true }; if ($Theme) { $dj["theme"] = $Theme.ToLower() }; if (-not $dj.theme) { $dj["theme"] = "brand" }; $dj | ConvertTo-Json | Set-Content -Path (Join-Path $stateDir "dashboard.json") -Encoding utf8 }

# ---- facts ----
$fw = Load-Json (Join-Path $root "ocpfFramework/framework.json") @{}
$usage = Load-Json (Join-Path $stateDir "usage.json") @{}
$tool = if ($usage.aiTool) { $usage.aiTool } elseif ("$($fw.placedAs)" -like "*copilot-instructions*") { "copilot-chat" } else { "claude-code" }
$copilot = $tool -like "copilot*"
$edition = if ($fw.edition) { "$($fw.edition)".ToLower() } elseif (Test-Path (Join-Path $root "ocpfFramework/runbookSteps/STEP-1.md")) { "lite" } else { "full" }
$app = Load-Json (Join-Path $root "app.json") @{}
$icon = $null
if ($app.logo -and (Test-Path (Join-Path $root $app.logo))) { $bytes = [IO.File]::ReadAllBytes((Join-Path $root $app.logo)); if ($bytes.Length -lt 400000) { $ext = ([IO.Path]::GetExtension($app.logo)).TrimStart('.').ToLower(); if (-not $ext) { $ext = "png" }; if ($ext -in "jpg","jpeg") { $ext = "jpeg" }; $icon = "data:image/$ext;base64," + [Convert]::ToBase64String($bytes) } }
$bc = $null; foreach ($k in "application","platform") { $v = $app[$k]; if ($v -is [string] -and $v -match '^(\d+)\.') { $bc = $Matches[1]; break } }
$appFacts = [ordered]@{ name = $app.name; publisher = $app.publisher; version = $app.version; bc = $bc; iconDataUri = $icon; target = $app.target }

$closedAt = Parse-Ts $usage.projectClosedAt  # the project was closed (v5.9.5.0): a window still open then ends there, so the clock stops
$wins = @(); foreach ($s in @($usage.steps)) { $a = Parse-Ts $s.startedAt; if ($a -and $s.step) { $b = Parse-Ts $s.completedAt; if ($null -eq $b -and $closedAt -and $a -le $closedAt) { $b = $closedAt }; $wins += ,@($s.step, $a, $b) } }
$wins = @($wins | Sort-Object { $_[1] }); for ($i = 0; $i -lt $wins.Count; $i++) { if ($null -eq $wins[$i][2] -and $i + 1 -lt $wins.Count) { $wins[$i][2] = $wins[$i + 1][1] } }
# A project closed by hand — the last step's row Completed, no -CloseProject / -Calibrate behind it: stamp projectClosedAt on first
# sight, before the usage script measures, so the clock stops here instead of running on in the last step's open window (v5.9.5.0;
# Ops § Dashboard → 6). Not while a feature session's window is open in this host (Case A): not closed, and never cut short.
if ($edition -ne "feature" -and -not $closedAt) {
  $baseIds = @($(if ($edition -eq "lite") { $LITE } else { $FULL }) | ForEach-Object { $_[0] }); $lastBase = $baseIds[-1]; $lastSt = ""
  foreach ($line in (Read-Text (Join-Path $root "ProjectProgress.md")) -split "`n") { if ($line -match '^\|\s*(DEFINE|DESIGN|BUILD|PROVE)\s*\|\s*([A-Za-z0-9-]+)\s*[—-]\s*[^|]*\|\s*([^|]*)\|' -and $Matches[2] -eq $lastBase) { $lastSt = $Matches[3].Trim().ToLower() } }
  $foreignOpen = @($wins | Where-Object { $null -eq $_[2] -and $_[0] -notin $baseIds }).Count
  if (($lastSt -like "complet*" -or $lastSt -like "done*") -and -not $foreignOpen) {
    $usage["projectClosedAt"] = Iso (NowUtc); $closedAt = Parse-Ts $usage.projectClosedAt
    foreach ($s in @($usage.steps)) { if ($s.startedAt -and -not $s.completedAt) { $s["completedAt"] = $usage.projectClosedAt } }
    $usage | ConvertTo-Json -Depth 8 | Set-Content -Path (Join-Path $stateDir "usage.json") -Encoding utf8
    foreach ($w in $wins) { if ($null -eq $w[2]) { $w[2] = $closedAt } }
    Add-Event "Agent" "$lastBase is Completed in ProjectProgress.md — project closed, clocks stopped"
  }
}
# ---- usage rows via the usage script ----
$notes = @(); $uj = $null
if ($wins.Count) {
  $script = Join-Path $here "ocpf-usage.ps1"
  if (-not (Test-Path $script)) { foreach ($c in @((Join-Path $root "ocpfFramework/scripts/ocpf-usage.ps1"), (Join-Path $here "../../usage/scripts/ocpf-usage.ps1"))) { if (Test-Path $c) { $script = $c; break } } }
  if (Test-Path $script) { try { $out = & pwsh -NoProfile -File $script -Project $root -Json 2>&1; $uj = ($out | Out-String) | ConvertFrom-Json -AsHashtable } catch { $notes += "usage: $_" } } else { $notes += "usage script not found beside the dashboard script" }
} else { $notes += "usage: no step windows yet" }
$rows = @(if ($uj -and $uj.rows) { $uj.rows })
$pricing = Load-Json (Join-Path $stateDir "pricing.json") @{}   # the usage script may just have fetched the prices (v5.8.0.0)
function Rows-For($sid) { @($rows | Where-Object { ("$($_.step)" -replace ' \(open\)$', '') -eq $sid }) }
function Sum($arr, $k) { $t = 0.0; foreach ($r in $arr) { $t += [double]($r[$k] ?? 0) }; $t }

# The first window begins where its session began — Claude Code: the transcript file that holds the recorded startedAt;
# Copilot: the journaled session the usage script summarises — otherwise the tokens start before the clock (v5.8.0.0).
# Only a session whose span contains the recorded startedAt counts; an earlier, separate chat in the folder never does.
if ($wins.Count) {
  $spans = @()
  if ($copilot) { foreach ($x in @($uj.sessions)) { $sa = Parse-Ts $x.start; if ($sa) { ,@($sa, ((Parse-Ts $x.lastKnownAt) ?? (NowUtc))) | ForEach-Object { $spans += ,$_ } } } }
  else { $tdir0 = if ($usage.transcriptDir) { $usage.transcriptDir -replace '^~', $HOME } else { Join-Path $HOME ".claude/projects/$(($root -replace '[\\/:]', '-'))" }
    foreach ($f in @(Get-ChildItem -Path $tdir0 -Filter *.jsonl -ErrorAction SilentlyContinue)) { $lo = $null; $hi = $null
      foreach ($line in [IO.File]::ReadLines($f.FullName)) { $i = $line.IndexOf('"timestamp":"'); if ($i -lt 0) { continue }; $ts = Parse-Ts ($line.Substring($i + 13, [Math]::Min(24, $line.Length - $i - 13)).Split('"')[0]); if (-not $ts) { continue }; if ($null -eq $lo -or $ts -lt $lo) { $lo = $ts }; if ($null -eq $hi -or $ts -gt $hi) { $hi = $ts } }
      if ($lo -and $hi) { $spans += ,@($lo, $hi) } } }
  $w0 = $wins[0]; $hits = @(foreach ($sp in $spans) { if ($sp[0] -le $w0[1] -and $w0[1] -le $sp[1] -and $sp[0] -lt $w0[1]) { $sp[0] } })
  if ($hits.Count) { $s0 = ($hits | Sort-Object)[0]; $wins[0] = @($w0[0], $s0, $w0[2]); $notes += "$($w0[0]) starts at the session's first event ($($s0.ToLocalTime().ToString('HH:mm'))), before its recorded startedAt" }
}
$phases = $PHASES; $status = @{}
if ($edition -eq "feature") {
  $phases = $FEATURE_PHASES
  $frows = [ordered]@{}
  foreach ($line in (Read-Text (Join-Path $root "ProjectProgress.md")) -split "`n") { if ($line -match '^##\s+Usage and cost') { break }; if ($line -match '^\|\s*(F\d{2}|FPK|FRV)\s*\|([^|]*)\|([^|]*)\|([^|]*)\|([^|]*)\|([^|]*)\|([^|]*)\|\s*$') { $frows[$Matches[1].Trim()] = @{ object = $Matches[2].Trim(); kind = $Matches[3].Trim(); oid = $Matches[4].Trim(); stage = $Matches[5].Trim(); status = $Matches[6].Trim(); shipped = $Matches[7].Trim() } } }
  $ids = @(); foreach ($w in $wins) { if ($w[0] -notin $ids) { $ids += $w[0] } }; foreach ($rid in $frows.Keys) { if ($rid -notin $ids) { $ids += $rid } }
  $titles = @{}; foreach ($s in @($usage.steps)) { if ($s.title -and $s.step) { $titles[$s.step] = $s.title } }
  $catalog = @(foreach ($sid in $ids) { $r = $frows[$sid]; if (-not $r) { $r = @{} }; $ph = Feature-Phase $sid
    $kind = $(if (Blank $r.kind) { $null } else { $r.kind }); $obj = $(if ($r.object) { $r.object } elseif ($titles[$sid]) { $titles[$sid] } else { $sid })
    $st = "$($r.status)".ToLower(); if ($st) { $status[$sid] = $(if ($st -like "*in progress*") { "now" } elseif ($st -like "complet*" -or $st -like "done*") { "done" } else { "todo" }) }
    [ordered]@{ id = $sid; phase = $ph; title = $(if ($kind) { "$kind $obj" } else { $obj }); short = $obj; exitGate = @($FEATURE_GATES[$ph]); stage = $(if ($r.stage) { $r.stage } else { $null }); kind = $kind
      objectId = $(if (Blank $r.oid) { $null } else { $r.oid }); shippedIn = $(if (Blank $r.shipped) { $null } else { $r.shipped }) } })
} else {
$base = if ($edition -eq "lite") { $LITE } else { $FULL }
$catalog = @(foreach ($pair in $base) { $sid = $pair[0]; $ph = $pair[1]; $txt = Read-Text (Join-Path $root "ocpfFramework/runbookSteps/$sid.md"); $title = $null; $gate = @()
  if ($txt) { if ($txt -match '(?m)^# .*? — (?:PRE-0[12]|[0-9]{2}|STEP [0-9]) — (.+)$') { $title = $Matches[1].Trim() }
    if ($txt -match 'Phase:\s*([A-Z]+)') { $ph = $Matches[1] }
    if ($txt -match '(?s)\*\*Exit gate:\*\*\s*(.+?)(?:\r?\n\r?\n|\r?\n\*\*|$)') { $g = ($Matches[1] -replace '\s+', ' ').Trim(); $g = $g -replace '`([^`]*)`', '$1' -replace '\*\*([^*]*)\*\*', '$1'
      $gate = @([regex]::Split($g, '(?<=[.;])\s+(?=[A-Z§`])') | Where-Object { $_.Trim().Length -gt 3 } | ForEach-Object { $x = $_.Trim(); if ($x.Length -gt 220) { $x.Substring(0,220) + "…" } else { $x } } | Select-Object -First 7) } }
  [ordered]@{ id = $sid; phase = $ph; title = ($title ?? $SHORT[$sid] ?? $sid); short = ($SHORT[$sid] ?? $title ?? $sid); exitGate = $gate } })

foreach ($line in (Read-Text (Join-Path $root "ProjectProgress.md")) -split "`n") { if ($line -match '^\|\s*(DEFINE|DESIGN|BUILD|PROVE)\s*\|\s*([A-Za-z0-9-]+)\s*[—-]\s*[^|]*\|\s*([^|]*)\|') { $st = $Matches[3].Trim().ToLower(); $status[$Matches[2].Trim()] = $(if ($st -like "*in progress*") { "now" } elseif ($st -like "complet*" -or $st -like "done*") { "done" } elseif (-not $st -or $st -in "pending","not started") { "todo" } elseif ($st -like "*complet*") { "done" } else { "todo" }) } }
}

if ($edition -ne "feature") {
  # Remediation rows — 07a, 07b, STEP-5a … — sit after their base step (Ops § Usage & Cost → 7)
  $REM = '^(PRE-0[12]|[0-9]{2}|STEP-[0-9])([a-z])$'
  $REMGATE = @("The changed requirement is in the FRD and the TDD (Lite: the Design Doc), each updated in place with a ChangeLog entry naming this remediation.", "Every affected object regenerated and the whole extension compiled and packaged clean again, as the base step requires.", "The remediation's usage rows written and pasted; the base step's exit gate met again.")
  $titles = @{}; foreach ($s in @($usage.steps)) { if ($s.title -and $s.step) { $titles[$s.step] = $s.title } }
  $rids = @(); foreach ($sid in (@($wins | ForEach-Object { $_[0] }) + @($status.Keys))) { if ($sid -match $REM -and $sid -notin $rids) { $rids += $sid } }
  foreach ($sid in ($rids | Sort-Object)) { $null = $sid -match $REM; $base = $Matches[1]
    $anchor = -1; for ($i = 0; $i -lt $catalog.Count; $i++) { $cid = $catalog[$i].id; if ($cid -eq $base -or ($cid -match $REM -and $Matches[1] -eq $base -and $cid -lt $sid)) { $anchor = $i } }
    if ($anchor -lt 0) { continue }
    $b = $catalog | Where-Object { $_.id -eq $base } | Select-Object -First 1
    $row = [ordered]@{ id = $sid; phase = $b.phase; title = $(if ($titles[$sid]) { $titles[$sid] } else { "Remediation" }); short = "Remediation"; exitGate = @($REMGATE); remediation = $true }
    $catalog = @($catalog[0..$anchor]) + @($row) + @(if ($anchor + 1 -lt $catalog.Count) { $catalog[($anchor + 1)..($catalog.Count - 1)] }) }
}
$el = @{}; foreach ($w in $wins) { $end = $w[2] ?? (NowUtc); $el[$w[0]] = ($el[$w[0]] ?? 0) + [Math]::Max(0, ($end - $w[1]).TotalSeconds) }
# the project's elapsed time is the union of the windows, so two windows open at once count once (v5.8.0.0)
$unionSec = 0.0; $ca = $null; $cb = $null
foreach ($iv in @($wins | ForEach-Object { ,@($_[1], ($_[2] ?? (NowUtc))) } | Sort-Object { $_[0] })) { if ($null -eq $cb -or $iv[0] -gt $cb) { if ($null -ne $cb) { $unionSec += ($cb - $ca).TotalSeconds }; $ca = $iv[0]; $cb = $iv[1] } elseif ($iv[1] -gt $cb) { $cb = $iv[1] } }
if ($null -ne $cb) { $unionSec += ($cb - $ca).TotalSeconds }
function Step-Of($ts) { $hit = $null; foreach ($w in $wins) { if ($ts -ge $w[1] -and ($null -eq $w[2] -or $ts -le $w[2])) { $hit = $w[0] } }; $hit }


# ---- Claude Code transcript: time split + live state ----
$liveState = $null
if (-not $copilot -and $wins.Count) {
  $tdir = if ($usage.transcriptDir) { $usage.transcriptDir -replace '^~', $HOME } else { Join-Path $HOME ".claude/projects/$(($root -replace '[\\/:]', '-'))" }
  # a session is <id>.jsonl; its sub-agents (Agent tool) are journaled beside it in <id>/subagents/agent-*.jsonl
  $files = @(@(Get-ChildItem -Path $tdir -Filter *.jsonl -ErrorAction SilentlyContinue) + @(Get-ChildItem -Path $tdir -Directory -ErrorAction SilentlyContinue | ForEach-Object { Join-Path $_.FullName "subagents" } | Where-Object { Test-Path $_ } | ForEach-Object { Get-ChildItem -Path $_ -Filter *.jsonl -ErrorAction SilentlyContinue }) | Sort-Object LastWriteTime)
  if ($files.Count) {
    $ev = [System.Collections.Generic.List[object]]::new(); $side = @{}
    foreach ($f in $files) { foreach ($line in [IO.File]::ReadLines($f.FullName)) { try { $o = $line | ConvertFrom-Json -AsHashtable } catch { continue }
        $ts = Parse-Ts $o.timestamp; $t = $o.type; if (-not $ts -or $t -notin "user","assistant") { continue }
        $m = $o.message ?? @{}; $blocks = if ($m.content -is [array]) { $m.content } else { @() }
        if ($o.isSidechain) { $aid = $o.agentId ?? "sidechain"; if (-not $side.ContainsKey($aid)) { $side[$aid] = @{ first = $ts; last = $ts; model = $null } }; if ($ts -gt $side[$aid].last) { $side[$aid].last = $ts }; if ($t -eq "assistant" -and $m.model) { $side[$aid].model = $m.model }; continue }
        if ($t -eq "user") { $isRes = $false; foreach ($b in $blocks) { if ($b -is [hashtable] -and $b.type -eq "tool_result") { $isRes = $true } }; $ev.Add(@{ ts = $ts; k = $(if ($isRes) { "result" } else { "prompt" }); x = $null }) }
        else { $ask = $false; $txt = ""; foreach ($b in $blocks) { if ($b -is [hashtable]) { if ($b.type -eq "tool_use" -and $b.name -eq "AskUserQuestion") { $ask = $true }; if ($b.type -eq "text" -and $b.text) { $txt += " " + $b.text } } }
          $ev.Add(@{ ts = $ts; k = $(if ($ask) { "ask" } else { "agent" }); x = @{ model = $m.model; txt = $txt.Trim().Substring(0, [Math]::Min(160, $txt.Trim().Length)) } }) } } }
    if ($ev.Count) { $ev = @($ev | Sort-Object { $_.ts }); $per = @{}; $pending = $false; $prev = $null; $gapCap = 600
      function AddT($sid, $k, $v) { $key = $sid ?? "Unattributed"; if (-not $script:per.ContainsKey($key)) { $script:per[$key] = @{ agent = 0.0; human = 0.0; waiting = 0.0 } }; $script:per[$key][$k] += $v }
      foreach ($e in $ev) { if ($prev) { $gap = ($e.ts - $prev.ts).TotalSeconds; $sid = (Step-Of $prev.ts) ?? (Step-Of $e.ts)
          if ($e.k -eq "prompt") { AddT $sid $(if ($pending -and $prev.k -ne "prompt") { "waiting" } else { "human" }) $gap }
          elseif ($prev.k -eq "ask") { AddT $sid "waiting" $gap; $pending = $false }   # an options box was open; its answer comes back as a tool result, not a prompt (v5.8.0.0)
          else { if ($prev.k -eq "prompt") { AddT $sid "agent" $gap } else { AddT $sid "agent" ([Math]::Min($gap, $gapCap)); AddT $sid "human" ([Math]::Max(0, $gap - $gapCap)) } } }
        if ($e.k -eq "ask") { $pending = $true }; if ($e.k -eq "prompt") { $pending = $false }; $prev = $e }
      $last = $ev[-1]; $age = ((NowUtc) - $last.ts).TotalSeconds
      $mainState = if ($last.k -ne "prompt" -and $age -lt 180) { "working" } else { "idle" }
      $lastModel = $null; $lastTxt = ""; for ($i = $ev.Count - 1; $i -ge 0; $i--) { if ($ev[$i].x -and $ev[$i].x.model -and -not $lastModel) { $lastModel = $ev[$i].x.model }; if ($ev[$i].x -and $ev[$i].x.txt -and -not $lastTxt) { $lastTxt = $ev[$i].x.txt }; if ($lastModel -and $lastTxt) { break } }
      $subsRaw = @(foreach ($aid in $side.Keys) { $s = $side[$aid]; @{ agentId = $aid; model = $s.model; running = (((NowUtc) - $s.last).TotalSeconds -lt 120); seconds = ($s.last - $s.first).TotalSeconds; last = $s.last } })
      if ($mainState -eq "idle" -and @($subsRaw | Where-Object { $_.running }).Count -gt 0) { $mainState = "working" }  # Main is waiting on its sub-agent, not idle
      $subs = @($subsRaw | Sort-Object { $_.last } -Descending)
      $liveState = @{ perStep = $per; main = @{ state = $mainState; model = $lastModel; text = $lastTxt; lastAt = $last.ts.ToString("o") }; subs = $subs } } }
}

# the agent / you / waiting split of each step is scaled to its window, so the three add up to Elapsed exactly (v5.6.0.0)
if ($liveState) { $per = @{}; foreach ($sid in $el.Keys) { $sec = [double]$el[$sid]; $v = $liveState.perStep[$sid]; if (-not $v) { $v = @{ agent = 0.0; human = 0.0; waiting = 0.0 } }
    $tot = [double]$v.agent + [double]$v.human + [double]$v.waiting
    if ($tot -gt 0) { $per[$sid] = @{ agent = [double]$v.agent * $sec / $tot; human = [double]$v.human * $sec / $tot; waiting = [double]$v.waiting * $sec / $tot } }
    else { $per[$sid] = @{ agent = 0.0; human = $sec; waiting = 0.0 } } }  # a window with no transcript event: nobody was in the chat — the human's time (v5.8.0.0)
  $liveState.perStep = $per }

# ---- steps ----
$steps = @(foreach ($c in $catalog) { $sid = $c.id; $rs = Rows-For $sid
  $st = $status[$sid]; if (-not $st) { $openWins = @($wins | Where-Object { $_[0] -eq $sid -and $null -eq $_[2] }).Count; $any = @($wins | Where-Object { $_[0] -eq $sid }).Count; $st = $(if ($any -and -not $openWins) { "done" } elseif ($any) { "now" } else { "todo" }) }
  if ($el.ContainsKey($sid) -and $st -eq "todo") { $st = $(if (@($wins | Where-Object { $_[0] -eq $sid -and $null -eq $_[2] }).Count) { "now" } else { "done" }) }
  $row = [ordered]@{ id = $sid; title = $c.title; short = $c.short; phase = $c.phase; status = $st; elapsedSeconds = $el[$sid]
    costUsd = $(if ($rs.Count) { Sum $rs "costUsd" } else { $null })
    tokens = $(if ($rs.Count -and -not $copilot) { (Sum $rs "input") + (Sum $rs "output") + (Sum $rs "cacheWrite") + (Sum $rs "cacheRead") } else { $null })
    credits = $(if ($rs.Count -and $copilot) { Sum $rs "aiCredits" } else { $null }) }
  foreach ($k in "stage","kind","objectId","shippedIn","remediation") { if ($c.Contains($k) -and $c[$k]) { $row[$k] = $c[$k] } }
  $row })
$cur = $steps | Where-Object { $_.status -eq "now" } | Select-Object -First 1

# ---- totals ----
$tot = [ordered]@{ costUsd = $(if ($rows.Count) { Sum $rows "costUsd" } else { $null }); elapsedSeconds = $(if ($el.Count) { $unionSec } else { $null }) }
# a row the usage script could not price (no rate for its model in pricing.json) must never read as $0
$unpriced = @($rows | Where-Object { $null -eq $_.costUsd -and ([double]($_.input ?? 0) + [double]($_.output ?? 0) + [double]($_.aiCredits ?? 0)) -gt 0 } | ForEach-Object { $_.model ?? "unknown" } | Sort-Object -Unique)
$outside = @($rows | Where-Object { "$($_.step)" -like "Unattributed*" }); $oc = $(if ($outside.Count) { Sum $outside "costUsd" } else { 0.0 }); if ($outside.Count -and $oc -gt 0) { $notes += ('$' + $oc.ToString("0.00") + " of the cost fell outside every step window — before the first window's session or after the last window closed — and is in the total but on no row") }
if ($unpriced.Count) { $tot.costUnpriced = $unpriced; $notes += ("price unknown for " + ($unpriced -join ", ") + " — the usage script fetches Anthropic's published rates itself at each measurement; if this stays, the machine is offline or the model's publisher is not covered (Ops § Usage & Cost → 3)") }
$seen = @{}; $d = 0; $t = 0; foreach ($r in $rows) { if ($seen.ContainsKey("$($r.step)")) { continue }; $seen["$($r.step)"] = 1; $d += [int]($r.decisions ?? 0); $t += [int]($r.turns ?? 0) }
$tot.decisions = $d; $tot.turns = $t
if ($copilot) { $tot.credits = $(if ($rows.Count) { [Math]::Round((Sum $rows "aiCredits"), 1) } else { $null }); $tot.creditsOpen = [bool](@($uj.sessions | Where-Object { -not $_.closed }).Count) }
else { $tk = [ordered]@{}; foreach ($k in "input","output","cacheWrite","cacheRead") { $tk[$k] = Sum $rows $k }; $tk.total = ($tk.input + $tk.output + $tk.cacheWrite + $tk.cacheRead); $tot.tokens = $(if ($rows.Count) { $tk } else { $null }) }
if ($liveState) { $ag = 0.0; $hu = 0.0; $wa = 0.0; foreach ($v in $liveState.perStep.Values) { $ag += $v.agent; $hu += $v.human; $wa += $v.waiting }
  $ssum = $ag + $hu + $wa; $kf = $(if ($ssum -gt 0 -and $tot.elapsedSeconds) { $tot.elapsedSeconds / $ssum } else { 1.0 })  # scaled once more to the union, so the three add up to Elapsed exactly
  $tot.agentSeconds = $ag * $kf; $tot.humanSeconds = $hu * $kf; $tot.waitingSeconds = $wa * $kf }
$current = [ordered]@{}
if ($cur) { $ps = if ($liveState -and $liveState.perStep.ContainsKey($cur.id)) { $liveState.perStep[$cur.id] } else { $null }; $gateC = ($catalog | Where-Object { $_.id -eq $cur.id } | Select-Object -First 1).exitGate
  $current = [ordered]@{ id = $cur.id; title = $cur.title; phase = $cur.phase; exitGate = @($gateC); stage = $(if ($cur.Contains("stage")) { $cur.stage } else { $null }); totals = [ordered]@{ costUsd = $cur.costUsd; elapsedSeconds = $cur.elapsedSeconds; agentSeconds = $(if ($ps) { $ps.agent }); humanSeconds = $(if ($ps) { $ps.human }); waitingSeconds = $(if ($ps) { $ps.waiting }); tokens = $cur.tokens; credits = $cur.credits } } }

# ---- models ----
$agg = [ordered]@{}
foreach ($r in $rows) { $k = "$($r.model ?? 'unknown')|$($r.role ?? '')"; if (-not $agg.Contains($k)) { $agg[$k] = [ordered]@{ model = ($r.model ?? "unknown"); role = ($r.role ?? ""); tokens = 0.0; credits = 0.0; costUsd = 0.0 } }
  $agg[$k].tokens += [double]($r.input ?? 0) + [double]($r.output ?? 0) + [double]($r.cacheWrite ?? 0) + [double]($r.cacheRead ?? 0); $agg[$k].credits += [double]($r.aiCredits ?? 0); $agg[$k].costUsd += [double]($r.costUsd ?? 0) }
$models = @($agg.Values | Sort-Object { -($(if ($copilot) { $_.credits } else { $_.tokens })) } | Select-Object -First 6)

# ---- roles ----
$rl = @()
foreach ($pair in @(@("Main",$null),@("Light","light"),@("Reasoning","reasoning"),@("Generator","generator"))) { $role = $pair[0]; $key = $pair[1]; $model = $null; $effort = $null
  if ($key) { foreach ($p in @("$root/.claude/agents/ocpf-$key.md", "$root/.github/agents/ocpf-$key.agent.md")) { $txt = Read-Text $p; if ($txt) { if ($txt -match '(?m)^model:\s*(.+)$') { $model = $Matches[1].Trim().Trim("'", '"') }; if ($txt -match '(?m)^(?:effort|reasoningEffort):\s*(.+)$') { $effort = $Matches[1].Trim().Trim("'", '"') }; if ($model) { break } } } }
  $rl += [ordered]@{ role = $role; model = $model; effort = $effort; status = "idle" } }
$main = $rl[0]; $gen = $rl[3]
if (-not $main.model -and $gen.model) { $main.model = $gen.model; $main.effort = $gen.effort }
if (-not $main.model -and $copilot -and $uj.sessions) { $ms = @(foreach ($x in $uj.sessions) { @($x.models) }); if ($ms.Count) { $main.model = $ms[-1] } }
if (-not $main.model -and $models.Count) { $main.model = $models[0].model }
if ($liveState) { if (-not $main.model) { $main.model = $liveState.main.model }; $main.status = $(if ($liveState.main.state -eq "working") { "working" } else { "idle" }); if ($liveState.main.text) { $main.detail = $liveState.main.text.Substring(0, [Math]::Min(90, $liveState.main.text.Length)) }
  # every sub-agent is matched to a role by model; a role shows how many of its sub-agents run right now (runningCount)
  foreach ($r in $rl) { if ($r.role -notin "Reasoning","Light","Generator" -or -not $r.model) { continue }
    $ms = @($liveState.subs | Where-Object { $_.model -and ("$($_.model)" -like "*$($r.model)*" -or "$($r.model)" -like "*$($_.model)*") }); $run = @($ms | Where-Object { $_.running })
    if ($run.Count) { $r.status = "running"; $r.runningSeconds = ($run | ForEach-Object { $_.seconds } | Measure-Object -Maximum).Maximum; $r.runningCount = $run.Count; $r.lastDetail = $null }
    elseif ($ms.Count) { $r.lastDetail = "returned " + (($ms | ForEach-Object { $_.last } | Measure-Object -Maximum).Maximum).ToLocalTime().ToString("HH:mm") } } }
foreach ($r in $rl) { if ($r.model) { $mm = $models | Where-Object { $_.model -and ("$($_.model)" -like "*$($r.model)*" -or "$($r.model)" -like "*$($_.model)*") } | Select-Object -First 1; if ($mm) { $r.tokens = $mm.tokens; $r.credits = [Math]::Round($mm.credits, 1) } } }
if ($gen.model -and $main.model -and $gen.model -eq $main.model) { $gen.Remove("tokens"); $gen.Remove("credits"); $gen.detail = "same model as Main; its usage is counted in Main's row" }
if ($edition -eq "feature") { $rl = @($rl | Where-Object { $_.role -eq "Main" }) }  # one model does everything on this journey
$waiting = Load-Json (Join-Path $stateDir "waiting.json") $null
if ($waiting -and $waiting.clearedAt) { $waiting = $null }
if ($waiting) { $main.status = "waiting on you"; $main.detail = "$($waiting.question)".Substring(0, [Math]::Min(90, "$($waiting.question)".Length)) }
# The project's state (v5.9.5.0): completed / waiting / testing / working / idle — a finished project no longer shows Main working forever.
if ($liveState -and $liveState.main.lastAt) { $main.lastAt = $liveState.main.lastAt }
$starts = @(foreach ($s in @($usage.steps)) { $t = Parse-Ts $s.startedAt; if ($t) { $t } })
if ($closedAt -and @($starts | Where-Object { $_ -gt $closedAt }).Count) { $closedAt = $null }  # a window opened after the close: back in work
$catIds = @($catalog | ForEach-Object { $_.id })
$reopened = (($null -ne (Parse-Ts $usage.projectClosedAt)) -and ($null -eq $closedAt)) -or (@($wins | Where-Object { $null -eq $_[2] -and $_[0] -notin $catIds }).Count -gt 0)  # …or a feature session's window open in a finished host (Case A): the last row stays Completed, the project is still back in work
$base = @($catalog | Where-Object { -not $_.remediation })  # a remediation row (07a, STEP-5a) opened from the release test must not displace the last step
$lastId = $(if ($base.Count -and $edition -ne "feature") { $base[-1].id } else { $null })
$lastDone = $false; if ($lastId -and -not $reopened) { $ls = $steps | Where-Object { $_.id -eq $lastId } | Select-Object -First 1; $lastDone = ($ls -and $ls.status -eq "done") }
$pSince = $null; $pState = "idle"
if ($closedAt -or $lastDone) { $pState = "completed"; $pSince = $closedAt; foreach ($s in $steps) { if ($s.status -eq "now") { $s.status = "done" } }; $cur = $null; $current = [ordered]@{}; if (-not $pSince) { $ends = @($wins | Where-Object { $_[2] } | ForEach-Object { $_[2] }); if ($ends.Count) { $pSince = ($ends | Measure-Object -Maximum).Maximum } }
  foreach ($r in $rl) { $r.status = $(if ($r.role -eq "Main") { "finished" } else { "idle" }); foreach ($k in @("runningCount","runningSeconds","lastDetail","detail","lastAt")) { $r.Remove($k) } } }
elseif ($waiting) { $pState = "waiting"; $pSince = Parse-Ts $waiting.since }
elseif ($cur -and $lastId -and $cur.id -eq $lastId -and $main.status -ne "working") { $pState = "testing"; $ws = @($wins | Where-Object { $_[0] -eq $cur.id } | ForEach-Object { $_[1] }); if ($ws.Count) { $pSince = ($ws | Measure-Object -Maximum).Maximum }; $main.status = "waiting on you"; $main.detail = "release testing — tell the agent how it went" }
elseif ($main.status -eq "working") { $pState = "working" }
$projState = [ordered]@{ state = $pState; since = $(if ($pSince) { $pSince.ToString("o") } else { $null }); closedAt = $(if ($closedAt) { $closedAt.ToString("o") } else { $null }); lastStep = $lastId }

# ---- estimate ----
$est = $null
if ($cur -and $edition -ne "feature") { $etxt = Read-Text (Join-Path $root "docs/2-design/AiEffortEstimate.md")
  if ($etxt) { $tokT = 0.0; $cred = 0.0; $hit = $false
    function NumE($s) { $s = ("$s" -replace ',', '').Trim().ToLower(); if ($s -match '^([0-9.]+)\s*([km]?)') { $v = [double]$Matches[1]; if ($Matches[2] -eq 'm') { $v * 1e6 } elseif ($Matches[2] -eq 'k') { $v * 1e3 } else { $v } } else { 0.0 } }
    foreach ($line in $etxt -split "`n") { $cells = @(($line.Trim().Trim('|')) -split '\|' | ForEach-Object { $_.Trim() }); if ($cells.Count -lt 6 -or $cells[0].Trim('*') -ne $cur.id) { continue }; $hit = $true; $tokT += (NumE $cells[2]) + (NumE $cells[3]) + (NumE $cells[4]) + (NumE $cells[5]); if ($cells.Count -ge 8) { $cred += NumE $cells[7] } }
    $est = if ($hit) { [ordered]@{ estimated = $(if ($copilot) { $cred } else { $tokT }); unit = $(if ($copilot) { "credits" } else { "tokens" }); used = ($(if ($copilot) { $cur.credits } else { $cur.tokens }) ?? 0) } } else { [ordered]@{ note = "No estimate row for step $($cur.id)" } } } }

# ---- events ----
$events = @(); if (Test-Path $evPath) { $lines = @(Get-Content $evPath | Select-Object -Last 12); foreach ($l in $lines) { try { $o = $l | ConvertFrom-Json -AsHashtable } catch { continue }; $ts = Parse-Ts $o.at; $events += [ordered]@{ time = $(if ($ts) { $ts.ToLocalTime().ToString("HH:mm") } else { "" }); who = $o.who; text = $o.text } }; [array]::Reverse($events) }

$priceSrc = if ($copilot) { $pricing.aiCredit.source } else { (@($pricing.perMillionTokens.Values | ForEach-Object { $_.source } | Where-Object { $_ } | Sort-Object -Unique) -join ", ") }
$dj0 = Load-Json (Join-Path $stateDir "dashboard.json") @{}
$isLive = $false; if ($Live.IsPresent) { $isLive = $true } elseif ($dj0.hooks -eq $true) { $isLive = $true }
$data = [ordered]@{ generatedAt = (NowUtc).ToString("o"); refreshSeconds = $Refresh; tool = $tool; live = $isLive
  renderer = "ocpf-dashboard.ps1"; app = $appFacts; framework = [ordered]@{ edition = $edition; version = $fw.runbookVersion; alMcp = $(if ($fw.alMcp) { "connected" } else { "unknown" }) }
  phases = $phases; steps = $steps; current = $current; totals = $tot; estimate = $est; models = $models; roles = $rl; waiting = $waiting; project = $projState; events = $events
  pricing = [ordered]@{ source = $priceSrc; fetchedAt = $pricing.fetchedAt; usdPerCredit = $pricing.aiCredit.usd }; notes = $notes; toast = $Toast }

# ---- render ----
# Every theme is rendered on every run; `theme` in dashboard.json only says which page -Open opens.
$THEMES = [ordered]@{ brand = @("dashboard.html", "ProjectDashboard.html"); f1 = @("dashboard-f1.html", "ProjectDashboard-f1.html") }
# -Open always opens the OnlyBCFans page; the F1 page opens only when -Theme f1 is passed on this very call (v5.6.0.0).
$themeKey = "$Theme".ToLower(); if (-not $THEMES.Contains($themeKey)) { $themeKey = "brand" }
$data.dataUrl = "ocpfFramework/state/dashboard-data.js"  # the pages pull this sidecar and repaint in place (no full reload)
$outs = @{}; $firstPayload = $null
foreach ($k in $THEMES.Keys) { $tplName = $THEMES[$k][0]; $outName = $THEMES[$k][1]
  $tpl = $null; foreach ($c in @((Join-Path $here "../templates/$tplName"), (Join-Path $root "ocpfFramework/scripts/$tplName"))) { if (Test-Path $c) { $tpl = Get-Content $c -Raw; break } }
  if (-not $tpl) { if ($k -eq "brand") { Write-Error "dashboard.html template not found beside the script (templates/dashboard.html) or in ocpfFramework/scripts/"; exit 1 }; continue }
  $data.theme = $k
  $payload = ($data | ConvertTo-Json -Depth 8 -Compress) -replace '</', '<\/'
  if ($null -eq $firstPayload) { $firstPayload = $payload }
  $o = Join-Path $root $outName  # project root: tracked, beside ProjectProgress.md
  [IO.File]::WriteAllText("$o.tmp", $tpl.Replace('/*__OCPF_DATA__*/null', $payload), [Text.UTF8Encoding]::new($false)); Move-Item -Force "$o.tmp" $o; $outs[$k] = $o }
$out = $outs[$themeKey]; if (-not $out) { $out = $outs["brand"] }
$side = Join-Path $stateDir "dashboard-data.js"; [IO.File]::WriteAllText("$side.tmp", "window.__ocpfData=$firstPayload;", [Text.UTF8Encoding]::new($false)); Move-Item -Force "$side.tmp" $side
if ($Open) { try { if ($IsMacOS) { & open $out } elseif ($IsWindows) { Start-Process $out } else { & xdg-open $out } } catch { } }
if (-not $Quiet) { $out; foreach ($n in $notes) { Write-Host "note: $n" } }
} catch { if ($Quiet) { exit 0 }; throw }
