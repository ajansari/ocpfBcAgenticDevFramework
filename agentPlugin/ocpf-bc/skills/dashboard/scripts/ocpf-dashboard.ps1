# OCPF BC Agentic Development Framework — the live dashboard renderer, PowerShell port.
# Renders ProjectDashboard.html (project root, tracked in git - never under the ignored ocpfFramework/state/)
# for one project from the state the framework already keeps
# (app.json, framework.json, usage.json, ProjectProgress.md, the step files, pricing.json, waiting.json,
# the sub-agent definitions, the usage script's -Json output, and — in Claude Code — the transcripts).
# Mirrors ocpf-dashboard.py (the Python script is the reference implementation); exercised on PowerShell 7
# on macOS, untested on Windows. Internal variables avoid the parameter names (names are case-insensitive).
#   pwsh ocpf-dashboard.ps1 -Project <root> [-Open] [-Quiet] [-Refresh 30] [-Toast "text"] [-Live]
#   pwsh ocpf-dashboard.ps1 -Project <root> -WaitingJson '<hook input>'    # a question opened
#   pwsh ocpf-dashboard.ps1 -Project <root> -ClearWaiting                   # it was answered
#   pwsh ocpf-dashboard.ps1 -Project <root> -Event who,text                 # append a feed event
param(
  [string]$Project = ".", [switch]$Open, [switch]$Quiet, [int]$Refresh = 30, [string]$Toast, [switch]$Live,
  [string]$WaitingJson, [switch]$ClearWaiting, [string[]]$Event, [int]$Throttle = 0
)
$ErrorActionPreference = "Stop"
try {
$root = (Resolve-Path $Project).Path
$stateDir = Join-Path $root "ocpfFramework/state"
if (-not (Test-Path (Join-Path $root "ocpfFramework"))) { if ($Quiet) { exit 0 }; Write-Error "$root has no ocpfFramework/ folder — not an OCPF project"; exit 1 }
New-Item -ItemType Directory -Force -Path $stateDir | Out-Null
if ($Throttle -gt 0 -and -not ($WaitingJson -or $ClearWaiting -or $Event -or $Open)) { $pg = Join-Path $root "ProjectDashboard.html"; if ((Test-Path $pg) -and (((Get-Date) - (Get-Item $pg).LastWriteTime).TotalSeconds -lt $Throttle)) { exit 0 }; if ((Test-Path "$pg.tmp") -and (((Get-Date) - (Get-Item "$pg.tmp").LastWriteTime).TotalSeconds -lt 120)) { exit 0 } }
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
function Load-Json($p, $d) { if (Test-Path $p) { try { Get-Content $p -Raw | ConvertFrom-Json -AsHashtable } catch { $d } } else { $d } }
function Read-Text($p) { if (Test-Path $p) { Get-Content $p -Raw } else { "" } }
function Parse-Ts($s) { if (-not $s) { return $null }; if ($s -is [datetime]) { return $s.ToUniversalTime() }; try { return ([datetimeoffset]::Parse($s)).UtcDateTime } catch { return $null } }
function NowUtc { [datetime]::UtcNow }
function Iso($d) { $d.ToString("yyyy-MM-ddTHH:mm:ssZ") }
$FULL = @(@("PRE-01","DEFINE"),@("PRE-02","DEFINE"),@("01","DEFINE"),@("02","DESIGN"),@("03","DESIGN"),@("04","DESIGN"),@("05","BUILD"),@("06","BUILD"),@("07","BUILD"),@("08","PROVE"),@("09","PROVE"),@("10","PROVE"),@("11","PROVE"),@("12","PROVE"))
$LITE = @(@("STEP-1","DEFINE"),@("STEP-2","DESIGN"),@("STEP-3","BUILD"),@("STEP-4","BUILD"),@("STEP-5","BUILD"),@("STEP-6","PROVE"),@("STEP-7","PROVE"))
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
if ($Live) { $dj = Load-Json (Join-Path $stateDir "dashboard.json") @{}; $dj["hooks"] = $true; if (-not $dj.theme) { $dj["theme"] = "brand" }; $dj | ConvertTo-Json | Set-Content -Path (Join-Path $stateDir "dashboard.json") -Encoding utf8 }

# ---- facts ----
$fw = Load-Json (Join-Path $root "ocpfFramework/framework.json") @{}
$usage = Load-Json (Join-Path $stateDir "usage.json") @{}
$pricing = Load-Json (Join-Path $stateDir "pricing.json") @{}
$tool = if ($usage.aiTool) { $usage.aiTool } elseif ("$($fw.placedAs)" -like "*copilot-instructions*") { "copilot-chat" } else { "claude-code" }
$copilot = $tool -like "copilot*"
$edition = if ($fw.edition) { "$($fw.edition)".ToLower() } elseif (Test-Path (Join-Path $root "ocpfFramework/runbookSteps/STEP-1.md")) { "lite" } else { "full" }
$app = Load-Json (Join-Path $root "app.json") @{}
$icon = $null
if ($app.logo -and (Test-Path (Join-Path $root $app.logo))) { $bytes = [IO.File]::ReadAllBytes((Join-Path $root $app.logo)); if ($bytes.Length -lt 400000) { $ext = ([IO.Path]::GetExtension($app.logo)).TrimStart('.').ToLower(); if (-not $ext) { $ext = "png" }; if ($ext -in "jpg","jpeg") { $ext = "jpeg" }; $icon = "data:image/$ext;base64," + [Convert]::ToBase64String($bytes) } }
$bc = $null; foreach ($k in "application","platform") { $v = $app[$k]; if ($v -is [string] -and $v -match '^(\d+)\.') { $bc = $Matches[1]; break } }
$appFacts = [ordered]@{ name = $app.name; publisher = $app.publisher; version = $app.version; bc = $bc; iconDataUri = $icon; target = $app.target }

$base = if ($edition -eq "lite") { $LITE } else { $FULL }
$catalog = @(foreach ($pair in $base) { $sid = $pair[0]; $ph = $pair[1]; $txt = Read-Text (Join-Path $root "ocpfFramework/runbookSteps/$sid.md"); $title = $null; $gate = @()
  if ($txt) { if ($txt -match '(?m)^# .*? — (?:PRE-0[12]|[0-9]{2}|STEP [0-9]) — (.+)$') { $title = $Matches[1].Trim() }
    if ($txt -match 'Phase:\s*([A-Z]+)') { $ph = $Matches[1] }
    if ($txt -match '(?s)\*\*Exit gate:\*\*\s*(.+?)(?:\r?\n\r?\n|\r?\n\*\*|$)') { $g = ($Matches[1] -replace '\s+', ' ').Trim(); $g = $g -replace '`([^`]*)`', '$1' -replace '\*\*([^*]*)\*\*', '$1'
      $gate = @([regex]::Split($g, '(?<=[.;])\s+(?=[A-Z§`])') | Where-Object { $_.Trim().Length -gt 3 } | ForEach-Object { $x = $_.Trim(); if ($x.Length -gt 220) { $x.Substring(0,220) + "…" } else { $x } } | Select-Object -First 7) } }
  [ordered]@{ id = $sid; phase = $ph; title = ($title ?? $SHORT[$sid] ?? $sid); short = ($SHORT[$sid] ?? $title ?? $sid); exitGate = $gate } })

$status = @{}
foreach ($line in (Read-Text (Join-Path $root "ProjectProgress.md")) -split "`n") { if ($line -match '^\|\s*(DEFINE|DESIGN|BUILD|PROVE)\s*\|\s*([A-Z0-9-]+)\s*[—-]\s*[^|]*\|\s*([^|]*)\|') { $st = $Matches[3].Trim().ToLower(); $status[$Matches[2].Trim()] = $(if ($st -like "*in progress*") { "now" } elseif ($st -like "complet*" -or $st -like "done*") { "done" } elseif (-not $st -or $st -in "pending","not started") { "todo" } elseif ($st -like "*complet*") { "done" } else { "todo" }) } }

$wins = @(); foreach ($s in @($usage.steps)) { $a = Parse-Ts $s.startedAt; if ($a -and $s.step) { $wins += ,@($s.step, $a, (Parse-Ts $s.completedAt)) } }
$wins = @($wins | Sort-Object { $_[1] }); for ($i = 0; $i -lt $wins.Count; $i++) { if ($null -eq $wins[$i][2] -and $i + 1 -lt $wins.Count) { $wins[$i][2] = $wins[$i + 1][1] } }
$el = @{}; foreach ($w in $wins) { $end = $w[2] ?? (NowUtc); $el[$w[0]] = ($el[$w[0]] ?? 0) + [Math]::Max(0, ($end - $w[1]).TotalSeconds) }
function Step-Of($ts) { $hit = $null; foreach ($w in $wins) { if ($ts -ge $w[1] -and ($null -eq $w[2] -or $ts -le $w[2])) { $hit = $w[0] } }; $hit }

# ---- usage rows via the usage script ----
$notes = @(); $uj = $null
if ($wins.Count) {
  $script = Join-Path $here "ocpf-usage.ps1"
  if (-not (Test-Path $script)) { foreach ($c in @((Join-Path $root "ocpfFramework/scripts/ocpf-usage.ps1"), (Join-Path $here "../../usage/scripts/ocpf-usage.ps1"))) { if (Test-Path $c) { $script = $c; break } } }
  if (Test-Path $script) { try { $out = & pwsh -NoProfile -File $script -Project $root -Json 2>&1; $uj = ($out | Out-String) | ConvertFrom-Json -AsHashtable } catch { $notes += "usage: $_" } } else { $notes += "usage script not found beside the dashboard script" }
} else { $notes += "usage: no step windows yet" }
$rows = @(if ($uj -and $uj.rows) { $uj.rows })
function Rows-For($sid) { @($rows | Where-Object { ("$($_.step)" -replace ' \(open\)$', '') -eq $sid }) }
function Sum($arr, $k) { $t = 0.0; foreach ($r in $arr) { $t += [double]($r[$k] ?? 0) }; $t }

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
          else { if ($prev.k -eq "prompt") { AddT $sid "agent" $gap } else { AddT $sid "agent" ([Math]::Min($gap, $gapCap)); AddT $sid "human" ([Math]::Max(0, $gap - $gapCap)) } } }
        if ($e.k -eq "ask") { $pending = $true }; if ($e.k -eq "prompt") { $pending = $false }; $prev = $e }
      $last = $ev[-1]; $age = ((NowUtc) - $last.ts).TotalSeconds
      $mainState = if ($last.k -ne "prompt" -and $age -lt 180) { "working" } else { "idle" }
      $lastModel = $null; $lastTxt = ""; for ($i = $ev.Count - 1; $i -ge 0; $i--) { if ($ev[$i].x -and $ev[$i].x.model -and -not $lastModel) { $lastModel = $ev[$i].x.model }; if ($ev[$i].x -and $ev[$i].x.txt -and -not $lastTxt) { $lastTxt = $ev[$i].x.txt }; if ($lastModel -and $lastTxt) { break } }
      $subsRaw = @(foreach ($aid in $side.Keys) { $s = $side[$aid]; @{ agentId = $aid; model = $s.model; running = (((NowUtc) - $s.last).TotalSeconds -lt 120); seconds = ($s.last - $s.first).TotalSeconds; last = $s.last } })
      if ($mainState -eq "idle" -and @($subsRaw | Where-Object { $_.running }).Count -gt 0) { $mainState = "working" }  # Main is waiting on its sub-agent, not idle
      $subs = @($subsRaw | Sort-Object { $_.last } -Descending)
      $liveState = @{ perStep = $per; main = @{ state = $mainState; model = $lastModel; text = $lastTxt }; subs = $subs } } }
}

