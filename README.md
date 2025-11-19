# ops360

[![CI](https://github.com/xoxpto/ops360/actions/workflows/ci.yml/badge.svg)](https://github.com/xoxpto/ops360/actions/workflows/ci.yml)

**ops360** é um conjunto modular de ferramentas PowerShell focado em operações IT, automação e suporte.  
Inclui utilitários leves para Identity & Access Management (IAM) e diagnóstico rápido de workstations, com testes automatizados e CI/CD.

---

## 🧭 Índice

- [Módulos incluídos](#-módulos-incluídos)
- [Requisitos](#-requisitos)
- [Instalação e utilização](#-instalação-e-utilização)
  - [IAMLite](#iamlite)
  - [SupportKit](#supportkit)
- [Testes e qualidade](#-testes-e-qualidade)
- [CI/CD](#-cicd)
- [Estrutura do projeto](#-estrutura-do-projeto)
- [Versionamento & Releases](#-versionamento--releases)
- [Roadmap](#-roadmap)
- [Licença](#-licença)
- [Contribuições](#-contribuições)

---

## ✨ Módulos incluídos

### IAMLite

Toolkit para automação de tarefas de IAM.

**Funcionalidades principais:**

- Criação de utilizadores a partir de ficheiro CSV
- Suporte para `-WhatIf` (seguro por defeito)
- Exportação em JSON (`-Json`)
- Estrutura modular clara (`psd1`, `psm1`, funções em `Public/`)

---

### SupportKit

Ferramentas de diagnóstico rápido para suporte técnico.

**Funcionalidades principais:**

- `Test-Workstation`: valida ping, uptime, espaço em disco e serviços essenciais
- Threshold configurável de espaço livre (`-MinFreePct`)
- Saída em objeto PowerShell ou JSON (`-Json`)

---

## 🖥️ Requisitos

- Windows PowerShell **5.1** ou PowerShell **7+**
- [Pester](https://github.com/pester/Pester) **5.x**  
  > Instalado automaticamente pelo `build.ps1` se ainda não existir.

---

## 📥 Instalação e utilização

### 1. Clonar o repositório

```powershell
git clone https://github.com/xoxpto/ops360.git
cd ops360

🧩 IAMLite
-Importar o módulo:
Import-Module .\iamlite\src\IAMLite\IAMLite.psd1 -Force

-Criar utilizadores a partir de CSV:
New-UserFromCsv -Path .\iamlite\samples\users.sample.csv

-Obter saída em JSON:
New-UserFromCsv -Path .\iamlite\samples\users.sample.csv -Json |
  ConvertFrom-Json |
  Format-Table Name, UserPrincipalName

-Simulação sem executar ações reais (-WhatIf):
New-UserFromCsv -Path .\iamlite\samples\users.sample.csv -WhatIf

🧩 SupportKit
-Importar o módulo:
Import-Module .\supportkit\src\SupportKit\SupportKit.psd1 -Force

-Verificar uma workstation com threshold de disco:
Test-Workstation -MinFreePct 15

-Saída em JSON:
Test-Workstation -MinFreePct 10 -Json |
  ConvertFrom-Json |
  Format-Table ComputerName, Status, FreePct

🧪 Testes e qualidade
O projeto usa Pester 5.x para testes e PSScriptAnalyzer para análise estática.

-Correr tudo (testes + análise)
.\build.ps1

-Correr testes de um módulo específico
Invoke-Pester -CI -Path .\iamlite\tests
Invoke-Pester -CI -Path .\supportkit\tests

-Correr apenas o PSScriptAnalyzer
.\analyze.ps1

🤖 CI/CD
O repositório inclui pipelines GitHub Actions:

-Workflow ci.yml (e/ou release.yml) corre em windows-latest.

-Executa:

--Testes Pester

--PSScriptAnalyzer

--Empacotamento dos módulos (.zip)

--Upload dos artefactos para as Releases quando são criadas tags v*.

Badge de estado no topo deste README mostra o resultado da última execução de CI.

📁 Estrutura do projeto

ops360/
├── iamlite/
│   ├── src/IAMLite/
│   │   ├── IAMLite.psd1
│   │   ├── IAMLite.psm1
│   │   └── Public/
│   │       └── New-UserFromCsv.ps1
│   └── tests/
│       └── IAMLite.Tests.ps1
│
├── supportkit/
│   ├── src/SupportKit/
│   │   ├── SupportKit.psd1
│   │   ├── SupportKit.psm1
│   │   └── Public/
│   │       └── Test-Workstation.ps1
│   └── tests/
│       └── SupportKit.Tests.ps1
│
├── build.ps1
├── analyze.ps1
├── release.ps1
├── ci.yml
├── .editorconfig
├── .gitattributes
├── .gitignore
└── LICENSE

🏷️ Versionamento & Releases

O versionamento é feito com tags vX.Y.Z e automatizado via release.ps1.

Criar uma nova versão incremental

.\release.ps1 -Bump Patch   # ou Minor / Major

Definir versão manual

.\release.ps1 -Version 0.1.3

O script release.ps1:

-Lê a versão atual (a partir da última tag v*)

-Calcula a próxima versão

-Atualiza os manifests (ModuleVersion nos .psd1)

-Corre build.ps1 (testes + análise)

-Faz commit

-Cria tag vX.Y.Z

-Faz git push + git push --tags

-Dispara o workflow de release no GitHub

🧭 Roadmap

 -0- Publicar módulos no PowerShell Gallery

 -0- Adicionar badges de versão e downloads

 -0- Criar novo módulo NetworkKit

 -0- Documentação com exemplos avançados e cenários reais

📝 Notas adicionais
- Fim de linha normalizado para LF via .gitattributes.
- Para renormalizar o repositório:

git add --renormalize .
git commit -m "chore: normalize line endings"

📄 Licença
Este projeto está licenciado sob a MIT License.
Consulta o ficheiro LICENSE para mais detalhes.

🤝 Contribuições
Issues e Pull Requests são bem-vindos.
