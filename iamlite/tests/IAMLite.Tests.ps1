BeforeAll {
  $script:CsvPath = (Resolve-Path "$PSScriptRoot\users.sample.csv").Path
  Import-Module (Resolve-Path "$PSScriptRoot\..\src\IAMLite\IAMLite.psd1") -Force
}
Describe "New-UserFromCsv" {
  It "parses CSV and returns two users" {
    $res = New-UserFromCsv -Path $script:CsvPath -Mock
    $res.Count | Should -Be 2
    $res[0].user.userPrincipalName | Should -Be "alice@contoso.com"
    $res[1].user.mailNickname      | Should -Be "bob"
  }
  It "emits valid JSON when -Json" {
    $json = New-UserFromCsv -Path $script:CsvPath -Mock -Json
    { $null = $json | ConvertFrom-Json } | Should -Not -Throw
  }
}
