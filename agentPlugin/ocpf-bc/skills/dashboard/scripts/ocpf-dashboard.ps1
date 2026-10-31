# OCPF BC Agentic Development Framework — the live dashboard renderer, PowerShell port.
# Renders ProjectDashboard.html (project root, tracked in git - never under the ignored ocpfFramework/state/)
# for one project from the state the framework already keeps
# (app.json, framework.json, usage.json, ProjectProgress.md — the step table, or Build-a-Feature's feature table — the step files, pricing.json, waiting.json,
# the sub-agent definitions, the usage script's -Json output, and — in Claude Code — the transcripts; for the View Project Documents
# popup also docs/** and requirements/** as per-document sidecars under state/docs/ and the sign-off lines, and outputAppPackage/ for the completed box's download).
# Mirrors ocpf-dashboard.py (the Python script is the reference implementation); exercised on PowerShell 7
# on macOS; needs PowerShell 7 (pwsh) on every OS, and the dashboard skill's hook proof (Ops § Dashboard → 3) is what proves it on each machine. Internal variables avoid the parameter names (names are case-insensitive).
#   pwsh ocpf-dashboard.ps1 -Project <root> [-Open] [-Quiet] [-Refresh 30] [-Toast "text"] [-Live]
#   pwsh ocpf-dashboard.ps1 -Project <root> -WaitingJson '<hook input>'    # a question opened
#   pwsh ocpf-dashboard.ps1 -Project <root> -ClearWaiting                   # it was answered
#   pwsh ocpf-dashboard.ps1 -Project <root> -WaitingJson - -Throttle 45      # Copilot preToolUse (every tool): the hook input on stdin
#   pwsh ocpf-dashboard.ps1 -Project <root> -ClearWaiting -HookJson - -Throttle 45   # Copilot postToolUse (every tool): stdin
#     Copilot's hooks have no matcher: the input carries toolName and toolArgs, and the script acts only when toolName
#     matches ask_user|askQuestions; any other tool is an ordinary render, throttled.
#   pwsh ocpf-dashboard.ps1 -Project <root> -CloseProject                   # the human said Done: completed state, clocks stopped
#   pwsh ocpf-dashboard.ps1 -Project <root> -Event who,text                 # append a feed event
param(
  [string]$Project = ".", [switch]$Open, [switch]$Quiet, [int]$Refresh = 30, [string]$Toast, [switch]$Live,
  [string]$WaitingJson, [switch]$ClearWaiting, [string]$HookJson, [switch]$CloseProject, [string[]]$Event, [int]$Throttle = 0, [string]$Theme
)
$ErrorActionPreference = "Stop"
try {
$root = (Resolve-Path $Project).Path
$stateDir = Join-Path $root "ocpfFramework/state"
if (-not (Test-Path -LiteralPath (Join-Path $root "ocpfFramework"))) { if ($Quiet) { exit 0 }; Write-Error "$root has no ocpfFramework/ folder — not an OCPF project"; exit 1 }
New-Item -ItemType Directory -Force -Path $stateDir | Out-Null
# Hook input. Claude Code's hooks are matched on the tool name by the harness (matcher AskUserQuestion), so the input is the
# question itself. Copilot's hooks (CLI and Chat) have no matcher: every tool call arrives, as {"toolName", "toolArgs", ...},
# and the script decides — ask_user / askQuestions record or clear the question; any other tool is a plain render, throttled.
function Read-HookInput($v) { if ($v -eq "-") { $v = ($input | Out-String); if (-not $v.Trim()) { try { $v = [Console]::In.ReadToEnd() } catch { } } }
  try { $o = $v | ConvertFrom-Json -AsHashtable } catch { $o = @{} }; if ($o -is [hashtable]) { $o } else { @{} } }
function Tool-Matches($inp) { $name = $inp.toolName; if ($name -isnot [string]) { return $null }; [bool]([regex]::IsMatch($name, 'ask_user|askQuestions|AskUserQuestion')) }  # Claude Code's input carries tool_name, matched by the harness already: never filtered here
$wInp = $null; if ($WaitingJson) { $wInp = Read-HookInput $WaitingJson; if ((Tool-Matches $wInp) -eq $false) { $WaitingJson = ""; $wInp = $null } }
if ($ClearWaiting -and $HookJson) { $cInp = Read-HookInput $HookJson; if ((Tool-Matches $cInp) -eq $false) { $ClearWaiting = $false } }
if ($Throttle -gt 0 -and -not ($WaitingJson -or $ClearWaiting -or $Event -or $Open -or $CloseProject)) { $pg = Join-Path $root "ProjectDashboard.html"; if ((Test-Path -LiteralPath $pg) -and (((Get-Date) - (Get-Item -LiteralPath $pg).LastWriteTime).TotalSeconds -lt $Throttle)) { exit 0 }; if ((Test-Path -LiteralPath "$pg.tmp") -and (((Get-Date) - (Get-Item -LiteralPath "$pg.tmp").LastWriteTime).TotalSeconds -lt 120)) { exit 0 } }
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
function Load-Json($p, $d) { if (Test-Path -LiteralPath $p) { try { Get-Content -LiteralPath $p -Raw | ConvertFrom-Json -AsHashtable } catch { $d } } else { $d } }
function Read-Text($p) { if (Test-Path -LiteralPath $p) { try { Get-Content -LiteralPath $p -Raw } catch { "" } } else { "" } }  # -LiteralPath: a name may hold [ ]; an unreadable file reads as empty, like the Python twin's read()
function Parse-Ts($s) { if (-not $s) { return $null }; if ($s -is [datetime]) { return $s.ToUniversalTime() }; try { return ([datetimeoffset]::Parse($s)).UtcDateTime } catch { return $null } }
function NowUtc { [datetime]::UtcNow }
function Iso($d) { $d.ToString("yyyy-MM-ddTHH:mm:ssZ") }
$FULL = @(@("PRE-01","DEFINE"),@("PRE-02","DEFINE"),@("01","DEFINE"),@("02","DESIGN"),@("03","DESIGN"),@("04","DESIGN"),@("05","BUILD"),@("06","BUILD"),@("07","BUILD"),@("08","PROVE"),@("09","PROVE"),@("10","PROVE"),@("11","PROVE"),@("12","PROVE"))
$LITE = @(@("STEP-1","DEFINE"),@("STEP-2","DESIGN"),@("STEP-3","BUILD"),@("STEP-4","BUILD"),@("STEP-5","BUILD"),@("STEP-6","PROVE"),@("STEP-7","PROVE"))
$FULL_PHASES = @("DEFINE","DESIGN","BUILD","PROVE")
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
function Add-Event($who, $text) { ([ordered]@{ at = (Iso (NowUtc)); who = $who; text = $text } | ConvertTo-Json -Compress) | Add-Content -LiteralPath $evPath -Encoding utf8 }
if ($null -ne $wInp) {
  $inp = $wInp
  $ti = if ($inp.tool_input) { $inp.tool_input } elseif ($inp.toolInput) { $inp.toolInput } elseif ($inp.toolArgs) { $inp.toolArgs } else { $inp }
  if ($ti -is [string]) { try { $ti = $ti | ConvertFrom-Json -AsHashtable } catch { $ti = @{} } }  # Copilot may pass toolArgs as a JSON string
  if ($ti -isnot [hashtable]) { $ti = @{} }
  $qs = @(); if ($ti.questions) { $qs = @($ti.questions) } elseif ($ti.question) { $qs = @($ti) }
  if (-not $qs.Count -and ($ti.message -or $ti.requestedSchema)) {  # Copilot CLI ask_user: one question, its options the enum of the first property
    $props = $(if ($ti.requestedSchema -is [hashtable] -and $ti.requestedSchema.properties -is [hashtable]) { $ti.requestedSchema.properties } else { @{} })
    $first = @{}; foreach ($pv in $props.Values) { if ($pv -is [hashtable]) { $first = $pv; break } }
    $qs = @(@{ question = ($ti.message ?? $first.title ?? $first.description); options = @(foreach ($e in @($first.enum)) { @{ label = "$e" } }) }) }
  if ($qs.Count) { $q = $qs[0]
    $opts = @(foreach ($o in @($q.options)) { if ($o -is [hashtable]) { [ordered]@{ label = ($o.label ?? $o.title ?? "$o"); description = ($o.description ?? "") } } else { [ordered]@{ label = "$o"; description = "" } } })
    $w = [ordered]@{ since = (Iso (NowUtc)); question = ($q.question ?? $q.header ?? "A question is waiting"); options = $opts; count = $qs.Count }
    $w | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $stateDir "waiting.json") -Encoding utf8
    Add-Event "Agent" ("asked: " + "$($w.question)".Substring(0, [Math]::Min(80, "$($w.question)".Length))) }
}
if ($ClearWaiting) { $wp = Join-Path $stateDir "waiting.json"; if (Test-Path -LiteralPath $wp) { $w = Load-Json $wp @{}; $w["clearedAt"] = Iso (NowUtc); $w | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $wp -Encoding utf8; Add-Event "You" "answered" } }
if ($Event -and $Event.Count -ge 2) { Add-Event $Event[0] $Event[1] }
# The human said the project is done (v5.9.5.0): stamp projectClosedAt, close every open window there, log it.
$mk0 = Load-Json (Join-Path $root "ocpfFramework/framework.json") @{}
if ($CloseProject -and "$($mk0.edition)".ToLower() -ne "feature") { Add-Event "Agent" "-CloseProject ignored — a Full or Lite project closes at its last step (Ops § Dashboard → 6)"; $CloseProject = $false }  # a Build-a-Feature run inside a Full or Lite project never closes the host
if ($CloseProject) { $up = Join-Path $stateDir "usage.json"; $u = Load-Json $up @{}; if (-not $u.projectClosedAt) { $u["projectClosedAt"] = Iso (NowUtc) }
  foreach ($s in @($u.steps)) { if ($s.startedAt -and -not $s.completedAt) { $s["completedAt"] = $u.projectClosedAt } }
  $u | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $up -Encoding utf8; Add-Event "You" "closed the project — completed" }
