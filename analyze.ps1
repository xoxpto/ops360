[CmdletBinding()]
param(
    [string[]] $Path = @(
        'iamlite\src\IAMLite',
        'supportkit\src\SupportKit'
    )
)

Write-Host "Running PSScriptAnalyzer..." 

# Garante que o módulo está disponível
if (-not (Get-Module PSScriptAnalyzer -ListAvailable)) {
    Write-Host "PSScriptAnalyzer não encontrado, a instalar para o utilizador atual..."
    Install-Module PSScriptAnalyzer -Scope CurrentUser -Force -ErrorAction Stop
}

Import-Module PSScriptAnalyzer -ErrorAction Stop

# Regras base (podes ir afinando mais tarde)
$rules = @(
    'PSUseDeclaredVarsMoreThanAssignments',
    'PSUseConsistentIndentation',
    'PSUseConsistentWhitespace',
    'PSAvoidUsingCmdletAliases',
    'PSUseApprovedVerbs'
)

$allResults = @()

foreach ($p in $Path) {
    if (-not (Test-Path $p)) {
        Write-Warning "Caminho não encontrado: $p"
        continue
    }

    Write-Host "Analisar: $p"
    $results = Invoke-ScriptAnalyzer -Path $p -Recurse -IncludeRule $rules -ErrorAction Stop
    if ($results) {
        $allResults += $results
    }
}

if ($allResults.Count -gt 0) {
    Write-Host ""
    Write-Host "❌ PSScriptAnalyzer encontrou $($allResults.Count) problema(s):"
    $allResults |
        Sort-Object Severity, RuleName |
        Format-Table RuleName, Severity, ScriptName, Line, Message -AutoSize

    throw "PSScriptAnalyzer falhou com $($allResults.Count) problema(s)."
}
else {
    Write-Host "✅ PSScriptAnalyzer: nenhum problema encontrado."
}
