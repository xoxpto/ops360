[CmdletBinding()]
param(
  [ValidateSet("Patch","Minor","Major")]
  [string]$Bump = "Patch",
  [string]$Version,
  [string[]]$Manifests = @(
    ".\iamlite\src\IAMLite\IAMLite.psd1",
    ".\supportkit\src\SupportKit\SupportKit.psd1"
  )
)

function Get-CurrentVersion {
  param([string]$text)
  $m = [regex]::Match($text, "(?m)^\s*ModuleVersion\s*=\s*'([^']+)'")
  if ($m.Success) { return [version]$m.Groups[1].Value } else { return $null }
}

function Get-NextVersion {
  param([version]$cur,[string]$bump,[string]$explicit)
  if ($explicit) { return [version]$explicit }
  if (-not $cur) { return [version]'0.1.0' }
  switch ($bump) {
    'Major' { return [version]::new($cur.Major+1,0,0) }
    'Minor' { return [version]::new($cur.Major,$cur.Minor+1,0) }
    default {
      $nextBuild = if ($cur.Build -lt 0) { 1 } else { $cur.Build + 1 }
      return [version]::new($cur.Major,$cur.Minor,$nextBuild)
    }
  }
}

# Ler versão atual (regex) e calcular próxima
$text0  = Get-Content $Manifests[0] -Raw
$curVer = Get-CurrentVersion $text0
$nextVer = Get-NextVersion -cur $curVer -bump $Bump -explicit $Version

$cv = if ($curVer) { $curVer } else { "<none>" }
Write-Host ("Versão: {0} -> {1}" -f $cv, $nextVer) -ForegroundColor Cyan

# Atualizar todos os manifests (só a ModuleVersion)
$rx = [regex]"(?m)^\s*(ModuleVersion\s*=\s*'')(?:[^'']*)(''\s*$)"
foreach ($mf in $Manifests) {
  if (-not (Test-Path $mf)) { throw "Manifest não encontrado: $mf" }
  $txt = Get-Content $mf -Raw
  if ($txt -notmatch 'ModuleVersion') { throw "ModuleVersion não encontrado em $mf" }
  $new = $rx.Replace($txt, "`$1$($nextVer.ToString())`$2")
  Set-Content -Path $mf -Value $new -Encoding UTF8
  Write-Host "Atualizado ModuleVersion em $mf" -ForegroundColor Green
}

# Commit + tag + push
git add -- . | Out-Null
git commit -m ("chore(release): bump version to v{0}" -f $nextVer) | Out-Null
$tag = "v$nextVer"
if (-not (git tag --list $tag)) { git tag $tag }
git push
git push --tags
Write-Host "Release $tag criada e enviada. 🎉" -ForegroundColor Green