if ($Live -or $Theme) { $dj = Load-Json (Join-Path $stateDir "dashboard.json") @{}; if ($Live) { $dj["hooks"] = $true }; if ($Theme) { $dj["theme"] = $Theme.ToLower() }; if (-not $dj.theme) { $dj["theme"] = "brand" }; $dj | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $stateDir "dashboard.json") -Encoding utf8 }

# ---- facts ----
$fw = Load-Json (Join-Path $root "ocpfFramework/framework.json") @{}
$usage = Load-Json (Join-Path $stateDir "usage.json") @{}
$tool = if ($usage.aiTool) { $usage.aiTool } elseif ("$($fw.placedAs)" -like "*copilot-instructions*") { "copilot-chat" } else { "claude-code" }
$copilot = $tool -like "copilot*"
$edition = if ($fw.edition) { "$($fw.edition)".ToLower() } elseif (Test-Path -LiteralPath (Join-Path $root "ocpfFramework/runbookSteps/STEP-1.md")) { "lite" } else { "full" }
$app = Load-Json (Join-Path $root "app.json") @{}
$icon = $null
if ($app.logo -and (Test-Path -LiteralPath (Join-Path $root $app.logo))) { $bytes = [IO.File]::ReadAllBytes((Join-Path $root $app.logo)); if ($bytes.Length -lt 400000) { $ext = ([IO.Path]::GetExtension($app.logo)).TrimStart('.').ToLower(); if (-not $ext) { $ext = "png" }; if ($ext -in "jpg","jpeg") { $ext = "jpeg" }; $icon = "data:image/$ext;base64," + [Convert]::ToBase64String($bytes) } }
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
    $usage | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $stateDir "usage.json") -Encoding utf8
    foreach ($w in $wins) { if ($null -eq $w[2]) { $w[2] = $closedAt } }
    Add-Event "Agent" "$lastBase is Completed in ProjectProgress.md — project closed, clocks stopped"
  }
}
# ---- usage rows via the usage script ----
$notes = @(); $uj = $null
if ($wins.Count) {
  $script = Join-Path $here "ocpf-usage.ps1"
  if (-not (Test-Path -LiteralPath $script)) { foreach ($c in @((Join-Path $root "ocpfFramework/scripts/ocpf-usage.ps1"), (Join-Path $here "../../usage/scripts/ocpf-usage.ps1"))) { if (Test-Path -LiteralPath $c) { $script = $c; break } } }
  if (Test-Path -LiteralPath $script) { try { $out = & pwsh -NoProfile -File $script -Project $root -Json 2>&1; $uj = ($out | Out-String) | ConvertFrom-Json -AsHashtable } catch { $notes += "usage: $_" } } else { $notes += "usage script not found beside the dashboard script" }
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
    foreach ($f in @(Get-ChildItem -LiteralPath $tdir0 -Filter *.jsonl -ErrorAction SilentlyContinue)) { $lo = $null; $hi = $null
      foreach ($line in [IO.File]::ReadLines($f.FullName)) { $i = $line.IndexOf('"timestamp":"'); if ($i -lt 0) { continue }; $ts = Parse-Ts ($line.Substring($i + 13, [Math]::Min(24, $line.Length - $i - 13)).Split('"')[0]); if (-not $ts) { continue }; if ($null -eq $lo -or $ts -lt $lo) { $lo = $ts }; if ($null -eq $hi -or $ts -gt $hi) { $hi = $ts } }
      if ($lo -and $hi) { $spans += ,@($lo, $hi) } } }
  $w0 = $wins[0]; $hits = @(foreach ($sp in $spans) { if ($sp[0] -le $w0[1] -and $w0[1] -le $sp[1] -and $sp[0] -lt $w0[1]) { $sp[0] } })
  if ($hits.Count) { $s0 = ($hits | Sort-Object)[0]; $wins[0] = @($w0[0], $s0, $w0[2]); $notes += "$($w0[0]) starts at the session's first event ($($s0.ToLocalTime().ToString('HH:mm'))), before its recorded startedAt" }
}
$phases = $FULL_PHASES; $status = @{}
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
  $files = @(@(Get-ChildItem -LiteralPath $tdir -Filter *.jsonl -ErrorAction SilentlyContinue) + @(Get-ChildItem -LiteralPath $tdir -Directory -ErrorAction SilentlyContinue | ForEach-Object { Join-Path $_.FullName "subagents" } | Where-Object { Test-Path -LiteralPath $_ } | ForEach-Object { Get-ChildItem -LiteralPath $_ -Filter *.jsonl -ErrorAction SilentlyContinue }) | Sort-Object LastWriteTime)
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
$events = @(); if (Test-Path -LiteralPath $evPath) { $lines = @(Get-Content -LiteralPath $evPath | Select-Object -Last 12); foreach ($l in $lines) { try { $o = $l | ConvertFrom-Json -AsHashtable } catch { continue }; $ts = Parse-Ts $o.at; $events += [ordered]@{ time = $(if ($ts) { $ts.ToLocalTime().ToString("HH:mm") } else { "" }); who = $o.who; text = $o.text } }; [array]::Reverse($events) }

