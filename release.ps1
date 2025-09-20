[CmdletBinding()]
param(
  [ValidateSet('Patch','Minor','Major')]
  [string]$Bump = 'Patch',
  [string]$Version,
  [string[]]$Manifests = @(
    ".\iamlite\src\IAMLite\IAMLite.psd1",
    ".\supportkit\src\SupportKit\SupportKit.psd1"
  )
)

function Get-NextVersion {
  param(
    [version]$cur,
    [string]$bump,
    [string]$explicit
  )
  if ($explicit) { return [version]$explicit }

  switch ($bump) {
    'Major' { return [version]::new($cur.Major + 1, 0, 0) }
    'Minor' { return [version]::new($cur.Major, $cur.Minor + 1, 0) }
    default {
      $nextBuild = if ($cur.Build -lt 0) { 1 } else { $cur.Build + 1 }
      return [version]::new($cur.Major, $cur.Minor, $nextBuild)
    }
  }
}

# 1) Ler versão atual do primeiro manifest
$curData = Import-PowerShellDataFile -Path $Manifests[0]
$curVer  = [version]$curData.ModuleVersion
$nextVer = Get-NextVersion -cur $curVer -bump $Bump -explicit $Version
Write-Host "Versão: $curVer -> $nextVer" -ForegroundColor Cyan

# 2) Atualizar todos os .psd1 (linha: ModuleVersion = 'x.y.z')
$regex = '(^\s*ModuleVersion\s*=\s*'')([^'']+)(''\s*$)'

foreach ($mf in $Manifests) {
  if (-not (Test-Path $mf)) { throw "Manifest não encontrado: $mf" }
  $text = Get-Content $mf -Raw
  if ($text -notmatch 'ModuleVersion') { throw "ModuleVersion não encontrado em $mf" }
  $new  = [regex]::Replace($text, $regex, "`$1$($nextVer.ToString())`$3", 'IgnoreCase, Multiline')
  Set-Content -Path $mf -Value $new -Encoding UTF8
}

# 3) Commit + tag + push
git add -- . | Out-Null
git commit -m "chore(release): bump version to v$nextVer" | Out-Null

# Evitar erro se a tag já existir
$tagName = "v$nextVer"
$existing = git tag --list $tagName
if (-not $existing) { git tag $tagName }

git push
git push --tags

Write-Host "Release $tagName criada e enviada. 🎉" -ForegroundColor Green
