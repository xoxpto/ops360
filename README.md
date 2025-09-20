# ops360

[![CI](https://github.com/xoxpto/ops360/actions/workflows/ci.yml/badge.svg)](https://github.com/xoxpto/ops360/actions/workflows/ci.yml)

Coleção de módulos PowerShell para operações:
- **IAMLite** — helpers leves para IAM (ex.: criação de utilizadores via CSV).
- **SupportKit** — utilitários de suporte (ex.: Test-Workstation com -Json e -MinFreePct).

## Estrutura
iamlite/
  src/IAMLite/{IAMLite.psd1,IAMLite.psm1,Public/New-UserFromCsv.ps1}
  tests/IAMLite.Tests.ps1
supportkit/
  src/SupportKit/{SupportKit.psd1,SupportKit.psm1,Public/Test-Workstation.ps1}
  tests/SupportKit.Tests.ps1
build.ps1
ci.yml

## Requisitos
- Windows PowerShell 5.1 ou PowerShell 7+
- Pester 5.x (instala automaticamente no uild.ps1)

## Usar localmente
# IAMLite
Import-Module .\iamlite\src\IAMLite\IAMLite.psd1 -Force
New-UserFromCsv -Path .\iamlite\samples\users.sample.csv

# SupportKit
Import-Module .\supportkit\src\SupportKit\SupportKit.psd1 -Force
Test-Workstation -MinFreePct 15 -Json | ConvertFrom-Json | Format-Table

## Testes
.\build.ps1
# ou individualmente:
Invoke-Pester -CI -Output Detailed -Path .\iamlite\tests
Invoke-Pester -CI -Output Detailed -Path .\supportkit\tests

## CI
O workflow ci.yml corre os testes Pester em windows-latest.

## Notas
- Fim de linha normalizado para **LF** via .gitattributes.
- Para renormalizar:
  git add --renormalize .
  git commit -m "chore: normalize line endings"
