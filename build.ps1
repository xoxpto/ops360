# build.ps1 — correr Pester em iamlite e supportkit + PSScriptAnalyzer

# Garantir Pester
try {
  if (-not (Get-Module -ListAvailable -Name Pester)) {
    Set-PSRepository PSGallery -InstallationPolicy Trusted
    Install-Module Pester -Scope CurrentUser -Force -SkipPublisherCheck
  }
} catch {
  Write-Warning "Não foi possível instalar Pester: $($_.Exception.Message)"
}

$errors = 0

Write-Host "`n==> IAMLite" -ForegroundColor Cyan
Push-Location .\iamlite\tests
try {
  Invoke-Pester -CI -Output Detailed
} catch {
  $errors++
} finally {
  Pop-Location
}

Write-Host "`n==> SupportKit" -ForegroundColor Cyan
Push-Location .\supportkit\tests
try {
  Invoke-Pester -CI -Output Detailed
} catch {
  $errors++
} finally {
  Pop-Location
}

Write-Host "`n==> PSScriptAnalyzer" -ForegroundColor Cyan
try {
  # chama o script de análise na raiz do repo
  .\analyze.ps1
} catch {
  $errors++
}

if ($errors -gt 0) {
  throw "Falharam $errors suites de validação (tests/análise)."
}

Write-Host "`n✔ Tudo OK" -ForegroundColor Green
