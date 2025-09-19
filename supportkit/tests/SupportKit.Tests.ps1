# Pester tests for SupportKit
Describe "SupportKit" {
  BeforeAll {
    $modulePath = Resolve-Path "$PSScriptRoot\..\src\SupportKit\SupportKit.psd1"
    Import-Module $modulePath -Force -Verbose
  }

  It "exports Test-Workstation" {
    Get-Command Test-Workstation -Module SupportKit | Should -Not -BeNullOrEmpty
  }

  It "runs and returns something" {
    $o = Test-Workstation
    $o | Should -Not -BeNullOrEmpty
    $o.ComputerName | Should -Not -BeNullOrEmpty
  }

  It "can return JSON" {
    $json = Test-Workstation -Json
    { $null = $json | ConvertFrom-Json } | Should -Not -Throw
  }

  It "respects -MinFreePct threshold" {
    $low  = Test-Workstation -MinFreePct 0
    $high = Test-Workstation -MinFreePct 100
    $low.DiskOK  | Should -BeTrue
    $high.DiskOK | Should -BeFalse
  }
}
