# OCPF BC Agentic Development Framework — Custom Skills: inspect, unpack, and check (Ops § Custom Skills), PowerShell port.
# Mirrors ocpf-skills.py (the reference implementation) and prints the same JSON — keys sorted, compact — for the same input.
# Reads and prints only; never writes the register, the harness folders, or any project file: the agent is the single writer.
# Needs PowerShell 7 (pwsh). Internal variables avoid the parameter names (PowerShell names are case-insensitive).
#   pwsh ocpf-skills.ps1 -Inspect <skill folder> [-FrameworkVersion x.y.z.w] [-Edition full|lite|feature] [-ExtensionPoints <file>] [-Register <file>]
#   pwsh ocpf-skills.ps1 -Unpack <file.zip> -Into <folder>
#   pwsh ocpf-skills.ps1 -Check -Project <root>
#   pwsh ocpf-skills.ps1 -Hash <folder>
# -Quiet makes every failure silent with exit 0 and no output. The rules are the Python twin's docstring, verbatim in effect.
param([string]$Inspect, [string]$Unpack, [string]$Into, [switch]$Check, [string]$Project = ".", [string]$Hash,
      [string]$FrameworkVersion, [string]$Edition, [string]$ExtensionPoints, [string]$Register, [switch]$Quiet)
$ErrorActionPreference = "Stop"
try {
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
$UTF8 = [Text.UTF8Encoding]::new($false, $true)   # strict, like Python's utf-8 reader: an invalid byte refuses the file on both twins
$SLUG_RE = '^[a-z][a-z0-9_]{2,39}$'
$RESERVED = @("ocpf_", "bcskills_", "onlycopilotfans_", "obcf_")
$FRAMEWORK_NAME = "OCPF BC Agentic Development Framework"
$ALLOWED_EXT = @(".md", ".txt", ".json", ".png", ".jpg", ".jpeg")
$ALLOWED_BARE = @("LICENSE", "LICENCE", "README", "CHANGELOG", "NOTICE", ".gitignore", ".gitattributes")
$REFUSED_DIRS = @("scripts", "agents", "hooks", ".claude", ".github", ".vscode", "node_modules")
$REFUSED_NAMES = @("hooks.json", ".mcp.json", "mcp.json")
$CODE_EXT = @(".ps1", ".py", ".sh", ".svg", ".cmd", ".bat", ".js", ".ts", ".exe", ".dll")
$JOURNEYS = @("full", "lite", "feature"); $HARNESSES = @("claude-code", "copilot")
$ZIP_MAX_ENTRIES = 200; $ZIP_MAX_ENTRY = 2 * 1024 * 1024
$ARCHIVE_EXT = @(".zip", ".7z", ".rar", ".tar", ".gz", ".tgz", ".bz2", ".xz", ".jar", ".app")
$DROPPINGS = @(".ds_store", "thumbs.db", "desktop.ini")  # left by Finder and Explorer; never part of a skill, never hashed, never refused
$DEFAULT_POINTS = @{ extends = [ordered]@{ referenceSources = "active"; preReviewChecks = "active"; codeReviewChecks = "active"; documents = "reserved"; steps = "reserved"; intakeQuestions = "reserved"; analyzeOutputs = "reserved" }
                     overrides = [ordered]@{ documentTemplates = "active"; modelRecommendations = "active"; companionOffers = "active" } }

# ---- JSON in and out, matching the Python twin (System.Text.Json in; sorted keys, compact, non-ASCII kept out) ----
function Convert-JsonElement($e) {
  switch ($e.ValueKind) {
    ([System.Text.Json.JsonValueKind]::Object) { $h = [ordered]@{}; foreach ($p in $e.EnumerateObject()) { $h[$p.Name] = Convert-JsonElement $p.Value }; return $h }
    ([System.Text.Json.JsonValueKind]::Array) { $a = @(); foreach ($x in $e.EnumerateArray()) { $a += , (Convert-JsonElement $x) }; return , $a }
    ([System.Text.Json.JsonValueKind]::String) { return $e.GetString() }
    ([System.Text.Json.JsonValueKind]::Number) { $l = [int64]0; if ($e.TryGetInt64([ref]$l)) { return $l }; return $e.GetDouble() }
    ([System.Text.Json.JsonValueKind]::True) { return $true }
    ([System.Text.Json.JsonValueKind]::False) { return $false }
    default { return $null } } }
function Load-Json($p) { if (-not (Test-Path -LiteralPath $p -PathType Leaf)) { return $null }
  try { $t = [IO.File]::ReadAllText($p, $UTF8); $opt = [System.Text.Json.JsonDocumentOptions]::new(); $opt.MaxDepth = 64; $opt.CommentHandling = [System.Text.Json.JsonCommentHandling]::Skip
    $doc = [System.Text.Json.JsonDocument]::Parse($t, $opt); try { Convert-JsonElement $doc.RootElement } finally { $doc.Dispose() } } catch { $null } }
function Sort-Keys($v) {
  if ($v -is [System.Collections.IDictionary]) { $o = [ordered]@{}; $keys = [string[]]@($v.Keys); [Array]::Sort($keys, [StringComparer]::Ordinal); foreach ($k in $keys) { $o[$k] = Sort-Keys $v[$k] }; return $o }
  if ($v -is [array]) { $a = @(); foreach ($x in $v) { $a += , (Sort-Keys $x) }; return , $a }
  $v }
function Out-Json($o) { (Sort-Keys $o) | ConvertTo-Json -Compress -Depth 64 }
function IsDict($v) { $v -is [System.Collections.IDictionary] }
function IsList($v) { ($v -is [array]) -or ($v -is [System.Collections.IList] -and -not (IsDict $v) -and $v -isnot [string]) }
function Get-Key($d, $k) { if ((IsDict $d) -and $d.Contains($k)) { $v = $d[$k]; if ($v -is [array]) { return , $v }; return $v } else { $null } }   # a one-element array must reach the caller as an array, not unrolled

# ---- rules ----
function VParts($v) { if ($v -is [string] -and $v -match '^\d+\.\d+\.\d+\.\d+$') { return , @($v.Split(".") | ForEach-Object { [int64]$_ }) }; $null }
function VCmp($a, $b) { for ($i = 0; $i -lt 4; $i++) { if ($a[$i] -lt $b[$i]) { return -1 }; if ($a[$i] -gt $b[$i]) { return 1 } }; 0 }
function Slug-Ok($s) { ($s -is [string]) -and ($s -cmatch $SLUG_RE) -and (-not $s.Contains("__")) -and (-not $s.EndsWith("_")) -and -not ($RESERVED | Where-Object { $s.StartsWith($_) }) }
function Slug-Problem($s) {
  if ($s -isnot [string] -or -not $s) { return "missing" }
  if ($s -cnotmatch $SLUG_RE) { return 'must match ^[a-z][a-z0-9_]{2,39}$ (lowercase letters, digits, underscore; starts with a letter; 3–40 characters)' }
  if ($s.Contains("__")) { return 'must not contain "__"' }
  if ($s.EndsWith("_")) { return 'must not end with "_"' }
  foreach ($r in $RESERVED) { if ($s.StartsWith($r)) { return "starts with a reserved prefix (" + ($RESERVED -join ", ") + ") — first-party names belong to the plugin" } }
  "" }
function Walk-Files($folder) {
  # relative paths (forward slashes), sorted ordinally, .git/ and the desktop droppings (.DS_Store, Thumbs.db, desktop.ini) excluded
  $base = (Get-Item -LiteralPath $folder).FullName.TrimEnd([IO.Path]::DirectorySeparatorChar)
  $out = [System.Collections.Generic.List[string]]::new()
  foreach ($f in @(Get-ChildItem -LiteralPath $base -File -Recurse -Force)) {
    if ($f.Name.ToLowerInvariant() -cin $DROPPINGS) { continue }
    $rel = $f.FullName.Substring($base.Length + 1).Replace([IO.Path]::DirectorySeparatorChar, "/")
    $segs = $rel.Split("/"); $skip = $false; for ($q = 0; $q -lt $segs.Count - 1; $q++) { if ($segs[$q] -ceq ".git") { $skip = $true } }   # a .git folder at any depth is skipped; a file named .git (a gitfile) is hashed, as the Python twin does
    if ($skip) { continue }
    $out.Add($rel) }
  $arr = $out.ToArray(); [Array]::Sort($arr, [StringComparer]::Ordinal); , $arr }
function Content-Hash($folder, $files) {
  $sha = [Security.Cryptography.SHA256]::Create(); $ms = [IO.MemoryStream]::new()
  foreach ($rel in $files) { $p = Join-Path $folder ($rel.Replace("/", [IO.Path]::DirectorySeparatorChar))
    $data = [byte[]]@(); try { $data = [IO.File]::ReadAllBytes($p) } catch { }
    $hdr = $UTF8.GetBytes($rel) + [byte]0 + [Text.Encoding]::ASCII.GetBytes("$($data.Length)") + [byte]0
    $ms.Write($hdr, 0, $hdr.Length); if ($data.Length) { $ms.Write($data, 0, $data.Length) } }
  "sha256:" + (($sha.ComputeHash($ms.ToArray()) | ForEach-Object { $_.ToString("x2") }) -join "") }
function Points-From($path) {
  $pts = $(if ($path) { Load-Json $path } else { $null })
  if (-not (IsDict $pts) -or -not (IsDict (Get-Key $pts "extends"))) { return @($DEFAULT_POINTS, $false) }
  $norm = { param($d) $o = [ordered]@{}; if (IsDict $d) { foreach ($k in $d.Keys) { $v = $d[$k]; $o[$k] = $(if (IsDict $v) { Get-Key $v "status" } else { "$v" }) } }; $o }
  , @(@{ extends = (& $norm (Get-Key $pts "extends")); overrides = (& $norm (Get-Key $pts "overrides")) }, $true) }
function File-Problem($rel) {
  $parts = $rel.Split("/")
  for ($i = 0; $i -lt $parts.Count - 1; $i++) { if ($parts[$i] -cin $REFUSED_DIRS) { return "folder '$($parts[$i])/' is not allowed in a skill (no code, no hooks, no servers, no sub-agents)" } }
  $name = $parts[-1]; $low = $name.ToLowerInvariant(); $ext = [IO.Path]::GetExtension($low)
  if ($low -cin $REFUSED_NAMES -or ($low.StartsWith("settings") -and $ext -eq ".json")) { return "'$name' is not allowed in a skill (no hooks, no MCP servers, no settings)" }
  if ($ext -cin $ALLOWED_EXT) { return "" }
  if ($ext -eq "" -and ($name -cin $ALLOWED_BARE -or $name.ToUpperInvariant() -cin $ALLOWED_BARE)) { return "" }
  if ($ext -cin $CODE_EXT) { return "'$name' is not allowed in a skill ($ext is code or a script carrier)" }
  "'$name' is not an allowed file kind (.md .txt .json .png .jpg .jpeg, LICENSE, README, CHANGELOG)" }
function Frontmatter-Name($skillMd) {
  try { $text = [IO.File]::ReadAllText($skillMd, $UTF8) } catch { return $null }
  if (-not $text.StartsWith("---")) { return $null }
  $end = $text.IndexOf("`n---", 3); if ($end -lt 0) { return $null }
  foreach ($line in $text.Substring(3, $end - 3) -split "`r?`n") { $m = [regex]::Match($line, '^\s*name\s*:\s*(.+?)\s*$'); if ($m.Success) { return $m.Groups[1].Value.Trim().Trim('"').Trim("'") } }
  $null }
function PyRepr($v) { if ($null -eq $v) { "None" } elseif ($v -is [string]) { "'" + $v.Replace("\", "\\").Replace("'", "\'") + "'" } else { "$v" } }   # Python's !r for a string or None, as the twin prints it

function Inspect-Skill($folder, $fwVersion, $edition, $pointsPath, $registerPath) {
  $res = [ordered]@{ ok = $false; slug = $null; displayName = $null; version = $null; renamedFrom = @(); contentHash = $null; files = @(); manifest = $null; errors = @(); warnings = @() }
  $E = { param($rule, $detail) $res.errors += , ([ordered]@{ rule = $rule; detail = $detail }) }
  $W = { param($rule, $detail) $res.warnings += , ([ordered]@{ rule = $rule; detail = $detail }) }
  if (-not (Test-Path -LiteralPath $folder -PathType Container)) { & $E "folder" "$folder is not a folder"; return $res }
  $files = Walk-Files $folder; $res.files = @($files); $res.contentHash = Content-Hash $folder $files
  $mp = Join-Path $folder "ocpf-skill.json"
  if (-not (Test-Path -LiteralPath $mp -PathType Leaf)) { & $E "manifest" "ocpf-skill.json is missing — only skills made for this framework load (skill-create writes one)"; return $res }
  $m = Load-Json $mp
  if (-not (IsDict $m)) { & $E "manifest" "ocpf-skill.json is not a JSON object"; return $res }
  $res.manifest = $m
  if ((Get-Key $m "ocpfCustomSkill") -ne 1) { & $E "manifest" "ocpfCustomSkill must be 1" }
  $fw = Get-Key $m "framework"; if (-not (IsDict $fw)) { $fw = @{} }
  if ((Get-Key $fw "name") -cne $FRAMEWORK_NAME) { & $E "framework" "framework.name must be `"$FRAMEWORK_NAME`"" }
  $slug = Get-Key $m "slug"; $res.slug = $(if ($slug -is [string]) { $slug } else { $null })
  $sp = Slug-Problem $slug; if ($sp) { & $E "slug" "slug $sp" }
  $rf = Get-Key $m "renamedFrom"; if ($null -eq $rf) { $rf = @() }
  $rfBad = -not (IsList $rf); if (-not $rfBad) { foreach ($x in @($rf)) { if (-not (Slug-Ok $x)) { $rfBad = $true } } }
  if ($rfBad) { & $E "renamedFrom" "renamedFrom must be a list of valid slugs" } else { $res.renamedFrom = @($rf) }
  if ($slug -and (IsList $rf) -and ($slug -cin @($rf))) { & $E "renamedFrom" "renamedFrom must not contain the slug itself" }
  $dn = Get-Key $m "displayName"; $res.displayName = $(if ($dn -is [string]) { $dn } else { $null })
  if (-not $res.displayName) { & $E "displayName" "displayName is required" }
  $desc = Get-Key $m "description"; if ($desc -isnot [string] -or -not $desc) { & $E "description" "description is required" }
  $ver = Get-Key $m "version"; $res.version = $(if ($ver -is [string]) { $ver } else { $null })
  if ($null -eq (VParts $ver)) { & $E "version" "version must be four-part, e.g. 1.0.0.0" }
  $au = Get-Key $m "author"; if (-not (IsDict $au)) { $au = $null }
  if (-not $au -or (Get-Key $au "name") -isnot [string] -or -not (Get-Key $au "name")) { & $E "author" "author.name is required (typed by the human, never inferred)" }
  if ($null -eq (VParts (Get-Key $fw "minVersion"))) { & $E "framework" "framework.minVersion must be a four-part version" }
  $mxRaw = Get-Key $fw "maxVersion"; if ($null -ne $mxRaw -and "$mxRaw" -ne "" -and $null -eq (VParts $mxRaw)) { & $E "framework" "framework.maxVersion must be null or a four-part version" }
  $js = Get-Key $m "journeys"; $jsBad = -not (IsList $js) -or @($js).Count -eq 0; if (-not $jsBad) { foreach ($j in @($js)) { if ($j -cnotin $JOURNEYS) { $jsBad = $true } } }
  if ($jsBad) { & $E "journeys" "journeys must be a non-empty list from full, lite, feature" }
  $hs = $(if ($m.Contains("harnesses")) { Get-Key $m "harnesses" } else { $HARNESSES }); $hsBad = -not (IsList $hs); if (-not $hsBad) { foreach ($h in @($hs)) { if ($h -cnotin $HARNESSES) { $hsBad = $true } } }
  if ($hsBad) { & $E "harnesses" "harnesses must be a list from claude-code, copilot" }
  $pp = Points-From $pointsPath; $pts = $pp[0]; $fromFile = $pp[1]
  $extRaw = Get-Key $m "extends"; $ext = $(if (IsDict $extRaw) { $extRaw } else { @{} })
  $ovrRaw = Get-Key $m "overrides"; $ovr = $(if (IsDict $ovrRaw) { $ovrRaw } else { @{} })
  if ($m.Contains("extends") -and -not (IsDict $extRaw)) { & $E "extends" "extends must be an object" }
  if ($m.Contains("overrides") -and -not (IsDict $ovrRaw)) { & $E "overrides" "overrides must be an object" }
  foreach ($k in @($ext.Keys)) { $v = $ext[$k]; if (-not $v -or ((IsList $v) -and @($v).Count -eq 0) -or ((IsDict $v) -and $v.Count -eq 0)) { continue }
    $st = Get-Key $pts.extends $k
    if ($null -eq $st) { & $E "extensionPoint" "extends.$k is not an extension point of this framework version" }
    elseif ($st -cne "active") { & $E "extensionPoint" "extends.$k is $st in this framework version — declared, not yet consulted; a skill that names it would silently not apply, so it is refused" }
    elseif (IsList $v) { foreach ($f in @($v)) { if ($f -isnot [string] -or -not (Test-Path -LiteralPath (Join-Path $folder ($f.Replace("/", [IO.Path]::DirectorySeparatorChar))) -PathType Leaf)) { & $E "extensionPoint" "extends.$k names $f, which is not a file in the skill" } } } }
  foreach ($k in @($ovr.Keys)) { $v = $ovr[$k]; if (-not $v -or ((IsList $v) -and @($v).Count -eq 0) -or ((IsDict $v) -and $v.Count -eq 0)) { continue }
    $st = Get-Key $pts.overrides $k
    if ($null -eq $st) { & $E "extensionPoint" "overrides.$k is not on the override allowlist" }
    elseif ($st -cne "active") { & $E "extensionPoint" "overrides.$k is $st in this framework version" } }
  foreach ($key in "conflictsWith", "requires") { $v = Get-Key $m $key; if ($null -eq $v) { continue }   # each under its own rule name, so a requires error reads as one
    if (-not (IsList $v)) { & $E $key "$key must be a list of slugs"; continue }
    foreach ($x in @($v)) { $name = $(if (IsDict $x) { Get-Key $x "slug" } else { $x }); if (-not (Slug-Ok $name)) { & $E $key "$key entries must name slugs ($name)" } } }
  foreach ($k in @($ovr.Keys)) { $v = $ovr[$k]; if ($null -eq $v -or -not (Get-Key $pts.overrides $k)) { continue }   # every override is an object; a documentTemplates value is a file in the skill
    if (-not (IsDict $v)) { & $E "extensionPoint" "overrides.$k must be an object"; continue }
    if ($k -ceq "documentTemplates") { foreach ($name in @($v.Keys)) { $f = $v[$name]; if ($f -isnot [string] -or -not (Test-Path -LiteralPath (Join-Path $folder ($f.Replace("/", [IO.Path]::DirectorySeparatorChar))) -PathType Leaf)) { & $E "extensionPoint" "overrides.documentTemplates.$name names $f, which is not a file in the skill" } } } }
  if ("SKILL.md" -cnotin $files) { & $E "skill" "SKILL.md is missing" }
  else { $fm = Frontmatter-Name (Join-Path $folder "SKILL.md")
    if ($slug -and (Slug-Ok $slug) -and $fm -cne $slug.Replace("_", "-")) { & $E "skill" "SKILL.md frontmatter name must be `"$($slug.Replace('_', '-'))`" (the slug with _ → -), found $(PyRepr $fm)" } }
  if ("README.md" -cnotin $files) { & $W "readme" "README.md is missing — how to load the skill goes there" }
  foreach ($rel in $files) { $fp = File-Problem $rel; if ($fp) { & $E "files" $fp } }
  if ($fwVersion) { $fv = VParts $fwVersion; $mn = VParts (Get-Key $fw "minVersion"); $mx = $(if (Get-Key $fw "maxVersion") { VParts (Get-Key $fw "maxVersion") } else { $null })
    if ($fv -and $mn -and (VCmp $fv $mn) -lt 0) { & $E "frameworkVersion" "needs framework ≥ $(Get-Key $fw 'minVersion'); this project is on $fwVersion" }
    if ($fv -and $mx -and (VCmp $fv $mx) -gt 0) { & $E "frameworkVersion" "framework.maxVersion is $(Get-Key $fw 'maxVersion'); this project is on $fwVersion — the skill's author must raise or remove maxVersion" } }
  if ($edition -and (IsList $js) -and ($edition -cnotin @($js))) { & $E "journey" "made for $(@($js) -join ', '); this project's journey is $edition" }
  if ($registerPath -and $slug) {
    $reg = Load-Json $registerPath; if (-not (IsDict $reg)) { $reg = @{} }
    $skills = Get-Key $reg "skills"; if (-not (IsDict $skills)) { $skills = @{} }
    $cur = Get-Key $skills $slug
    if (IsDict $cur) {
      $curAu = Get-Key $cur "author"; $ca = $(if (IsDict $curAu) { Get-Key $curAu "name" } else { $null })
      if ((Get-Key $cur "contentHash") -ceq $res.contentHash) { & $W "dedupe" "already loaded as $(Get-Key $cur 'displayName') $(Get-Key $cur 'version') (same content)" }
      elseif ($ca -and $au -and $ca -ceq (Get-Key $au "name")) {
        $nv = VParts $res.version; $cv = VParts (Get-Key $cur "version")
        $c = $(if ($nv -and $cv) { VCmp $nv $cv } elseif ($nv) { 1 } elseif ($cv) { -1 } else { 0 })   # Python compares () < (n,n,n,n): a missing version is the lowest
        if ($c -gt 0) { & $W "dedupe" "same slug and author as the loaded $(Get-Key $cur 'version'): a higher version — offer the upgrade (Ops § Custom Skills → 4)" }
        elseif ($c -lt 0) { & $W "dedupe" "same slug and author as the loaded $(Get-Key $cur 'version'): a lower version — keep the loaded one, append the source (Ops § Custom Skills → 4)" }
        else { & $E "dedupe" "same slug, author, and version as the loaded $(Get-Key $cur 'version') but different content — a modified copy of a released version; bump it with skill-update or remove the loaded one first (Ops § Custom Skills → 4)" } }
      else { $srcs = Get-Key $cur "sources"; $ref = ""; if ((IsList $srcs) -and @($srcs).Count) { $s0 = @($srcs)[0]; if (IsDict $s0) { $ref = "$(Get-Key $s0 'ref')" } }
        & $E "collision" "slug collision: $slug is already loaded from another author ($(if ($ca) { $ca } else { 'unknown' }), $ref); remove one" } }
    foreach ($old in $res.renamedFrom) { if (IsDict (Get-Key $skills $old)) { & $W "rename" "$old is loaded and this skill names it in renamedFrom — an upgrade offer to $slug, not a collision" } } }
  if (-not $fromFile -and $pointsPath) { & $W "extensionPoints" "$pointsPath not readable — the built-in list for this release was used" }
  $res.ok = ($res.errors.Count -eq 0)
  $res }

function Unpack-Skill($zipPath, $into) {
  $res = [ordered]@{ ok = $false; folder = $null; entries = 0; errors = @() }
  $E = { param($rule, $detail) $res.errors += , ([ordered]@{ rule = $rule; detail = $detail }) }
  if (-not (Test-Path -LiteralPath $zipPath -PathType Leaf)) { & $E "zip" "$zipPath is not a zip archive"; return $res }
  Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem
  $stem = [regex]::Replace([IO.Path]::GetFileNameWithoutExtension($zipPath), '[^A-Za-z0-9._-]', '-'); if (-not $stem) { $stem = "skill" }
  $dest = Join-Path $into $stem; $made = $false
  $z = $null
  try { $z = [IO.Compression.ZipFile]::OpenRead($zipPath) } catch { & $E "zip" "$zipPath is not a zip archive"; return $res }
  try {
    $infos = @($z.Entries); $res.entries = $infos.Count
    if ($infos.Count -gt $ZIP_MAX_ENTRIES) { & $E "zip" "$($infos.Count) entries — more than $ZIP_MAX_ENTRIES" }
    foreach ($i in $infos) { $n = $i.FullName
      if ($n.StartsWith("/") -or $n.StartsWith("\") -or $n -cmatch '^[A-Za-z]:') { & $E "zip" "absolute path in the archive: $n" }
      if ($n.Contains("\")) { & $E "zip" "backslash in an entry name: $n" }
      if (".." -cin $n.Split("/")) { & $E "zip" "'..' in an entry name: $n" }
      if ((($i.ExternalAttributes -shr 16) -band 0xF000) -eq 0xA000) { & $E "zip" "symlink entry: $n" }
      if ($i.Length -gt $ZIP_MAX_ENTRY) { & $E "zip" "$n is $($i.Length) bytes — over $ZIP_MAX_ENTRY" }
      if (-not $n.EndsWith("/") -and ([IO.Path]::GetExtension($n.ToLowerInvariant()) -cin $ARCHIVE_EXT)) { & $E "zip" "nested archive: $n" } }
    if ($res.errors.Count) { return $res }
    if (Test-Path -LiteralPath $dest) { & $E "zip" "$dest already exists — remove it or choose another --into"; return $res }
    New-Item -ItemType Directory -Force -Path $dest | Out-Null; $made = $true
    foreach ($i in $infos) {
      if ($i.FullName.EndsWith("/")) { New-Item -ItemType Directory -Force -Path (Join-Path $dest ($i.FullName.TrimEnd("/").Replace("/", [IO.Path]::DirectorySeparatorChar))) | Out-Null; continue }
      $target = Join-Path $dest ($i.FullName.Replace("/", [IO.Path]::DirectorySeparatorChar))
      New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
      [IO.Compression.ZipFileExtensions]::ExtractToFile($i, $target, $true) }
  } catch { if ($made) { try { Remove-Item -LiteralPath $dest -Recurse -Force -ErrorAction SilentlyContinue } catch { } }  # a partial folder would block the retry
    & $E "zip" $(if ($made) { "could not extract the archive: $($_.Exception.Message)" } else { "could not read the archive: $($_.Exception.Message)" }); return $res } finally { if ($z) { $z.Dispose() } }
  $inner = @(Get-ChildItem -LiteralPath $dest -Directory -Force | ForEach-Object Name)
  if (-not (Test-Path -LiteralPath (Join-Path $dest "ocpf-skill.json")) -and $inner.Count -eq 1 -and (Test-Path -LiteralPath (Join-Path (Join-Path $dest $inner[0]) "ocpf-skill.json"))) { $dest = Join-Path $dest $inner[0] }
  $res.folder = $dest; $res.ok = $true; $res }

function Check-Project($root) {
  $res = [ordered]@{ ok = $false; frameworkVersion = $null; edition = $null; skills = [ordered]@{}; issues = @() }
  $marker = Load-Json (Join-Path $root "ocpfFramework/framework.json"); if (-not (IsDict $marker)) { $marker = @{} }
  $res.frameworkVersion = Get-Key $marker "runbookVersion"; $res.edition = Get-Key $marker "edition"
  $regPath = Join-Path $root "ocpfFramework/customSkills.json"
  if (-not (Test-Path -LiteralPath $regPath -PathType Leaf)) { $res.ok = $true; return $res }
  $reg = Load-Json $regPath
  if (-not (IsDict $reg)) {   # a register that exists but does not parse must not open the gate
    $res.issues += , ([ordered]@{ slug = $null; rule = "register"; detail = "ocpfFramework/customSkills.json exists but is not valid JSON"; recommended = "fix or restore the register (git shows its last good version); the framework does not run until it reads" })
    return $res }
  $skills = Get-Key $reg "skills"; if (-not (IsDict $skills)) { $skills = @{} }
  $ptsPath = Join-Path $root "ocpfFramework/extensionPoints.json"
  $inspected = @{}
  $issue = { param($slug, $rule, $detail, $recommended) $res.issues += , ([ordered]@{ slug = $slug; rule = $rule; detail = $detail; recommended = $recommended }); $res.skills[$slug].issues += , ([ordered]@{ rule = $rule; detail = $detail }) }
  $names = [string[]]@($skills.Keys); [Array]::Sort($names, [StringComparer]::Ordinal)
  foreach ($slug in $names) {
    $s = $skills[$slug]; if (-not (IsDict $s)) { $s = @{} }
    $en = $(if ($s.Contains("enabled")) { [bool]$s["enabled"] } else { $true })
    $entry = [ordered]@{ version = (Get-Key $s "version"); enabled = $en; status = "disabled"; issues = @() }
    $res.skills[$slug] = $entry
    if (-not $en) { continue }
    $folder = "$(Get-Key $s 'folder')"; if ($folder.StartsWith("~")) { $folder = $HOME + $folder.Substring(1) }
    if (-not $folder -or -not (Test-Path -LiteralPath $folder -PathType Container)) { $entry.status = "missing"; & $issue $slug "folder" "the skill folder $(if ($folder) { $folder } else { '(none)' }) is not on this machine" "run skill-load on $slug's source again, or disable it"; continue }
    $r = Inspect-Skill $folder $res.frameworkVersion $res.edition $(if (Test-Path -LiteralPath $ptsPath) { $ptsPath } else { $null }) $null
    $inspected[$slug] = $r
    foreach ($e in $r.errors) { & $issue $slug $e.rule $e.detail "disable or remove $slug, or load a version that passes" }
    if ($r.slug -and $r.slug -cne $slug) { & $issue $slug "slug" "the folder's manifest says slug $($r.slug), the register says $slug" "reload $slug from its source" }
    if ($r.contentHash -and (Get-Key $s "contentHash") -and $r.contentHash -cne (Get-Key $s "contentHash")) { & $issue $slug "content" "the folder's content differs from what was loaded (the register's contentHash)" "run skill-update on $slug, or reload it, so the record matches the files" }
    $entry.status = $(if ($entry.issues.Count -eq 0) { "compatible" } else { "blocked" }) }
  $enabled = @($names | Where-Object { $res.skills[$_].enabled -and $inspected.ContainsKey($_) })
  $man = { param($s) $m = $inspected[$s].manifest; if (IsDict $m) { $m } else { @{} } }
  $owners = [ordered]@{}
  foreach ($s in $enabled) { $ov = Get-Key (& $man $s) "overrides"; if (-not (IsDict $ov)) { continue }
    foreach ($item in $ov.Keys) { $v = $ov[$item]; if (-not (IsDict $v)) { continue }; foreach ($name in $v.Keys) { $key = "$item.$name"; if (-not $owners.Contains($key)) { $owners[$key] = @() }; $owners[$key] += $s } } }
  $okeys = [string[]]@($owners.Keys); [Array]::Sort($okeys, [StringComparer]::Ordinal)
  foreach ($key in $okeys) { $ss = @($owners[$key]); if ($ss.Count -gt 1) { foreach ($s in $ss) { & $issue $s "override" "$($ss -join ', ') all override $key" "keep one of them, or create one skill that merges them (skill-create)"; $res.skills[$s].status = "blocked" } } }
  foreach ($s in $enabled) { $mm = & $man $s
    $cl = Get-Key $mm "conflictsWith"; if (-not (IsList $cl)) { $cl = @() }; $rl = Get-Key $mm "requires"; if (-not (IsList $rl)) { $rl = @() }
    foreach ($c in $cl) { if ($null -eq $c) { continue }; $name = $(if (IsDict $c) { Get-Key $c "slug" } else { $c }); if ($name -cin $enabled) { & $issue $s "conflictsWith" "$s declares a conflict with $name, which is loaded" "remove or disable one of them"; $res.skills[$s].status = "blocked" } }
    foreach ($rq in $rl) { if ($null -eq $rq) { continue }; $name = $(if (IsDict $rq) { Get-Key $rq "slug" } else { $rq }); if ($name -cnotin $enabled) { & $issue $s "requires" "$s requires $name, which is not loaded (or not enabled)" "load $name first, or disable $s"; $res.skills[$s].status = "blocked" } }
    foreach ($old in @($inspected[$s].renamedFrom)) { if ($old -cin $enabled) { & $issue $s "rename" "$s is the renamed $old, and both are loaded" "remove $old; $s replaces it"; $res.skills[$s].status = "blocked" } } }
  $res.ok = ($res.issues.Count -eq 0)
  $res }

function Full-Path($p) { if ($p.StartsWith("~")) { $p = $HOME + $p.Substring(1) }; [IO.Path]::GetFullPath($p) }
if ($Inspect) { Out-Json (Inspect-Skill (Full-Path $Inspect) $FrameworkVersion $Edition $ExtensionPoints $Register); exit 0 }
if ($Unpack) { if (-not $Into) { if ($Quiet) { exit 0 }; Write-Error "-Unpack needs -Into <folder>"; exit 1 }; Out-Json (Unpack-Skill (Full-Path $Unpack) (Full-Path $Into)); exit 0 }
if ($Check) { Out-Json (Check-Project (Full-Path $Project)); exit 0 }
if ($Hash) { $f = Full-Path $Hash; $files = Walk-Files $f; Out-Json ([ordered]@{ contentHash = (Content-Hash $f $files); files = @($files).Count }); exit 0 }
"usage: ocpf-skills.ps1 -Inspect <folder> | -Unpack <zip> -Into <folder> | -Check -Project <root> | -Hash <folder>"
exit 0
} catch { if ($Quiet) { exit 0 }; Write-Error $_; exit 1 }
