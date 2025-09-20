Describe "IAMLite" {
  BeforeAll {
    Import-Module "$PSScriptRoot\..\src\IAMLite\IAMLite.psd1" -Force
  }

  It "parses CSV and returns two users" {
    $users = New-UserFromCsv -Path "$PSScriptRoot\..\samples\users.sample.csv"
    $users.Count | Should -Be 2
    $users[0].SamAccountName | Should -Be "jdoe"
    $users[1].SamAccountName | Should -Be "jsmith"
  }

  It "emits valid JSON when -Json" {
    $json = New-UserFromCsv -Path "$PSScriptRoot\..\samples\users.sample.csv" -Json
    { $null = $json | ConvertFrom-Json } | Should -Not -Throw
  }

  It "honors -WhatIf (ShouldProcess)" {
    { New-UserFromCsv -Path "$PSScriptRoot\..\samples\users.sample.csv" -WhatIf } | Should -Not -Throw
  }
}
