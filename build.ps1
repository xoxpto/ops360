# build.ps1 — correr Pester em iamlite e supportkit

# Garantir Pester
try {
  if (-not (Get-Module -ListAvailable -Name Pester)) {
    Set-PSRepository PSGallery -InstallationPolicy Trusted
    Install-Module Pester -Scope CurrentUser -Force -SkipPublisherCheck
  }
} catch { Write-Warning "Não foi possível instalar Pester: $($_.Exception.Message)" }

$errors = 0

Write-Host "`n==> IAMLite" -ForegroundColor Cyan
Push-Location .\iamlite\tests
try { Invoke-Pester -CI -Output Detailed } catch { $errors++ } finally { Pop-Location }

Write-Host "`n==> SupportKit" -ForegroundColor Cyan
Push-Location .\supportkit\tests
try { Invoke-Pester -CI -Output Detailed } catch { $errors++ } finally { Pop-Location }

if ($errors -gt 0) { throw "Falharam $errors suites de teste." }
Write-Host "`n✔ Tudo OK" -ForegroundColor Green
