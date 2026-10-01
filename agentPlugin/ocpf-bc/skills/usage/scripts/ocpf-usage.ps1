# OCPF BC Agentic Development Framework — usage and cost per step, PowerShell port.
# Two sources, chosen by "aiTool" in usage.json (or -Tool): claude-code reads tokens by type from Claude Code's
# transcripts; copilot-chat reads AI credits per model from the chat session files GitHub Copilot Chat in VS Code
# keeps in the workspace storage folder, sub-agents included. Copilot Chat records no token totals by type, so the
# Copilot table has credit columns, not token columns. Steps are separated by checkpoints stored in usage.json
# (a turn can run across several steps); see ocpf-usage.py's header.
# Mirrors ocpf-usage.py (the Python script is the reference implementation); exercised on PowerShell 7 on macOS,
# untested on Windows. Internal variables avoid the parameter names: PowerShell variable names are case-insensitive.
#   pwsh ocpf-usage.ps1 -Project C:\path\to\project [-Json] [-Step 03] [-Usage <path>] [-Pricing <path>] [-Transcripts <dir>]
#   pwsh ocpf-usage.ps1 -Project C:\path\to\project -Calibrate
#   pwsh ocpf-usage.ps1 -Project C:\path\to\project -Step 03 [-Tool copilot-chat] [-Sessions <chatSessions dir>] [-SessionCredits 3714.7]
# Defaults: ocpfFramework\state\usage.json and ocpfFramework\state\pricing.json under the project.
# -Calibrate (project close, Full Step 12 / Lite Step 7) writes ~\.ocpf\calibration\<project>-<date>.json —
# per step and per model tokens by type, elapsed, turns, decisions, sub-agent calls, and the object counts
# by type from docs\1-define\ObjectRegister.md (Full) or docs\2-design\DesignDoc.md's object table (Lite) —
# and prints the path it wrote.
param(
  [string]$Project = ".",
  [string]$Usage, [string]$Pricing, [string]$Transcripts,
  [switch]$Json, [string]$Step, [switch]$Calibrate,
  [ValidateSet("claude-code", "copilot-chat")][string]$Tool, [string]$Sessions, [Nullable[double]]$SessionCredits
)
$ErrorActionPreference = "Stop"
$inv = [cultureinfo]::InvariantCulture
if ($Calibrate -and $Step) { Write-Error "-Calibrate exports the whole project; run it without -Step"; exit 1 }
$root = (Resolve-Path $Project).Path
$stateDir = Join-Path $root "ocpfFramework/state"
function Load-Json($path, $default) { if (Test-Path $path) { Get-Content $path -Raw | ConvertFrom-Json -AsHashtable } else { $default } }
function Parse-Ts($s) { if (-not $s) { return $null }; if ($s -is [datetime]) { return $s.ToUniversalTime() }; if ($s -is [datetimeoffset]) { return $s.UtcDateTime }; try { return ([datetimeoffset]::Parse($s)).UtcDateTime } catch { return $null } }
$usagePath  = $(if ($Usage) { $Usage } else { Join-Path $stateDir "usage.json" })
$usageDoc   = Load-Json $usagePath @{}
$pricingDoc = Load-Json ($(if ($Pricing) { $Pricing } else { Join-Path $stateDir "pricing.json" })) @{}
$rates = if ($pricingDoc.perMillionTokens) { $pricingDoc.perMillionTokens } else { @{} }
$aiTool = if ($Tool) { $Tool } elseif ($usageDoc.aiTool) { $usageDoc.aiTool } else { "claude-code" }
if ($aiTool -eq "copilot-cli") { Write-Error "Copilot CLI isn't measured by this script — read the session's credits in the CLI and pass them with -Tool copilot-chat -SessionCredits <n>"; exit 1 }
$isCopilot = $aiTool -eq "copilot-chat"
$notes = @()
$wins = @(); foreach ($s in ($usageDoc.steps ?? @())) { $a = Parse-Ts $s.startedAt; if ($a -and $s.step) { $wins += ,@($s.step, $a, (Parse-Ts $s.completedAt)) } }
$wins = @($wins | Sort-Object { $_[1] })
for ($i = 0; $i -lt $wins.Count; $i++) { if ($null -eq $wins[$i][2] -and $i + 1 -lt $wins.Count) { $wins[$i][2] = $wins[$i + 1][1] } }   # an open window ends where the next starts
if (-not $wins) { $notes += "no step windows in ocpfFramework/state/usage.json — everything is Unattributed" }
function Step-For($ts) { $hit = $null; foreach ($w in $wins) { if ($ts -ge $w[1] -and ($null -eq $w[2] -or $ts -le $w[2])) { $hit = $w[0] } }; if ($hit) { $hit } else { "Unattributed" } }
function N($v) { try { [long]($v ?? 0) } catch { 0 } }
function Elapsed-For($sid) {
  $elapsed = $null
  foreach ($s in ($usageDoc.steps ?? @())) { if ($s.step -eq $sid -and (Parse-Ts $s.startedAt)) { $start = Parse-Ts $s.startedAt; $end = $null; foreach ($w in $wins) { if ($w[0] -eq $sid -and $w[1] -eq $start) { $end = $w[2] } }; $end = $end ?? [datetime]::UtcNow; $elapsed = ($elapsed ?? 0) + [math]::Max(0, ($end - $start).TotalSeconds) } }
  $elapsed
}
$out = @()

