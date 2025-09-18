Describe "Test-Workstation" {
  It "returns an object" {
    $r = Test-Workstation
    $r | Should -Not -BeNullOrEmpty
    $r | Should -HaveProperty DiskOK
  }
  It "can return JSON" {
    $j = Test-Workstation -Json
    { $null = $j | ConvertFrom-Json } | Should -Not -Throw
  }
}