# ---- steps ----
$steps = @(foreach ($c in $catalog) { $sid = $c.id; $rs = Rows-For $sid
  $st = $status[$sid]; if (-not $st) { $openWins = @($wins | Where-Object { $_[0] -eq $sid -and $null -eq $_[2] }).Count; $any = @($wins | Where-Object { $_[0] -eq $sid }).Count; $st = $(if ($any -and -not $openWins) { "done" } elseif ($any) { "now" } else { "todo" }) }
  if ($el.ContainsKey($sid) -and $st -eq "todo") { $st = $(if (@($wins | Where-Object { $_[0] -eq $sid -and $null -eq $_[2] }).Count) { "now" } else { "done" }) }
  [ordered]@{ id = $sid; title = $c.title; short = $c.short; phase = $c.phase; status = $st; elapsedSeconds = $el[$sid]
    costUsd = $(if ($rs.Count) { Sum $rs "costUsd" } else { $null })
    tokens = $(if ($rs.Count -and -not $copilot) { (Sum $rs "input") + (Sum $rs "output") + (Sum $rs "cacheWrite") + (Sum $rs "cacheRead") } else { $null })
    credits = $(if ($rs.Count -and $copilot) { Sum $rs "aiCredits" } else { $null }) } })
$cur = $steps | Where-Object { $_.status -eq "now" } | Select-Object -First 1