# ───────────────────────────── GitHub Copilot Chat in VS Code ─────────────────────────────
$AllModels = "all models (Session Info popover)"
function To-Mutable($o) {
  if ($o -is [System.Collections.IDictionary]) { foreach ($k in @($o.Keys)) { $o[$k] = To-Mutable $o[$k] }; return $o }
  if ($o -is [array] -or $o -is [System.Collections.ArrayList]) { $l = [System.Collections.ArrayList]::new(); foreach ($x in $o) { [void]$l.Add((To-Mutable $x)) }; return ,$l }
  return $o
}
function Replay-Session($path) {
  # The session's state, rebuilt from VS Code's operation log (kind 0 = initial, 1 = set, 2 = append).
  if ($path -notlike "*.jsonl") { return (To-Mutable (Get-Content $path -Raw | ConvertFrom-Json -AsHashtable)) }
  $state = $null
  foreach ($line in [System.IO.File]::ReadLines($path)) {
    try { $o = $line | ConvertFrom-Json -AsHashtable } catch { continue }
    if ($o -isnot [System.Collections.IDictionary]) { continue }
    $kind = $o.kind; $k = @($o.k | Where-Object { $null -ne $_ }); $v = To-Mutable $o.v
    if ($kind -eq 0) { $state = $v; continue }
    if ($null -eq $state -or $k.Count -eq 0) { continue }
    try {
      $cur = $state
      for ($i = 0; $i -lt $k.Count - 1; $i++) {
        $key = $k[$i]
        if ($cur -is [System.Collections.ArrayList]) { $key = [int]$key; while ($cur.Count -le $key) { [void]$cur.Add(@{}) }; if ($null -eq $cur[$key]) { $cur[$key] = @{} }; $cur = $cur[$key] }
        else { if ($null -eq $cur[$key]) { $cur[$key] = @{} }; $cur = $cur[$key] }
      }
      $last = $k[-1]; $isList = $cur -is [System.Collections.ArrayList]
      if ($isList) { $last = [int]$last; while ($cur.Count -le $last) { [void]$cur.Add($null) } }
      if ($kind -eq 1) { $cur[$last] = $v }
      elseif ($kind -eq 2) {
        $tgt = $cur[$last]
        if ($tgt -isnot [System.Collections.ArrayList]) { $tgt = [System.Collections.ArrayList]::new(); $cur[$last] = $tgt }
        if ($null -ne $o.i) { $i0 = [int]$o.i; if ($i0 -lt $tgt.Count) { $tgt.RemoveRange($i0, $tgt.Count - $i0) } }
        if ($v -is [System.Collections.ArrayList]) { $tgt.AddRange($v) } else { [void]$tgt.Add($v) }
      }
    } catch { continue }
  }
  $state
}
function Num($v) { try { $d = [double]($v ?? 0); if ([double]::IsNaN($d) -or [double]::IsInfinity($d)) { 0.0 } else { $d } } catch { 0.0 } }
function Uri-ToPath($u) { if (-not $u -or $u -notlike "file:*") { return $null }; try { $p = [uri]::UnescapeDataString(([uri]$u).AbsolutePath) } catch { return $null }; if ($p -match '^/[A-Za-z]:') { $p = $p.Substring(1) }; $p }
function Same-Path($a, $b) { try { $x = [System.IO.Path]::GetFullPath($a).TrimEnd('\', '/'); $y = [System.IO.Path]::GetFullPath($b).TrimEnd('\', '/'); $x -ieq $y } catch { $false } }
function Session-DirsFor($root) {
  $bases = if ($IsMacOS) { @(Join-Path $HOME "Library/Application Support") } elseif ($IsWindows) { @($env:APPDATA) } else { @($(if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { Join-Path $HOME ".config" })) }
  $dirs = @()
  foreach ($b in $bases) { foreach ($product in "Code", "Code - Insiders", "VSCodium") {
    $store = Join-Path $b "$product/User/workspaceStorage"; if (-not (Test-Path $store)) { continue }
    foreach ($ws in (Get-ChildItem -Path $store -Directory | Sort-Object Name)) {
      $metaPath = Join-Path $ws.FullName "workspace.json"; if (-not (Test-Path $metaPath)) { continue }
      try { $meta = Get-Content $metaPath -Raw | ConvertFrom-Json -AsHashtable } catch { continue }
      $folders = @(Uri-ToPath $meta.folder)
      $wsFile = Uri-ToPath $meta.workspace
      if ($wsFile -and (Test-Path $wsFile)) { try { foreach ($f in ((Get-Content $wsFile -Raw | ConvertFrom-Json -AsHashtable).folders ?? @())) { if ($f.path) { $folders += $(if ([System.IO.Path]::IsPathRooted($f.path)) { $f.path } else { Join-Path (Split-Path $wsFile) $f.path }) } } } catch { } }
      $hit = $false; foreach ($f in $folders) { if ($f -and (Same-Path $f $root)) { $hit = $true } }
      $d = Join-Path $ws.FullName "chatSessions"
      if ($hit -and (Test-Path $d)) { $dirs += $d }
    } } }
  $dirs
}
function New-Snap { @{ byModel = @{}; turns = 0; decisions = 0; subAgentCalls = 0 } }
function Snapshot($turnList, $overhead = 0.0) {
  $s = New-Snap
  foreach ($t in $turnList) {
    $k = "$($t.model)|main"; if (-not $s.byModel.ContainsKey($k)) { $s.byModel[$k] = @{ credits = 0.0; calls = 0 } }
    $s.byModel[$k].credits += $t.own; $s.byModel[$k].calls += 1
    foreach ($sub in $t.subs) { $k = "$($sub[0])|sub-agent"; if (-not $s.byModel.ContainsKey($k)) { $s.byModel[$k] = @{ credits = 0.0; calls = 0 } }; $s.byModel[$k].credits += $sub[1]; $s.byModel[$k].calls += 1 }
    if (-not $t.hidden) { $s.turns += 1 }; $s.decisions += $t.asks; $s.subAgentCalls += $t.subs.Count
  }
  if ($overhead -gt 0.05) { $s.byModel["between turns (compaction)|session"] = @{ credits = $overhead; calls = 0 } }
  foreach ($k in @($s.byModel.Keys)) { $s.byModel[$k].credits = [math]::Round($s.byModel[$k].credits, 4) }
  $s
}
function Snap-Total($s) { $t = 0.0; foreach ($v in $s.byModel.Values) { $t += (Num $v.credits) }; $t }
function Snap-Diff($cur, $prev, $label) {
  $by = @{}
  $cs = $cur.source ?? "sessions"; $ps = $prev.source ?? "sessions"
  if ($cs -ne $ps -and $prev.byModel.Count -gt 0) { $by["$AllModels|all"] = @{ credits = (Snap-Total $cur) - (Snap-Total $prev); calls = 0 } }
  else { foreach ($k in (@($cur.byModel.Keys) + @($prev.byModel.Keys) | Select-Object -Unique)) { $c = $cur.byModel[$k] ?? @{ credits = 0; calls = 0 }; $p = $prev.byModel[$k] ?? @{ credits = 0; calls = 0 }; $by[$k] = @{ credits = (Num $c.credits) - (Num $p.credits); calls = [int]$c.calls - [int]$p.calls } } }
  $neg = $false; foreach ($v in $by.Values) { if ($v.credits -lt -0.05) { $neg = $true } }
  if ($neg) { $script:notes += "${label}: the recorded total went down — a chat session was deleted or cleared; negative differences are shown as 0" }
  $d = New-Snap
  foreach ($k in $by.Keys) { $v = $by[$k]; if ($v.credits -gt 0.00005 -or $v.calls -gt 0) { $d.byModel[$k] = @{ credits = [math]::Max(0.0, $v.credits); calls = [math]::Max(0, $v.calls) } } }
  $d.turns = [math]::Max(0, [int]$cur.turns - [int]$prev.turns); $d.decisions = [math]::Max(0, [int]$cur.decisions - [int]$prev.decisions); $d.subAgentCalls = [math]::Max(0, [int]$cur.subAgentCalls - [int]$prev.subAgentCalls)
  $d
}
$cpFiles = @(); $cpDirs = @(); $cpManual = $false; $usdPerCredit = $null
if ($isCopilot) {
  if (-not $usageDoc.ContainsKey("copilot") -or $usageDoc.copilot -isnot [System.Collections.IDictionary]) { $usageDoc["copilot"] = [ordered]@{} }
  $cpState = $usageDoc.copilot
  $cps = [System.Collections.ArrayList]::new(); foreach ($c in ($cpState.checkpoints ?? @())) { [void]$cps.Add($c) }
  $cpManual = $null -ne $SessionCredits
  $cand = if ($Sessions) { @($Sessions) } elseif ($cpState.sessionDirs) { @($cpState.sessionDirs) } else { @(Session-DirsFor $root) }
  $cpDirs = @($cand | Where-Object { $_ } | ForEach-Object { $_ -replace '^~', $HOME } | Where-Object { Test-Path $_ })
  foreach ($d in $cpDirs) { $cpFiles += @(Get-ChildItem -Path $d -File | Where-Object { $_.Name -like "*.json*" } | Sort-Object Name) }
  $turnList = @(); $overhead = 0.0
  if ($cpManual) { $current = New-Snap; $current.byModel["$AllModels|all"] = @{ credits = [math]::Round([double]$SessionCredits, 4); calls = 0 }; $current.source = "popover" }
  else {
    if (-not $cpFiles) { Write-Error ("no Copilot Chat session files found for this project folder" + $(if ($cpDirs) { " in $($cpDirs -join ', ')" } else { " in VS Code's workspace storage" }) + " — pass -Sessions <chatSessions folder>, or read Session Cost in the Session Info popover (the context window control in the chat input) and pass it with -SessionCredits <n>"); exit 1 }
    $unread = 0
    foreach ($f in $cpFiles) {
      $state = $null; try { $state = Replay-Session $f.FullName } catch { }
      if ($state -isnot [System.Collections.IDictionary] -or $state.requests -isnot [System.Collections.ArrayList]) { $unread++; continue }
      $reported = 0.0; $total = 0.0
      foreach ($r in $state.requests) {
        if ($r -isnot [System.Collections.IDictionary]) { continue }
        $ts = $null; if ($r.timestamp -is [ValueType]) { $ts = [DateTimeOffset]::FromUnixTimeMilliseconds([long]$r.timestamp).UtcDateTime }
        $credits = Num $r.copilotCredits; $total += $credits; $reported = [math]::Max($reported, (Num $r.sessionCopilotCredits))
        $subs = @(); $asks = 0
        foreach ($part in ($r.response ?? @())) {
          if ($part -isnot [System.Collections.IDictionary] -or $part.kind -ne "toolInvocationSerialized") { continue }
          if ("$($part.toolId)" -like "*askQuestions*") { $asks++ }
          $t = $part.toolSpecificData
          if ($t -is [System.Collections.IDictionary] -and $t.kind -eq "subagent") { $subs += ,@(($t.modelId ?? $t.modelName ?? "unknown"), (Num $t.credits)) }
        }
        $subTotal = 0.0; foreach ($x in $subs) { $subTotal += $x[1] }
        $own = $credits - $subTotal; if ($own -lt -0.005) { $own = $credits }   # a VS Code that doesn't fold sub-agents into the turn
        $turnList += @{ ts = $ts; model = ($r.modelId ?? "unknown"); own = [math]::Max(0.0, $own); subs = $subs; asks = $asks; hidden = [bool]$r.hiddenFromTranscript }
      }
      if ($reported -gt $total + 0.05) { $overhead += $reported - $total }
    }
    if ($unread) { $notes += "$unread session file(s) could not be read and were skipped" }
    $current = Snapshot $turnList $overhead; $current.source = "sessions"
    $cpState["sessionDirs"] = $cpDirs
  }
  if ($Step -and -not $Calibrate) {
    $win = @($wins | Where-Object { $_[0] -eq $Step })
    if (-not $win) { Write-Error "step $Step has no startedAt in ocpfFramework/state/usage.json — write the window first"; exit 1 }
    $cp = [ordered]@{ step = $Step; at = [datetime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ"); source = $current.source; byModel = $current.byModel; turns = $current.turns; decisions = $current.decisions; subAgentCalls = $current.subAgentCalls }
    $lastAt = if ($cps.Count) { Parse-Ts $cps[$cps.Count - 1].at } else { $null }
    if ($cps.Count -and $cps[$cps.Count - 1].step -eq $Step -and $lastAt -and $lastAt -ge $win[-1][1]) { $cps[$cps.Count - 1] = $cp } else { [void]$cps.Add($cp) }
    $cpState["checkpoints"] = @($cps)
    $usageDoc | ConvertTo-Json -Depth 12 | Set-Content -Path $usagePath -Encoding utf8
  }
  $per = [ordered]@{}
  function Credit-Step($sid, $d) {
    if ($d.byModel.Count -eq 0 -and $d.turns -eq 0) { return }
    if (-not $script:per.Contains($sid)) { $script:per[$sid] = New-Snap }
    $g = $script:per[$sid]
    foreach ($k in $d.byModel.Keys) { if (-not $g.byModel.ContainsKey($k)) { $g.byModel[$k] = @{ credits = 0.0; calls = 0 } }; $g.byModel[$k].credits += $d.byModel[$k].credits; $g.byModel[$k].calls += $d.byModel[$k].calls }
    $g.turns += $d.turns; $g.decisions += $d.decisions; $g.subAgentCalls += $d.subAgentCalls
  }
  function Turn-Step($t) { if ($null -eq $t.ts) { "Unattributed" } else { Step-For $t.ts } }
  if ($cps.Count -eq 0) {
    $notes += "no checkpoints yet — attributed by each turn's start time; a turn that ran across steps counts in the step it started in"
    foreach ($sid in ((@($wins | ForEach-Object { $_[0] }) + "Unattributed") | Select-Object -Unique)) { Credit-Step $sid (Snapshot @($turnList | Where-Object { (Turn-Step $_) -eq $sid })) }
    Credit-Step "between turns" (Snapshot @() $overhead)
  } else {
    $firstStart = $null; foreach ($w in $wins) { if ($w[0] -eq $cps[0].step -and $null -eq $firstStart) { $firstStart = $w[1] } }
    $prev = New-Snap
    if ($firstStart -and $turnList.Count) {
      $early = @($turnList | Where-Object { $_.ts -and $_.ts -lt $firstStart })
      $prev = Snapshot $early; $prev.source = "sessions"
      foreach ($sid in ((@("Unattributed") + @($wins | ForEach-Object { $_[0] })) | Select-Object -Unique)) { $mine = @($early | Where-Object { (Turn-Step $_) -eq $sid }); if ($mine.Count) { Credit-Step $sid (Snapshot $mine) } }
      if ($per.Count) { $notes += "work before step $($cps[0].step) has no checkpoint — attributed by each turn's start time; Unattributed is work that started outside every step window" }
    }
    foreach ($cp in $cps) { Credit-Step $cp.step (Snap-Diff $cp $prev "step $($cp.step)"); $prev = $cp }
    $tail = Snap-Diff $current $prev "since the last checkpoint"
    if ($tail.byModel.Count) {
      $openStep = $null; $prevAt = Parse-Ts $prev.at
      for ($i = $wins.Count - 1; $i -ge 0 -and -not $openStep; $i--) { if ($null -eq $wins[$i][2] -or $null -eq $prevAt -or $wins[$i][1] -ge $prevAt) { $openStep = $wins[$i][0] } }
      Credit-Step $(if ($openStep) { "$openStep (open)" } else { "Unattributed" }) $tail
    }
  }
  $usdPerCredit = if ($pricingDoc.aiCredit -and $null -ne $pricingDoc.aiCredit.usd) { [double]$pricingDoc.aiCredit.usd } else { $null }
  foreach ($sid in $per.Keys) {
    $bare = $sid -replace ' \(open\)$', ''
    if ($Step -and $bare -ne $Step) { continue }
    $el = Elapsed-For $bare; $d = $per[$sid]
    foreach ($k in ($d.byModel.Keys | Sort-Object @{ Expression = { ($_ -split '\|')[-1] -ne "main" } }, @{ Expression = { -$d.byModel[$_].credits } })) {
      $cut = $k.LastIndexOf('|'); $v = $d.byModel[$k]
      $out += [pscustomobject]@{ step=$sid; model=$k.Substring(0, $cut); role=$k.Substring($cut + 1); aiCredits=[math]::Round($v.credits, 2); calls=$v.calls
        input=$null; output=$null; cacheWrite=$null; cacheRead=$null; requests=$v.calls
        costUsd=$(if ($null -ne $usdPerCredit) { [math]::Round($v.credits * $usdPerCredit, 4) } else { $null }); elapsedSeconds=$(if ($null -ne $el) { [int][math]::Round($el) } else { $null })
        turns=$d.turns; decisions=$d.decisions; subAgentCalls=$d.subAgentCalls; webRequests=0 }
    }
  }
  if ($Step -and -not $out) { $notes += "no credits were recorded inside step $Step — check its window in ocpfFramework/state/usage.json, and that the chat session wasn't deleted" }
  if ($null -eq $usdPerCredit) { $notes += 'pricing.json has no "aiCredit" entry — fetch https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing and write { "aiCredit": { "usd": <value>, "source": <url> } }' }
}

if (-not $isCopilot) {
$key = ($root -replace '[\\/:]', '-')
$tdir = if ($Transcripts) { $Transcripts } elseif ($usageDoc.transcriptDir) { $usageDoc.transcriptDir -replace '^~', $HOME } else { Join-Path $HOME ".claude/projects/$key" }
$files = Get-ChildItem -Path $tdir -Filter *.jsonl -ErrorAction SilentlyContinue | Sort-Object Name
if (-not $files) { Write-Error "no transcripts in $tdir — set transcriptDir in ocpfFramework/state/usage.json (ls ~/.claude/projects/)"; exit 1 }
$seen = @{}; $rows = @(); $turns = @{}; $decisions = @{}; $agents = @{}; $web = @{}; $noRid = 0
foreach ($f in $files) {
  foreach ($line in [System.IO.File]::ReadLines($f.FullName)) {
    try { $o = $line | ConvertFrom-Json -AsHashtable } catch { continue }
    $ts = Parse-Ts $o.timestamp; if ($null -eq $ts) { continue }
    $sid = Step-For $ts; $m = $o.message
    $blocks = if ($m -and ($m.content -is [array])) { $m.content } else { @() }
    if ($o.type -eq "user" -and -not $o.isSidechain) { $isResult = $false; foreach ($c in $blocks) { if ($c -is [hashtable] -and $c.type -eq "tool_result") { $isResult = $true } }; if (-not $isResult) { $turns[$sid] = 1 + ($turns[$sid] ?? 0) } }
    if ($o.type -ne "assistant" -or -not $m) { continue }
    foreach ($c in $blocks) { if ($c -is [hashtable] -and $c.type -eq "tool_use") {
      if ($c.name -eq "AskUserQuestion") { $decisions[$sid] = 1 + ($decisions[$sid] ?? 0) }
      if ($c.name -eq "Agent" -or $c.name -eq "Task") { $agents[$sid] = 1 + ($agents[$sid] ?? 0) } } }
    $u = $m.usage; if (-not $u) { continue }
    $rid = $o.requestId; if (-not $rid) { $noRid++; continue }
    if ($seen.ContainsKey($rid)) { continue }; $seen[$rid] = $true
    $cc = $u.cache_creation ?? @{}; $st = $u.server_tool_use ?? @{}
    $web[$sid] = ($web[$sid] ?? 0) + (N $st.web_search_requests) + (N $st.web_fetch_requests)
    $rows += [pscustomobject]@{ step=$sid; model=($m.model ?? "unknown"); input=(N $u.input_tokens); output=(N $u.output_tokens)
      cacheWrite=(N $u.cache_creation_input_tokens); cache5m=(N $cc.ephemeral_5m_input_tokens); cache1h=(N $cc.ephemeral_1h_input_tokens)
      cacheRead=(N $u.cache_read_input_tokens) }
  }
}
if ($noRid) { $notes += "$noRid assistant line(s) had no requestId and were excluded" }
$order = @($wins | ForEach-Object { $_[0] }) + "Unattributed"
foreach ($sid in ($order | Select-Object -Unique)) {
  if ($Step -and $sid -ne $Step) { continue }
  $elapsed = Elapsed-For $sid
  foreach ($grp in ($rows | Where-Object step -eq $sid | Group-Object model | Sort-Object Name)) {
    $r = $rates[$grp.Name]; $priced = $null -ne $r; $cost = 0.0
    $sum = @{ input=0; output=0; cacheWrite=0; cache5m=0; cache1h=0; cacheRead=0 }
    foreach ($x in $grp.Group) { foreach ($k in @($sum.Keys)) { $sum[$k] += $x.$k }
      if ($priced) { $unsplit = [math]::Max(0, $x.cacheWrite - $x.cache5m - $x.cache1h); $cost += ($x.input*($r.input ?? 0) + $x.output*($r.output ?? 0) + ($x.cache5m + $unsplit)*($r.cacheWrite5m ?? 0) + $x.cache1h*($r.cacheWrite1h ?? 0) + $x.cacheRead*($r.cacheRead ?? 0)) / 1e6 } }
    $out += [pscustomobject]@{ step=$sid; model=$grp.Name; input=$sum.input; output=$sum.output; cacheWrite=$sum.cacheWrite; cacheRead=$sum.cacheRead
      requests=$grp.Count; costUsd=$(if ($priced) { [math]::Round($cost,4) } else { $null }); elapsedSeconds=$(if ($null -ne $elapsed) { [int]$elapsed } else { $null })
      turns=($turns[$sid] ?? 0); decisions=($decisions[$sid] ?? 0); subAgentCalls=($agents[$sid] ?? 0); webRequests=($web[$sid] ?? 0) }
  }
}
if ($Step -and -not $out) { $notes += "no transcript lines fall inside step $Step's window — check its startedAt/completedAt in ocpfFramework/state/usage.json" }
}

function Get-ObjectCounts($root, $edition) {
  # Objects by type from the Object Register (Full) or the Design Doc's object table (Lite): every Markdown
  # table with an ID and a Type column, keyed by (type, ID) — BC IDs are unique per object type.
  $candidates = @(@("full", "docs/1-define/ObjectRegister.md"), @("lite", "docs/2-design/DesignDoc.md"))
  if ($edition -eq "lite") { [array]::Reverse($candidates) }
  foreach ($c in $candidates) {
    $path = Join-Path $root $c[1]; if (-not (Test-Path $path)) { continue }
    $lines = Get-Content $path; $byKey = @{}; $i = 0
    while ($i -lt $lines.Count) {
      $line = $lines[$i].Trim()
      if ($line.StartsWith("|") -and ($i + 1) -lt $lines.Count -and $lines[$i + 1].Trim() -match '^\|[\s:|-]+\|$') {
        $header = @($line.Trim('|').Split('|') | ForEach-Object { ($_ -replace '[`*]', '').Trim().ToLower() })
        $idCol = [array]::IndexOf($header, "id"); $typeCol = [array]::IndexOf($header, "type")
        if ($idCol -lt 0 -or $typeCol -lt 0) { $i++; continue }
        $i += 2
        while ($i -lt $lines.Count -and $lines[$i].Trim().StartsWith("|")) {
          $cells = @($lines[$i].Trim().Trim('|').Split('|') | ForEach-Object { ($_ -replace '[`*]', '').Trim() })
          if ($cells.Count -gt [math]::Max($idCol, $typeCol)) {
            $oid = $cells[$idCol]; $otype = $cells[$typeCol]
            if ($oid -and -not $oid.StartsWith("<") -and $otype -and -not $otype.StartsWith("<")) { $byKey["$otype|$oid"] = $otype }
          }
          $i++
        }
        continue
      }
      $i++
    }
    if ($byKey.Count -gt 0) {
      $byType = [ordered]@{}; foreach ($t in ($byKey.Values | Sort-Object)) { $byType[$t] = 1 + ($byType[$t] ?? 0) }
      return @{ source = $c[1]; byType = $byType; total = $byKey.Count }
    }
  }
  return @{ source = $null; byType = @{}; total = 0; note = "no object table with ID and Type columns found in docs/1-define/ObjectRegister.md or docs/2-design/DesignDoc.md" }
}

if ($Calibrate) {
  $marker = Load-Json (Join-Path $root "ocpfFramework/framework.json") @{}
  $app = Load-Json (Join-Path $root "app.json") @{}
  $name = if ($app.name) { $app.name } else { Split-Path -Leaf $root }
  $steps = [ordered]@{}
  foreach ($r in $out) {
    if (-not $steps.Contains($r.step)) { $steps[$r.step] = [ordered]@{ step=$r.step; elapsedSeconds=$r.elapsedSeconds; turns=$r.turns; decisions=$r.decisions; subAgentCalls=$r.subAgentCalls; models=@() } }
    $entry = [ordered]@{ model=$r.model; input=$r.input; output=$r.output; cacheWrite=$r.cacheWrite; cacheRead=$r.cacheRead; requests=$r.requests; costUsd=$r.costUsd }
    if ($isCopilot) { $entry.aiCredits = $r.aiCredits; $entry.role = $r.role }
    $steps[$r.step].models += $entry
  }
  $tot = @{ input=0; output=0; cacheWrite=0; cacheRead=0 }; $tcost = 0.0; $unpriced = $false; $elapsed = 0; $measuredOutput = 0; $credits = 0.0
  $hasTokens = -not $isCopilot
  foreach ($s in $steps.Values) {
    if ($s.elapsedSeconds) { $elapsed += $s.elapsedSeconds; foreach ($m in $s.models) { $measuredOutput += ($m.output ?? 0) } }
    foreach ($m in $s.models) { $credits += ($m.aiCredits ?? 0); foreach ($k in @($tot.Keys)) { $tot[$k] += ($m[$k] ?? 0) }; if ($null -eq $m.costUsd) { $unpriced = $true } else { $tcost += $m.costUsd } }
  }
  $objects = Get-ObjectCounts $root $marker.edition
  if ($objects.note) { $notes += $objects.note }
  $data = [ordered]@{
    framework = "OCPF BC Agentic Development Framework"; calibrationSchema = 1
    project = $name; projectRoot = $root; edition = $marker.edition
    runbookVersion = $marker.runbookVersion; pluginVersion = $marker.pluginVersion
    aiTool = $usageDoc.aiTool; writtenAt = [datetime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
    pricing = [ordered]@{ fetchedAt = $pricingDoc.fetchedAt; sources = @((@($rates.Values | ForEach-Object { $_.source }) + @($pricingDoc.aiCredit.source)) | Where-Object { $_ } | Sort-Object -Unique); usdPerAiCredit = $(if ($pricingDoc.aiCredit) { $pricingDoc.aiCredit.usd } else { $null }) }
    steps = @($steps.Values)
    totals = [ordered]@{ input=$(if ($hasTokens) { $tot.input }); output=$(if ($hasTokens) { $tot.output }); cacheWrite=$(if ($hasTokens) { $tot.cacheWrite }); cacheRead=$(if ($hasTokens) { $tot.cacheRead }); aiCredits=$(if ($credits) { [math]::Round($credits, 1) }); costUsd=[math]::Round($tcost,4); costIncomplete=$unpriced; elapsedSeconds=$elapsed }
    throughput = [ordered]@{ outputTokensPerSecond = $(if ($elapsed -and $hasTokens) { [math]::Round($measuredOutput / $elapsed, 2) } else { $null }); basis = "output tokens ÷ elapsed seconds over the steps that have timestamps; the AI Effort Estimate's wall-clock default is 50 when this is null" }
    objects = $objects; notes = $notes
  }
  $folder = Join-Path $HOME ".ocpf/calibration"; New-Item -ItemType Directory -Force -Path $folder | Out-Null
  $slug = (($name -replace '[^A-Za-z0-9._-]+', '-').Trim('-')); if (-not $slug) { $slug = "project" }
  $path = Join-Path $folder ("{0}-{1}.json" -f $slug, [datetime]::UtcNow.ToString("yyyy-MM-dd"))
  $data | ConvertTo-Json -Depth 6 | Set-Content -Path $path -Encoding utf8
  $path; exit 0
}
function HM($sec) { if ($null -eq $sec) { "n/a — no timestamps" } else { "{0}h {1:00}m" -f [int][math]::Floor($sec/3600), [int][math]::Floor(([int]$sec % 3600)/60) } }
if ($isCopilot) {
  $src = if ($pricingDoc.aiCredit -and $pricingDoc.aiCredit.source) { $pricingDoc.aiCredit.source } else { "none fetched" }
  if ($Json) { [ordered]@{ aiTool="copilot-chat"; sessionDirs=$cpDirs; files=$cpFiles.Count; usdPerAiCredit=$usdPerCredit; pricingSource=$src; pricingFetchedAt=$pricingDoc.fetchedAt; sessionTotalCredits=[math]::Round((Snap-Total $current), 1); rows=$out; notes=$notes } | ConvertTo-Json -Depth 5; exit 0 }
  "| Step | Model(s) | AI credits | Cost (USD) | Elapsed | Turns | Decisions | Sub-agent calls | Senior AL dev est. (h) | Notes |"
  "|---|---|---|---|---|---|---|---|---|---|"
  $tc = 0.0; $tcost = 0.0; $unpriced = $false; $shown = @{}
  foreach ($r in $out) {
    $c = if ($null -ne $r.costUsd) { $tcost += $r.costUsd; ([double]$r.costUsd).ToString("F2", $inv) } else { $unpriced = $true; "price unknown" }
    $tc += $r.aiCredits
    $first = -not $shown.ContainsKey($r.step); $shown[$r.step] = $true
    $el = if ($first) { HM $r.elapsedSeconds } else { "〃" }; $tu = if ($first) { $r.turns } else { "〃" }; $de = if ($first) { $r.decisions } else { "〃" }; $sa = if ($first) { $r.subAgentCalls } else { "〃" }
    $note = switch ($r.role) { "main" { "main, $($r.calls) turn(s)" } "sub-agent" { "sub-agent, $($r.calls) call(s)" } "session" { "billed between turns" } "all" { "read from the popover by the human — no model breakdown" } default { $r.role } }
    "| $($r.step) | $($r.model) | $(([double]$r.aiCredits).ToString('N1', $inv)) | $c | $el | $tu | $de | $sa |  | $note |"
  }
  "| **Total** |  | $($tc.ToString('N1', $inv)) | $($tcost.ToString('F2', $inv))$(if ($unpriced) { ' + unpriced' }) |  |  |  |  |  |  |"
  $where = if ($cpManual) { "the Session Info popover, read by the human" } else { "$($cpFiles.Count) chat session file(s) in $($cpDirs -join ', ')" }
  $rate = if ($null -ne $usdPerCredit) { '$' + $usdPerCredit.ToString('0.####', $inv) } else { "price unknown" }
  ""; "*AI credits as GitHub Copilot Chat recorded them, sub-agents included; Copilot Chat records no token totals by type. 1 AI credit = ${rate}: $src, read $($pricingDoc.fetchedAt ?? 'n/a'). Source: $where.*"
  foreach ($n_ in $notes) { "*Note: $n_*" }
  exit 0
}
if ($Json) { @{ transcriptDir=$tdir; files=$files.Count; pricingSource=$pricingDoc.fetchedAt; rows=$out; notes=$notes } | ConvertTo-Json -Depth 5; exit 0 }
"| Step | Model(s) | Input | Output | Cache write | Cache read | Cost (USD) | Elapsed | Turns | Decisions | Sub-agent calls | Senior AL dev est. (h) | Notes |"
"|---|---|---|---|---|---|---|---|---|---|---|---|---|"
$tot = @{ input=0; output=0; cacheWrite=0; cacheRead=0 }; $tcost = 0.0; $unpriced = $false; $shown = @{}
foreach ($r in $out) {
  $c = if ($null -ne $r.costUsd) { $tcost += $r.costUsd; ([double]$r.costUsd).ToString("F2", $inv) } else { $unpriced = $true; "price unknown" }
  foreach ($k in @($tot.Keys)) { $tot[$k] += $r.$k }
  $first = -not $shown.ContainsKey($r.step); $shown[$r.step] = $true
  $el = if ($first) { HM $r.elapsedSeconds } else { "〃" }; $tu = if ($first) { $r.turns } else { "〃" }; $de = if ($first) { $r.decisions } else { "〃" }; $sa = if ($first) { $r.subAgentCalls } else { "〃" }
  $note = "$($r.requests) requests" + $(if ($r.webRequests) { ", $($r.webRequests) web" } else { "" })
  "| $($r.step) | $($r.model) | $('{0:N0}' -f $r.input) | $('{0:N0}' -f $r.output) | $('{0:N0}' -f $r.cacheWrite) | $('{0:N0}' -f $r.cacheRead) | $c | $el | $tu | $de | $sa |  | $note |"
}
"| **Total** |  | $('{0:N0}' -f $tot.input) | $('{0:N0}' -f $tot.output) | $('{0:N0}' -f $tot.cacheWrite) | $('{0:N0}' -f $tot.cacheRead) | $($tcost.ToString('F2', $inv))$(if ($unpriced) { ' + unpriced' }) |  |  |  |  |  |  |"
$src = ($rates.Values | ForEach-Object { $_.source } | Where-Object { $_ } | Sort-Object -Unique) -join ", "; if (-not $src) { $src = "none fetched" }
""; "*Prices: $src, read $($pricingDoc.fetchedAt ?? 'n/a'). Transcripts: $tdir ($($files.Count) files).*"
foreach ($n_ in $notes) { "*Note: $n_*" }