$priceSrc = if ($copilot) { $pricing.aiCredit.source } else { (@($pricing.perMillionTokens.Values | ForEach-Object { $_.source } | Where-Object { $_ } | Sort-Object -Unique) -join ", ") }
$dj0 = Load-Json (Join-Path $stateDir "dashboard.json") @{}
$isLive = $false; if ($Live.IsPresent) { $isLive = $true } elseif ($dj0.hooks -eq $true) { $isLive = $true }
$data = [ordered]@{ generatedAt = (NowUtc).ToString("o"); refreshSeconds = $Refresh; tool = $tool; live = $isLive
  renderer = "ocpf-dashboard.ps1"; app = $appFacts; framework = [ordered]@{ edition = $edition; version = $fw.runbookVersion; alMcp = $(if ($fw.alMcp) { "connected" } else { "unknown" }) }
  phases = $phases; steps = $steps; current = $current; totals = $tot; estimate = $est; models = $models; roles = $rl; waiting = $waiting; project = $projState; events = $events
  pricing = [ordered]@{ source = $priceSrc; fetchedAt = $pricing.fetchedAt; usdPerCredit = $pricing.aiCredit.usd }; notes = $notes; toast = $Toast }

# ---- documents, approvals, package ----
# Mirrors the Python block of the same name: the same regexes in the same order, so both twins write the same HTML into
# ocpfFramework/state/docs/<slug>.js (window.__ocpfDoc = {...}) and the same index into dashboard-data.js. Case-sensitive
# operators throughout ([regex] statics, -ceq, -cin): PowerShell's -match / -replace would silently differ from Python.
$CONV = 4  # converter version; bump with the Python twin when the converter or the slug changes (4: injective slugs, URL-safe link paths that keep an author's %XX)
$DOC_EXT = @(".md", ".txt", ".docx", ".xlsx", ".pdf", ".png", ".jpg", ".jpeg", ".svg")
$DOC_SKIP = @("index.html", "build.py", "site.json", "template.html")  # html-docs' own files in docs/
$DOC_SKIP_DIRS = @("images", "assets", "screenshots")
$FOLDER_LABELS = @{ "0-project" = "Project"; "1-define" = "Define"; "2-design" = "Design"; "3-build" = "Build"; "4-prove" = "Prove"; "docs" = "Documents"; "requirements" = "Requirements"; "requirements/existing" = "Existing app" }
$PHASE_FOLDERS = @("0-project", "1-define", "2-design", "3-build", "4-prove")
$DOC_NAMES = @{ FRD = "FRD"; TDD = "TDD"; SanityCheck = "Sanity Check"; BuildPlan = "Build Plan"; DesignDoc = "Design Doc"; CodeReview = "Code Review"; PostDevTDD = "Post-dev TDD" }
$STEP_DOC = @{ "02" = "docs/2-design/FRD.md"; "03" = "docs/2-design/TDD.md"; "04" = "docs/2-design/SanityCheck.md"; "05" = "docs/3-build/BuildPlan.md"; "09" = "docs/4-prove/CodeReview.md"; "STEP-2" = "docs/2-design/DesignDoc.md" }
$FEATURE_STAGES = @("Asked", "Confirmed", "Built", "Compiled", "Documented", "Reviewed", "Packaged")
$CH1 = [string][char]1
$RE_LIST = '^([ \t]*)(?:[-*+]|\d+[.)])[ \t]+(.*)$'
$RE_HR = '^[ \t]*(?:-[ \t]*){3,}$|^[ \t]*(?:\*[ \t]*){3,}$|^[ \t]*(?:_[ \t]*){3,}$'
$RE_TSEP = '^[ \t]*\|?[ \t]*:?-{3,}:?[ \t]*(?:\|[ \t]*:?-{3,}:?[ \t]*)*\|?[ \t]*$'
function Doc-Slug($p) {  # the path with every run outside [A-Za-z0-9_-] as one '-', plus six hex digits of the path's SHA-256: injective, URL-safe, a safe file name (same string as the Python twin)
  $sha = [Security.Cryptography.SHA256]::Create(); try { $hex = (($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($p)) | ForEach-Object { $_.ToString("x2") }) -join "").Substring(0, 6) } finally { $sha.Dispose() }
  [regex]::Replace($p, '[^A-Za-z0-9_-]+', '-') + "-" + $hex }
function Href-Path($p) { [regex]::Replace("$p", '%(?![0-9A-Fa-f]{2})', '%25').Replace("#", "%23").Replace("?", "%3F").Replace(" ", "%20") }  # a valid %XX written by the author stays  # a project-relative path as a URL path; the text is already HTML-escaped, entities stay
function Read-Doc($p) { Read-Text $p }  # Get-Content -Raw already drops a BOM, which the Python twin strips itself
function Iso-Mtime($p) { (Get-Item -LiteralPath $p).LastWriteTimeUtc.ToString("yyyy-MM-ddTHH:mm:ssZ") }
function Esc-Html($s) { "$s".Replace("&", "&amp;").Replace("<", "&lt;").Replace(">", "&gt;") }
function Esc-Attr($s) { "$s".Replace('"', "&quot;") }
function Norm-Path($baseDir, $url) { $parts = [System.Collections.Generic.List[string]]::new(); foreach ($seg in "$baseDir/$url".Split('/')) { if ($seg -eq "" -or $seg -eq ".") { continue }; if ($seg -eq "..") { if ($parts.Count) { $parts.RemoveAt($parts.Count - 1) }; continue }; $parts.Add($seg) }; ($parts -join "/") }
function Heading-Id($text, $ids) { $t = [regex]::Replace($text, '<[^>]*>', ''); $t = [regex]::Replace($t, '&[a-z]+;|&#\d+;', ''); $t = [regex]::Replace($t.ToLowerInvariant(), '[^a-z0-9]+', '-').Trim('-'); if (-not $t) { $t = "section" }
  $n = 0; if ($ids.ContainsKey($t)) { $n = $ids[$t] }; $ids[$t] = $n + 1; if ($n -eq 0) { $t } else { "$t-$($n + 1)" } }
function Inline-Md($s, $docDir) {
  $codes = [System.Collections.Generic.List[string]]::new()
  $s = [regex]::Replace($s, '`([^`\n]+)`', [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $codes.Add($m.Groups[1].Value); $CH1 + "I" + ($codes.Count - 1) + $CH1 })
  $s = [regex]::Replace($s, '!\[([^\]]*)\]\(([^)\s]+)\)', [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $src = $m.Groups[2].Value; if (-not [regex]::IsMatch($src, '^(?:https?:|data:|/)')) { $src = Href-Path (Norm-Path $docDir $src) }; '<img alt="' + (Esc-Attr $m.Groups[1].Value) + '" src="' + (Esc-Attr $src) + '">' })  # a relative source resolves from the document's folder to the project root, like a link
  $s = [regex]::Replace($s, '\[([^\]]+)\]\(([^)\s]+)\)', [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $text = $m.Groups[1].Value; $url = $m.Groups[2].Value
      if ([regex]::IsMatch($url, '^https?://')) { return '<a href="' + (Esc-Attr $url) + '" target="_blank" rel="noopener">' + $text + '</a>' }
      if ($url.StartsWith("#") -or $url.StartsWith("mailto:") -or $url.StartsWith("/")) { return '<a href="' + (Esc-Attr $url) + '">' + $text + '</a>' }
      $anchor = ""; $hi = $url.IndexOf("#"); if ($hi -ge 0) { $anchor = $url.Substring($hi + 1); $url = $url.Substring(0, $hi) }
      $rel = Norm-Path $docDir $url
      if (($rel.StartsWith("docs/") -or $rel.StartsWith("requirements/")) -and $rel.ToLowerInvariant().EndsWith(".md")) { return '<a href="#doc=' + (Doc-Slug $rel) + $(if ($anchor) { "&amp;h=" + (Esc-Attr $anchor) } else { "" }) + '">' + $text + '</a>' }
      '<a href="' + (Esc-Attr ((Href-Path $rel) + $(if ($anchor) { "#" + $anchor } else { "" }))) + '" target="_blank">' + $text + '</a>' })
  $s = [regex]::Replace($s, '\*\*(.+?)\*\*', '<strong>$1</strong>')
  $s = [regex]::Replace($s, '(?<![\w*])\*([^*\n]+?)\*(?![\w*])', '<em>$1</em>')
  $s = [regex]::Replace($s, '~~(.+?)~~', '<del>$1</del>')
  $s = [regex]::Replace($s, $CH1 + 'I(\d+)' + $CH1, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) '<code>' + $codes[[int]$m.Groups[1].Value] + '</code>' })
  $s }
