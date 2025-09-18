function Test-Workstation {
  [CmdletBinding()]
  param([switch]$Json)

  # Disk
  $disk = Get-PSDrive -Name C -PSProvider FileSystem | Select-Object Used,Free
  $freeGB = [math]::Round($disk.Free / 1GB, 1)
  $diskOk = $freeGB -ge 10

  # Services
  $svc = @("wuauserv","lanmanworkstation") | ForEach-Object {
    try { (Get-Service $_).Status } catch { "Unknown" }
  }
  $servicesOk = -not ($svc -contains "Stopped")

  # Network (ping 8.8.8.8)
  $ping = Test-Connection -Count 1 -Quiet 8.8.8.8
  $networkOk = [bool]$ping

  # Windows Update pending reboot (heurística simples)
  $pendingReboot = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -ErrorAction SilentlyContinue) -ne $null

  $result = [ordered]@{
    DiskOK          = $diskOk
    FreeSpaceGB     = $freeGB
    ServicesOK      = $servicesOk
    WindowsUpdate   = @{ PendingReboot = $pendingReboot }
    NetworkOK       = $networkOk
    Timestamp       = (Get-Date).ToString("s")
  }

  if ($Json) { $result | ConvertTo-Json -Depth 5 } else { [pscustomobject]$result }
}