# ---- totals ----
$tot = [ordered]@{ costUsd = $(if ($rows.Count) { Sum $rows "costUsd" } else { $null }); elapsedSeconds = $(if ($el.Count) { ($el.Values | Measure-Object -Sum).Sum } else { $null }) }
$seen = @{}; $d = 0; $t = 0; foreach ($r in $rows) { if ($seen.ContainsKey("$($r.step)")) { continue }; $seen["$($r.step)"] = 1; $d += [int]($r.decisions ?? 0); $t += [int]($r.turns ?? 0) }
$tot.decisions = $d; $tot.turns = $t
if ($copilot) { $tot.credits = $(if ($rows.Count) { [Math]::Round((Sum $rows "aiCredits"), 1) } else { $null }); $tot.creditsOpen = [bool](@($uj.sessions | Where-Object { -not $_.closed }).Count) }
else { $tk = [ordered]@{}; foreach ($k in "input","output","cacheWrite","cacheRead") { $tk[$k] = Sum $rows $k }; $tk.total = ($tk.input + $tk.output + $tk.cacheWrite + $tk.cacheRead); $tot.tokens = $(if ($rows.Count) { $tk } else { $null }) }
if ($liveState) { $ag = 0.0; $hu = 0.0; $wa = 0.0; foreach ($v in $liveState.perStep.Values) { $ag += $v.agent; $hu += $v.human; $wa += $v.waiting }; $tot.agentSeconds = $ag; $tot.humanSeconds = $hu; $tot.waitingSeconds = $wa }
$current = [ordered]@{}
if ($cur) { $ps = if ($liveState -and $liveState.perStep.ContainsKey($cur.id)) { $liveState.perStep[$cur.id] } else { $null }; $gateC = ($catalog | Where-Object { $_.id -eq $cur.id } | Select-Object -First 1).exitGate
  $current = [ordered]@{ id = $cur.id; title = $cur.title; phase = $cur.phase; exitGate = @($gateC); totals = [ordered]@{ costUsd = $cur.costUsd; elapsedSeconds = $cur.elapsedSeconds; agentSeconds = $(if ($ps) { $ps.agent }); humanSeconds = $(if ($ps) { $ps.human }); waitingSeconds = $(if ($ps) { $ps.waiting }); tokens = $cur.tokens; credits = $cur.credits } } }

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
  foreach ($sub in @($liveState.subs | Select-Object -First 3)) { $target = $rl | Where-Object { $_.role -in "Reasoning","Light","Generator" -and $_.model -and $sub.model -and ("$($sub.model)" -like "*$($_.model)*" -or "$($_.model)" -like "*$($sub.model)*") -and $_.status -eq "idle" } | Select-Object -First 1
    if ($target) { $target.status = $(if ($sub.running) { "running" } else { "idle" }); $target.runningSeconds = $(if ($sub.running) { $sub.seconds }); $target.lastDetail = $(if ($sub.running) { $null } else { "returned " + $sub.last.ToLocalTime().ToString("HH:mm") }) } } }