function Md-Cells($line) { $s = $line.Trim(); if ($s.StartsWith("|")) { $s = $s.Substring(1) }; if ($s.EndsWith("|") -and -not $s.EndsWith("\|")) { $s = $s.Substring(0, $s.Length - 1) }; @([regex]::Split($s, '(?<!\\)\|') | ForEach-Object { $_.Trim().Replace("\|", "|") }) }
function Md-ToHtml($text, $docPath) {
  # Markdown -> HTML, nothing but [regex]: headings with ids, paragraphs, bold / italic / code, fenced code (Mermaid as source),
  # lists one level deep with checkboxes, GFM tables, links (docs/ links become #doc= routes), blockquotes, rules, images.
  # The whole text is HTML-escaped first: a document is untrusted text, never passthrough HTML.
  $docDir = $(if ($docPath.Contains("/")) { $docPath.Substring(0, $docPath.LastIndexOf("/")) } else { "" })
  $text = Esc-Html ("$text".Replace("`r`n", "`n").Replace("`r", "`n"))
  $fences = [System.Collections.Generic.List[object]]::new()
  $text = [regex]::Replace($text, '(?ms)^[ \t]*```[ \t]*([\w+-]*)[^\n]*\n(.*?)^[ \t]*```[ \t]*$', [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $fences.Add(@($m.Groups[1].Value.Trim().ToLowerInvariant(), $m.Groups[2].Value)); $CH1 + "F" + ($fences.Count - 1) + $CH1 })
  $lines = $text.Split("`n"); $n = $lines.Count
  $out = [System.Collections.Generic.List[string]]::new(); $para = [System.Collections.Generic.List[string]]::new(); $bq = [System.Collections.Generic.List[string]]::new(); $lists = [System.Collections.Generic.List[string]]::new(); $ids = @{}
  $flushPara = { if ($para.Count) { $s = (@($para | ForEach-Object { $_.TrimStart() }) -join "`n"); $s = [regex]::Replace($s, ' {2,}\n', "<br>`n").Trim(); $out.Add("<p>" + (Inline-Md $s $docDir) + "</p>"); $para.Clear() } }
  $flushBq = { if ($bq.Count) { $sb = ""; foreach ($p in [regex]::Split(($bq -join "`n"), '\n[ \t]*\n')) { if ($p.Trim()) { $sb += "<p>" + (Inline-Md $p.Trim() $docDir) + "</p>" } }; $out.Add("<blockquote>" + $sb + "</blockquote>"); $bq.Clear() } }
  $closeLists = { param($to) while ($lists.Count -gt $to) { $tag = $lists[$lists.Count - 1]; $lists.RemoveAt($lists.Count - 1); $out.Add("</li></$tag>") } }
  $i = 0
  while ($i -lt $n) { $line = $lines[$i]
    if (-not $line.Trim()) { & $flushPara; & $flushBq; $j = $i + 1; while ($j -lt $n -and -not $lines[$j].Trim()) { $j++ }; if (-not ($j -lt $n -and [regex]::IsMatch($lines[$j], $RE_LIST))) { & $closeLists 0 }; $i++; continue }
    $m = [regex]::Match($line.Trim(), '^' + $CH1 + 'F(\d+)' + $CH1 + '$')
    if ($m.Success) { & $flushPara; & $flushBq; & $closeLists 0; $f = $fences[[int]$m.Groups[1].Value]; $lang = $f[0]; $body = $f[1]; if ($body.EndsWith("`n")) { $body = $body.Substring(0, $body.Length - 1) }
      $out.Add('<pre class="code"' + $(if ($lang) { ' data-lang="' + $lang + '"' } else { "" }) + '><code>' + $body + '</code></pre>'); $i++; continue }
    $m = [regex]::Match($line, '^(#{1,6})[ \t]+(.*?)[ \t]*#*[ \t]*$')
    if ($m.Success) { & $flushPara; & $flushBq; & $closeLists 0; $h = Inline-Md $m.Groups[2].Value $docDir; $lv = $m.Groups[1].Value.Length; $out.Add("<h$lv id=`"" + (Heading-Id $h $ids) + "`">" + $h + "</h$lv>"); $i++; continue }
    if ([regex]::IsMatch($line, $RE_HR)) { & $flushPara; & $flushBq; & $closeLists 0; $out.Add("<hr>"); $i++; continue }
    if ($line.TrimStart().StartsWith("|") -and $i + 1 -lt $n -and [regex]::IsMatch($lines[$i + 1], $RE_TSEP)) { & $flushPara; & $flushBq; & $closeLists 0
      $h = ""; foreach ($c in @(Md-Cells $line)) { $h += "<th>" + (Inline-Md $c $docDir) + "</th>" }; $out.Add("<table><thead><tr>" + $h + "</tr></thead><tbody>"); $i += 2
      while ($i -lt $n -and $lines[$i].TrimStart().StartsWith("|")) { $r = ""; foreach ($c in @(Md-Cells $lines[$i])) { $r += "<td>" + (Inline-Md $c $docDir) + "</td>" }; $out.Add("<tr>" + $r + "</tr>"); $i++ }
      $out.Add("</tbody></table>"); continue }
    $m = [regex]::Match($line, '^[ \t]*&gt;[ \t]?(.*)$')
    if ($m.Success) { & $flushPara; & $closeLists 0; $bq.Add($m.Groups[1].Value); $i++; continue }
    $m = [regex]::Match($line, $RE_LIST)
    if ($m.Success) { & $flushPara; & $flushBq
      $indent = $m.Groups[1].Value.Replace("`t", "    ").Length; $level = $(if ($indent -ge 2) { 1 } else { 0 })
      $tag = $(if ([regex]::IsMatch($line, '^[ \t]*\d')) { "ol" } else { "ul" })
      if ($level -gt $lists.Count) { $level = $lists.Count }
      if ($lists.Count -gt $level + 1) { & $closeLists ($level + 1) }
      if ($lists.Count -eq $level + 1) { if ($lists[$lists.Count - 1] -cne $tag) { & $closeLists $level } else { $out.Add("</li>") } }
      if ($lists.Count -eq $level) { $out.Add("<$tag>"); $lists.Add($tag) }
      $body = $m.Groups[2].Value; $t = [regex]::Match($body, '^\[([ xX])\][ \t]+')
      if ($t.Success) { $body = '<input type="checkbox" disabled' + $(if ($t.Groups[1].Value -cne " ") { " checked" } else { "" }) + '> ' + $body.Substring($t.Length) }
      $out.Add("<li>" + (Inline-Md $body $docDir)); $i++; continue }
    if ($lists.Count -and -not $para.Count -and -not $bq.Count) { $out[$out.Count - 1] = $out[$out.Count - 1] + " " + (Inline-Md $line.Trim() $docDir); $i++; continue }  # lazy continuation of the last item
    if ($bq.Count) { $bq.Add($line.Trim()); $i++; continue }
    $para.Add($line); $i++ }
  & $flushPara; & $flushBq; & $closeLists 0
  ($out -join "`n") }
$TEXT_CAP = 200000  # characters of source text a sidecar carries (Markdown, plain text, extracted office text alike)
$TRUNC_LINE = "<p><em>Text truncated at 200 KB — open the file itself for the rest.</em></p>"
function Xml-Text($s) { "$s".Replace("&lt;", "<").Replace("&gt;", ">").Replace("&quot;", '"').Replace("&apos;", "'").Replace("&amp;", "&") }
function Office-Html($path) {
  # docx / xlsx -> HTML by ZipFile + regex over the XML parts, capped at 200 KB of text
  $out = [System.Collections.Generic.List[string]]::new(); $st = @{ size = 0; cut = $false }; $cap = $TEXT_CAP
  $add = { param($s) if ($st.cut) { return }; $st.size += $s.Length; if ($st.size -gt $cap) { $st.cut = $true; return }; $out.Add($s) }
  try { $z = [System.IO.Compression.ZipFile]::OpenRead($path)
    try { $names = @($z.Entries | ForEach-Object { $_.FullName }); if ($names.Count) { [Array]::Sort($names, [System.StringComparer]::Ordinal) }
      $readEntry = { param($nm) $e = $z.GetEntry($nm); $sr = [IO.StreamReader]::new($e.Open(), [Text.Encoding]::UTF8); try { $sr.ReadToEnd() } finally { $sr.Dispose() } }
      if ($names -ccontains "word/document.xml") { $xml = & $readEntry "word/document.xml"
        foreach ($pm in [regex]::Matches($xml, '(?s)<w:p[ >].*?</w:p>')) { $t = ""; foreach ($tm in [regex]::Matches($pm.Value, '(?s)<w:t(?: [^>]*)?>(.*?)</w:t>')) { $t += $tm.Groups[1].Value }; if ($t.Trim()) { & $add ("<p>" + (Esc-Html (Xml-Text $t)) + "</p>") } } }
      else { $shared = [System.Collections.Generic.List[string]]::new()
        if ($names -ccontains "xl/sharedStrings.xml") { foreach ($si in [regex]::Matches((& $readEntry "xl/sharedStrings.xml"), '(?s)<si>(.*?)</si>')) { $t = ""; foreach ($tm in [regex]::Matches($si.Groups[1].Value, '(?s)<t(?: [^>]*)?>(.*?)</t>')) { $t += $tm.Groups[1].Value }; $shared.Add((Xml-Text $t)) } }
        $sheets = @($names | Where-Object { [regex]::IsMatch($_, '^xl/worksheets/sheet\d+\.xml$') }); $k = 0
        foreach ($sh in $sheets) { $k++; & $add "<h2>Sheet $k</h2><table><tbody>"
          foreach ($rm in [regex]::Matches((& $readEntry $sh), '(?s)<row[ >].*?</row>')) { $row = [regex]::Replace($rm.Value, '<c( [^>]*)?/>', '<c$1></c>'); $cells = ""; $any = $false
            foreach ($cm in [regex]::Matches($row, '(?s)<c( [^>]*)?>(.*?)</c>')) { $attrs = $cm.Groups[1].Value; $inner = $cm.Groups[2].Value; $vm = [regex]::Match($inner, '(?s)<v>(.*?)</v>'); $v = $(if ($vm.Success) { Xml-Text $vm.Groups[1].Value } else { "" })
              if ($attrs.Contains('t="s"') -and [regex]::IsMatch($v, '^\d+$') -and [int]$v -lt $shared.Count) { $v = $shared[[int]$v] }
              elseif ($attrs.Contains('t="inlineStr"')) { $t = ""; foreach ($tm in [regex]::Matches($inner, '(?s)<t(?: [^>]*)?>(.*?)</t>')) { $t += $tm.Groups[1].Value }; $v = Xml-Text $t }
              $cells += "<td>" + (Esc-Html $v) + "</td>"; $any = $true }
            if ($any) { & $add ("<tr>" + $cells + "</tr>") } }
          & $add "</tbody></table>" } } }
    finally { $z.Dispose() } }
  catch { return "<p><em>Could not extract text: " + (Esc-Html "$_") + "</em></p>" }
  if ($st.cut) { $out.Add($TRUNC_LINE) }
  ($out -join "`n") }
function Doc-Kind($name) { $ext = [IO.Path]::GetExtension($name).ToLowerInvariant(); if ($ext -eq ".md") { "markdown" } elseif ($ext -eq ".txt") { "text" } elseif ($ext -in ".docx", ".xlsx") { "extracted" } elseif ($ext -eq ".pdf") { "pdf" } else { "image" } }
function Doc-Title($path, $kind, $name) { if ($kind -eq "markdown") { foreach ($l in @((Read-Doc $path) -split "`r?`n" | Select-Object -First 40)) { $m = [regex]::Match($l, '^#[ \t]+(.+?)[ \t]*#*[ \t]*$'); if ($m.Success) { $t = [regex]::Replace($m.Groups[1].Value, '[`*_]', '').Trim(); if ($t) { return $t } else { return $name } } } }; $name }
function Write-DocSidecar($rel, $kind) {
  # ocpfFramework/state/docs/<slug>.js, rewritten only when the source is newer or the converter changed
  $src = Join-Path $root $rel; $slug = Doc-Slug $rel; $ddir = Join-Path $stateDir "docs"; $outp = Join-Path $ddir "$slug.js"
  New-Item -ItemType Directory -Force -Path $ddir | Out-Null
  if ((Test-Path -LiteralPath $outp) -and (Get-Item -LiteralPath $outp).LastWriteTimeUtc -ge (Get-Item -LiteralPath $src).LastWriteTimeUtc) { $head = ""; try { $sr = [IO.File]::OpenText($outp); $buf = [char[]]::new(80); $cnt = $sr.Read($buf, 0, 80); $head = [string]::new($buf, 0, $cnt); $sr.Dispose() } catch { }; if ($head.Contains('"conv":' + $CONV + ',')) { return $slug } }
  $name = [IO.Path]::GetFileName($rel)
  if ($kind -in "markdown", "text") { $text = "$(Read-Doc $src)"; $cut = $text.Length -gt $TEXT_CAP; if ($cut) { $text = $text.Substring(0, $TEXT_CAP) }
    $html = $(if ($kind -eq "markdown") { Md-ToHtml $text $rel } else { '<pre class="plain">' + (Esc-Html ($text.Replace("`r`n", "`n").Replace("`r", "`n"))) + '</pre>' }); if ($cut) { $html += "`n" + $TRUNC_LINE } }
  else { $html = Office-Html $src }
  $doc = [ordered]@{ conv = $CONV; slug = $slug; path = $rel; title = (Doc-Title $src $kind $name); kind = $kind; html = $html; renderedAt = (Iso (NowUtc)); bytes = (Get-Item -LiteralPath $src).Length }
  [IO.File]::WriteAllText("$outp.tmp", "window.__ocpfDoc=" + ($doc | ConvertTo-Json -Depth 3 -Compress) + ";", [Text.UTF8Encoding]::new($false)); Move-Item -Force -LiteralPath "$outp.tmp" -Destination $outp
  $slug }
function Docs-Index {
  # every document under docs/ (phase folders, other subfolders, the flat files) and requirements/ (depth 2), ordinal order
  $filesIn = { param($d) $fpath = Join-Path $root $d; if (-not (Test-Path -LiteralPath $fpath -PathType Container)) { return @() }
    $names = @(Get-ChildItem -LiteralPath $fpath -File -Force | Where-Object { -not $_.Name.StartsWith(".") -and $_.Name -cnotin $DOC_SKIP -and ([IO.Path]::GetExtension($_.Name).ToLowerInvariant() -in $DOC_EXT) } | ForEach-Object { $_.Name }); if ($names.Count) { [Array]::Sort($names, [System.StringComparer]::Ordinal) }; $names }
  $subdirs = { param($d) $fpath = Join-Path $root $d; if (-not (Test-Path -LiteralPath $fpath -PathType Container)) { return @() }
    $names = @(Get-ChildItem -LiteralPath $fpath -Directory -Force | Where-Object { -not $_.Name.StartsWith(".") -and $_.Name -cnotin $DOC_SKIP_DIRS } | ForEach-Object { $_.Name }); if ($names.Count) { [Array]::Sort($names, [System.StringComparer]::Ordinal) }; $names }
  $groups = [System.Collections.Generic.List[object]]::new()
  $docsSubs = @(& $subdirs "docs")
  foreach ($ph in $PHASE_FOLDERS) { if ($docsSubs -ccontains $ph) { $groups.Add(@($ph, "docs/$ph")) } }
  foreach ($d in $docsSubs) { if ($d -cnotin $PHASE_FOLDERS) { $groups.Add(@($d, "docs/$d")) } }
  $groups.Add(@("docs", "docs")); $groups.Add(@("requirements", "requirements"))
  foreach ($d in @(& $subdirs "requirements")) { $groups.Add(@("requirements/$d", "requirements/$d")) }
  $folders = @(); $count = 0; $keep = @{}; $skipped = @(); $seen = @{}
  foreach ($g in $groups) { $name = $g[0]; $d = $g[1]; $files = @()
    foreach ($fn in @(& $filesIn $d)) { $rel = "$d/$fn"; $kind = Doc-Kind $fn; $fpath = Join-Path $root $rel; $slug = Doc-Slug $rel; $sidecar = $null
      if ($seen.ContainsKey($slug)) { $skipped += "$rel (slug collides with $($seen[$slug]))"; continue }  # cannot happen with the hashed slug; said, never silent
      $seen[$slug] = $rel
      try {  # one unreadable or malformed file is skipped and named in docs.note — it never stops the render
        if ($kind -in "markdown", "text", "extracted") { $keep["$slug.js"] = 1; Write-DocSidecar $rel $kind | Out-Null; $sidecar = "ocpfFramework/state/docs/$slug.js" }  # kept even when this write fails: the last good sidecar still reads
        $files += [ordered]@{ path = $rel; title = (Doc-Title $fpath $kind $fn); slug = $slug; kind = $kind; bytes = (Get-Item -LiteralPath $fpath).Length; modifiedAt = (Iso-Mtime $fpath); sidecar = $sidecar } }
      catch { $msg = "$($_.Exception.Message)" -split "`r?`n" | Select-Object -First 1; if (-not $msg) { $msg = $_.Exception.GetType().Name }; $skipped += "$rel ($($msg.Substring(0, [Math]::Min(80, $msg.Length))))" } }
    if ($files.Count) { $label = $null; foreach ($lk in $FOLDER_LABELS.Keys) { if ($lk -ceq $name) { $label = $FOLDER_LABELS[$lk] } }
      if (-not $label) { $last = [regex]::Replace($name.Split("/")[-1], '^\d+-', ''); $label = $last.Substring(0, [Math]::Min(1, $last.Length)).ToUpperInvariant() + $(if ($last.Length -gt 1) { $last.Substring(1) } else { "" }) }
      $folders += [ordered]@{ name = $name; label = $label; files = @($files) }; $count += $files.Count } }
  $ddir = Join-Path $stateDir "docs"
  if (Test-Path -LiteralPath $ddir) { foreach ($f in @(Get-ChildItem -LiteralPath $ddir -File -Filter *.js)) { if (-not $keep.ContainsKey($f.Name)) { try { Remove-Item -LiteralPath $f.FullName -Force } catch { } } } }  # a sidecar whose source is gone
  $note = $null; if ($skipped.Count) { $plural = $(if ($skipped.Count -eq 1) { "" } else { "s" }); $note = "Skipped $($skipped.Count) file$plural the renderer could not read: " + ($skipped -join "; ") }
  [ordered]@{ folders = @($folders); count = $count; renderedAt = (Iso (NowUtc)); note = $note } }
$RE_SIGNOFF = '\*\*Sign-off:\*\*\s*(?:([^—\n]+?)\s*—\s*)?([^,\n·]+?),\s*([^·\n]+?)(?=\s*(?:·|\*\*|$))'
$RE_SIGNOFF_ANY = '\*\*Sign-off:\*\*\s*([^·\n]+?)(?=\s*(?:·|\*\*|$))'
$RE_APPROVED = '\*\*Approved by:\*\*\s*([^,\n(]+?),\s*([^(\n·]+?)(?=\s*(?:\(|·|\*\*|$))'
function Approval-Status($name, $date) { $d = "$date"; $nm = "$name"; if ([regex]::IsMatch($d, '(?i)pending') -or [regex]::IsMatch($d.Trim(), '^<.*>$') -or -not $d.Trim() -or [regex]::IsMatch($nm.Trim(), '^<.*>$')) { "pending" } else { "approved" } }
function Approvals-Read {
  # Sign-off and Approved-by lines in the first 12 lines of every .md under docs/, plus the Code Review §3 table — read only
  $out = @(); $docsDir = Join-Path $root "docs"
  if (-not (Test-Path -LiteralPath $docsDir -PathType Container)) { return @() }
  $paths = @(Get-ChildItem -LiteralPath $docsDir -File -Recurse -Force | Where-Object { $_.Name.ToLowerInvariant().EndsWith(".md") } | ForEach-Object { $_.FullName.Substring($root.Length).TrimStart('\', '/').Replace('\', '/') } | Where-Object { $parts = $_.Split('/'); $ok = $true; for ($q = 1; $q -lt $parts.Length - 1; $q++) { if ($parts[$q] -cin $DOC_SKIP_DIRS) { $ok = $false } }; $ok })
  if ($paths.Count) { [Array]::Sort($paths, [System.StringComparer]::Ordinal) }
  foreach ($rel in $paths) { $fpath = Join-Path $root $rel; $fn = [IO.Path]::GetFileName($rel); $stem = [IO.Path]::GetFileNameWithoutExtension($fn); $label = $stem; foreach ($dk in $DOC_NAMES.Keys) { if ($dk -ceq $stem) { $label = $DOC_NAMES[$dk] } }
    $lines = @((Read-Doc $fpath) -split "`r?`n"); $top = [Math]::Min(12, $lines.Count)
    for ($ln = 0; $ln -lt $top; $ln++) { $line = $lines[$ln]
      $m = [regex]::Match($line, $RE_SIGNOFF)
      if ($m.Success) { $role = $m.Groups[1].Value.Trim(); if (-not $role) { $role = $null }; $nm = $m.Groups[2].Value.Trim(); $dt = $m.Groups[3].Value.Trim()
        $out += [ordered]@{ document = $label; path = $rel; role = $role; name = $nm; date = $dt; status = (Approval-Status $nm $dt); source = "Sign-off"; line = $ln + 1 } }
      elseif ($line.Contains("**Sign-off:**")) { $m2 = [regex]::Match($line, $RE_SIGNOFF_ANY); $txt = $(if ($m2.Success) { $m2.Groups[1].Value.Trim() } else { "" }); if (-not $txt) { $txt = $null }
        $out += [ordered]@{ document = $label; path = $rel; role = $null; name = $txt; date = $null; status = "pending"; source = "Sign-off"; line = $ln + 1 } }
      $m = [regex]::Match($line, $RE_APPROVED)
      if ($m.Success) { $nm = $m.Groups[1].Value.Trim(); $dt = $m.Groups[2].Value.Trim(); $out += [ordered]@{ document = $label; path = $rel; role = $null; name = $nm; date = $dt; status = (Approval-Status $nm $dt); source = "Approved by"; line = $ln + 1 } } }
    if ($stem -ceq "CodeReview") { $k = -1; for ($q = 0; $q -lt $lines.Count; $q++) { if ([regex]::IsMatch($lines[$q], '^##\s+3\.\s+Fix batch')) { $k = $q; break } }
      if ($k -ge 0) { $q = $k + 1; $seen = 0
        while ($q -lt $lines.Count -and -not $lines[$q].StartsWith("## ")) { $l = $lines[$q]
          if ($l.TrimStart().StartsWith("|")) { $seen++
            if ($seen -gt 2) { $c = @(Md-Cells $l)
              if ($c.Count -ge 4 -and @($c[0..2] | Where-Object { $_ }).Count) { $nm = [regex]::Replace($c[1], '[*_]', '').Trim(); $dt = [regex]::Replace($c[2], '[*_]', '').Trim()
                $out += [ordered]@{ document = "Code Review — fix batch"; path = $rel; role = $null; name = $nm; date = $dt; status = (Approval-Status $nm $dt); source = "Code Review §3"; line = $q + 1 } } } }
          $q++ } } } }
  @($out) }
function HelpSite-Read { $p = Join-Path $root "docs/index.html"
  if (-not (Test-Path -LiteralPath $p -PathType Leaf)) { return [ordered]@{ path = "docs/index.html"; exists = $false; builtAt = $null; staleAgainst = @() } }
  $built = (Get-Item -LiteralPath $p).LastWriteTimeUtc; $stale = @(); $sj = Load-Json (Join-Path $root "docs/site.json") @{}
  foreach ($tab in @($sj.tabs)) { $src = $null; if ($tab -and $tab -isnot [string] -and $tab.source) { $src = $tab.source }; if ($src -and (Test-Path -LiteralPath (Join-Path $root $src) -PathType Leaf) -and (Get-Item -LiteralPath (Join-Path $root $src)).LastWriteTimeUtc -gt $built) { $stale += $src } }
  [ordered]@{ path = "docs/index.html"; exists = $true; builtAt = (Iso-Mtime $p); staleAgainst = @($stale) } }
function Package-Read {
  # the newest .app in outputAppPackage/ by the version in <Name>_<a.b.c.d>.app, mtime as the fallback; a shallow root search when that folder holds none
  $vkey = { param($f) $m = [regex]::Match($f, '_(\d+)\.(\d+)\.(\d+)\.(\d+)\.app$'); if ($m.Success) { ,@([int]$m.Groups[1].Value, [int]$m.Groups[2].Value, [int]$m.Groups[3].Value, [int]$m.Groups[4].Value) } else { $null } }
  $cands = @(); $pdir = Join-Path $root "outputAppPackage"
  if (Test-Path -LiteralPath $pdir -PathType Container) { $cands = @(Get-ChildItem -LiteralPath $pdir -File | Where-Object { $_.Name.ToLowerInvariant().EndsWith(".app") } | ForEach-Object { "outputAppPackage/" + $_.Name }) }
  if (-not $cands.Count) { $cands = @(Get-ChildItem -LiteralPath $root -File | Where-Object { $_.Name.ToLowerInvariant().EndsWith(".app") } | ForEach-Object { $_.Name })
    foreach ($d in @(Get-ChildItem -LiteralPath $root -Directory | Where-Object { $_.Name -cnotin ".alpackages", "node_modules", ".git", "ocpfFramework" -and -not $_.Name.StartsWith(".") })) { $cands += @(Get-ChildItem -LiteralPath $d.FullName -File | Where-Object { $_.Name.ToLowerInvariant().EndsWith(".app") } | ForEach-Object { $d.Name + "/" + $_.Name }) } }
  if (-not $cands.Count) { return [ordered]@{ path = $null; file = $null; version = $null; bytes = $null; builtAt = $null; count = 0 } }
  $best = $null; $bestV = $null; $bestT = $null
  foreach ($c in $cands) { $v = & $vkey $c; $t = (Get-Item -LiteralPath (Join-Path $root $c)).LastWriteTimeUtc; $take = $false
    if ($null -eq $best) { $take = $true }
    elseif ($v -and -not $bestV) { $take = $true }
    elseif ($v -and $bestV) { $cmp = 0; for ($q = 0; $q -lt 4; $q++) { if ($v[$q] -ne $bestV[$q]) { $cmp = $(if ($v[$q] -gt $bestV[$q]) { 1 } else { -1 }); break } }; if ($cmp -gt 0 -or ($cmp -eq 0 -and [string]::CompareOrdinal($c, $best) -gt 0)) { $take = $true } }
    elseif (-not $v -and -not $bestV) { if ($t -gt $bestT -or ($t -eq $bestT -and [string]::CompareOrdinal($c, $best) -gt 0)) { $take = $true } }
    if ($take) { $best = $c; $bestV = $v; $bestT = $t } }
  [ordered]@{ path = $best; file = [IO.Path]::GetFileName($best); version = $(if ($bestV) { $bestV -join "." } else { $null }); bytes = (Get-Item -LiteralPath (Join-Path $root $best)).Length; builtAt = (Iso-Mtime (Join-Path $root $best)); count = $cands.Count } }

function Newest-Mtime($d, $ext) { if (-not (Test-Path -LiteralPath $d -PathType Container)) { return $null }; $best = $null; foreach ($f in @(Get-ChildItem -LiteralPath $d -File -Recurse -Force | Where-Object { $_.Name.ToLowerInvariant().EndsWith($ext) })) { if ($null -eq $best -or $f.LastWriteTimeUtc -gt $best) { $best = $f.LastWriteTimeUtc } }; $best }
function UsageRow-Present($sid) { $hit = $false; foreach ($line in ((Read-Text (Join-Path $root "ProjectProgress.md")) -split "`r?`n")) { if ([regex]::IsMatch($line, '^##\s+Usage and cost')) { $hit = $true; continue }; if ($hit -and [regex]::IsMatch($line, '^\|\s*\**' + [regex]::Escape($sid) + '\**(?:\s*\(open\))?\s*\|')) { return $true } }; $false }
# The gate rules (the same three patterns as the Python twin): a path the item names; the item *is* an existence claim about it
# (the path is the subject of the first sentence, up to three words before it); the compile / package verbs (never the noun).
$GATE_PATH = '(docs/[\w./-]+\.\w+|requirements/[\w./-]+\.\w+|app\.json|outputAppPackage/)'
$RE_GATE_EXISTS = "^(?:[\w'-]+\s+){0,3}?" + $GATE_PATH + '\s*(?:\([^)]*\)\s*)?(?:exists|is written|is in\b|in place|holds)\b'
$RE_GATE_WRITTEN = "^(?:[\w'-]+\s+){0,5}?written to\s+" + $GATE_PATH
$RE_GATE_COMPILE = '(?i)\b(compiles?|compiled|0 errors|packaged|packages)\b'
function Progress-Read($cur, $appr, $pkg) {
  # the within-step progress bar's data (Ops § Dashboard → 7, the honesty rule): the current step's exit-gate items, each verified
  # from disk where a literal rule exists, else unknown; Build-a-Feature: the stage ladder, exact. No timer, no interpolation.
  if (-not $cur -or -not $cur.Count) { return $null }
  $items = @()
  if ($edition -eq "feature") { $stage = "$($cur.stage)".Trim(); $idx = -1; for ($q = 0; $q -lt $FEATURE_STAGES.Count; $q++) { if ($FEATURE_STAGES[$q].ToLowerInvariant() -ceq $stage.ToLowerInvariant()) { $idx = $q; break } }
    for ($q = 0; $q -lt $FEATURE_STAGES.Count; $q++) { $items += [ordered]@{ text = $FEATURE_STAGES[$q]; state = $(if ($q -le $idx) { "done" } else { "open" }); why = "stage column of the feature table" } }
    $source = "ProjectProgress.md" }
  else { $doc = $STEP_DOC["$($cur.id)"]; $docAppr = @($appr | Where-Object { $doc -and $_.path -ceq $doc })
    $appT = $(if ($pkg.count) { Newest-Mtime (Join-Path $root "outputAppPackage") ".app" } else { $null }); $srcT = Newest-Mtime (Join-Path $root "src") ".al"
    foreach ($text in @($cur.exitGate)) { $st = "unknown"; $why = "no on-disk signal"
      $paths = @([regex]::Matches($text, $GATE_PATH) | ForEach-Object { $_.Groups[1].Value })
      if ([regex]::IsMatch($text, '(?i)sign-off')) { if (-not $doc) { $why = "no document mapped to this step" } elseif (-not $docAppr.Count) { $st = "open"; $why = "$doc has no sign-off line yet" } elseif (@($docAppr | Where-Object { $_.status -eq "approved" }).Count) { $st = "done"; $why = "$doc sign-off line not pending" } else { $st = "open"; $why = "$doc sign-off pending" } }  # first: a sign-off item is about the approval, whatever paths it names
      elseif ($paths.Count) {  # a path proves only an existence claim whose subject is the path
        if ([regex]::IsMatch($text, $RE_GATE_EXISTS) -or [regex]::IsMatch($text, $RE_GATE_WRITTEN)) {
          $missing = @($paths | Where-Object { $p = $_; -not $(if ($p -ceq "outputAppPackage/") { [bool]$pkg.count } else { Test-Path -LiteralPath (Join-Path $root $p) }) })
          $st = $(if ($missing.Count) { "open" } else { "done" }); $why = $(if ($missing.Count) { $missing[0] + $(if ($missing[0] -ceq "outputAppPackage/") { " holds no package yet" } else { " not found" }) } else { ($paths -join ", ") + $(if ($paths.Count -eq 1) { " exists" } else { " exist" }) }) }
        else { $why = "names " + $paths[0] + " but claims more than its existence" } }
      elseif ([regex]::IsMatch($text, '(?i)usage rows')) { $st = $(if (UsageRow-Present $cur.id) { "done" } else { "open" }); $why = "ProjectProgress.md usage table " + $(if ($st -eq "done") { "has" } else { "has no" }) + " row " + $cur.id }
      elseif ([regex]::IsMatch($text, $RE_GATE_COMPILE) -and -not [regex]::IsMatch($text, '(?i)\.alpackages|not required|no compile')) { if ($appT -and ($null -eq $srcT -or $appT -ge $srcT)) { $st = "done"; $why = "newest .app is newer than every src/**/*.al" } else { $st = "open"; $why = $(if ($appT) { "no package newer than src/" } else { "no package yet" }) } }
      $items += [ordered]@{ text = $text; state = $st; why = $why } }
    $source = "runbookSteps/$($cur.id).md" }
  $done = @($items | Where-Object { $_.state -eq "done" }).Count; $ver = @($items | Where-Object { $_.state -ne "unknown" }).Count
  [ordered]@{ stepId = $cur.id; items = @($items); done = $done; verifiable = $ver; total = $items.Count; source = $source } }

# View Project Documents: the documents by folder (per-document sidecars) and the approval lines read from them; the newest
# package for the Download latest .app link in the Project completed box; the within-step progress bar — the same readers as the Python twin
$data.docs = Docs-Index
$apprs = @(Approvals-Read); $data.approvals = $apprs
$data.helpSite = HelpSite-Read
$pkgInfo = Package-Read; $data.package = $pkgInfo
$data.progress = Progress-Read $current $apprs $pkgInfo
# ---- render ----
# Every theme is rendered on every run; `theme` in dashboard.json only says which page -Open opens.
$THEMES = [ordered]@{ brand = @("dashboard.html", "ProjectDashboard.html"); f1 = @("dashboard-f1.html", "ProjectDashboard-f1.html") }
# -Open always opens the OnlyBCFans page; the F1 page opens only when -Theme f1 is passed on this very call (v5.6.0.0).
$themeKey = "$Theme".ToLower(); if (-not $THEMES.Contains($themeKey)) { $themeKey = "brand" }
$data.dataUrl = "ocpfFramework/state/dashboard-data.js"  # the pages pull this sidecar and repaint in place (no full reload)
$outs = @{}; $firstPayload = $null
foreach ($k in $THEMES.Keys) { $tplName = $THEMES[$k][0]; $outName = $THEMES[$k][1]
  $tpl = $null; foreach ($c in @((Join-Path $here "../templates/$tplName"), (Join-Path $root "ocpfFramework/scripts/$tplName"))) { if (Test-Path -LiteralPath $c) { $tpl = Get-Content -LiteralPath $c -Raw; break } }
  if (-not $tpl) { if ($k -eq "brand") { Write-Error "dashboard.html template not found beside the script (templates/dashboard.html) or in ocpfFramework/scripts/"; exit 1 }; continue }
  $data.theme = $k
  $payload = ($data | ConvertTo-Json -Depth 8 -Compress) -replace '</', '<\/'
  if ($null -eq $firstPayload) { $firstPayload = $payload }
  $o = Join-Path $root $outName  # project root: tracked, beside ProjectProgress.md
  [IO.File]::WriteAllText("$o.tmp", $tpl.Replace('/*__OCPF_DATA__*/null', $payload), [Text.UTF8Encoding]::new($false)); Move-Item -Force -LiteralPath "$o.tmp" -Destination $o; $outs[$k] = $o }
$out = $outs[$themeKey]; if (-not $out) { $out = $outs["brand"] }
$side = Join-Path $stateDir "dashboard-data.js"; [IO.File]::WriteAllText("$side.tmp", "window.__ocpfData=$firstPayload;", [Text.UTF8Encoding]::new($false)); Move-Item -Force -LiteralPath "$side.tmp" -Destination $side
if ($Open) { try { if ($IsMacOS) { & open $out } elseif ($IsWindows) { Start-Process $out } else { & xdg-open $out } } catch { } }
if (-not $Quiet) { $out; foreach ($n in $notes) { Write-Host "note: $n" } }
} catch { if ($Quiet) { exit 0 }; throw }