foreach ($r in $rl) { if ($r.model) { $mm = $models | Where-Object { $_.model -and ("$($_.model)" -like "*$($r.model)*" -or "$($r.model)" -like "*$($_.model)*") } | Select-Object -First 1; if ($mm) { $r.tokens = $mm.tokens; $r.credits = [Math]::Round($mm.credits, 1) } } }
if ($gen.model -and $main.model -and $gen.model -eq $main.model) { $gen.Remove("tokens"); $gen.Remove("credits"); $gen.detail = "same model as Main; its usage is counted in Main's row" }
$waiting = Load-Json (Join-Path $stateDir "waiting.json") $null
if ($waiting -and $waiting.clearedAt) { $waiting = $null }
if ($waiting) { $main.status = "waiting on you"; $main.detail = "$($waiting.question)".Substring(0, [Math]::Min(90, "$($waiting.question)".Length)) }

# ---- estimate ----
$est = $null
if ($cur) { $etxt = Read-Text (Join-Path $root "docs/2-design/AiEffortEstimate.md")
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
  steps = $steps; current = $current; totals = $tot; estimate = $est; models = $models; roles = $rl; waiting = $waiting; events = $events
  pricing = [ordered]@{ source = $priceSrc; fetchedAt = $pricing.fetchedAt; usdPerCredit = $pricing.aiCredit.usd }; notes = $notes; toast = $Toast }

# ---- render ----
$tpl = $null; foreach ($c in @((Join-Path $here "../templates/dashboard.html"), (Join-Path $root "ocpfFramework/scripts/dashboard.html"))) { if (Test-Path $c) { $tpl = Get-Content $c -Raw; break } }
if (-not $tpl) { Write-Error "dashboard.html template not found beside the script (templates/dashboard.html) or in ocpfFramework/scripts/"; exit 1 }
$payload = ($data | ConvertTo-Json -Depth 8 -Compress) -replace '</', '<\/'
$html = $tpl.Replace('/*__OCPF_DATA__*/null', $payload)
$out = Join-Path $root "ProjectDashboard.html"  # project root: tracked, beside ProjectProgress.md
[IO.File]::WriteAllText("$out.tmp", $html, [Text.UTF8Encoding]::new($false)); Move-Item -Force "$out.tmp" $out
if ($Open) { try { if ($IsMacOS) { & open $out } elseif ($IsWindows) { Start-Process $out } else { & xdg-open $out } } catch { } }
if (-not $Quiet) { $out; foreach ($n in $notes) { Write-Host "note: $n" } }
} catch { if ($Quiet) { exit 0 }; throw }
