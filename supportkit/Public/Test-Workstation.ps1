function Test-Workstation {
    [CmdletBinding()]
    param(
        [string]$ComputerName = $env:COMPUTERNAME,
        [int]$MinFreePct = 10,
        [switch]$Json
    )

    Write-Verbose "A verificar $ComputerName (MinFreePct=$MinFreePct)..."

    $isLocal = $ComputerName -in '.', 'localhost', $env:COMPUTERNAME

    $result = [ordered]@{
        ComputerName = $ComputerName
        Ping         = $false
        UptimeDays   = $null
        DiskOK       = $false
        ServicesOK   = $false
        FreePct      = $null
        CheckedAt    = (Get-Date)
    }

    # Ping (se remoto; em local assume true)
    try {
        if ($isLocal) {
            $result.Ping = $true
        } else {
            $result.Ping = [bool](Test-Connection -ComputerName $ComputerName -Count 1 -Quiet -ErrorAction Stop)
        }
    } catch {
        Write-Warning "Ping falhou: $($_.Exception.Message)"
    }

    # Helpers CIM
    function Get-LocalCim($class, $filter) {
        if ($filter) { Get-CimInstance -ClassName $class -Filter $filter -ErrorAction Stop }
        else { Get-CimInstance -ClassName $class -ErrorAction Stop }
    }
    function Get-RemoteCim($class, $filter, $comp) {
        if ($filter) { Get-CimInstance -ClassName $class -ComputerName $comp -Filter $filter -ErrorAction Stop }
        else { Get-CimInstance -ClassName $class -ComputerName $comp -ErrorAction Stop }
    }

    # Uptime
    try {
        $os = if ($isLocal) {
            Get-LocalCim 'Win32_OperatingSystem' $null
        } else {
            Get-RemoteCim 'Win32_OperatingSystem' $null $ComputerName
        }
        if ($os.LastBootUpTime) {
            $uptime = (Get-Date) - $os.LastBootUpTime
            $result.UptimeDays = [math]::Round($uptime.TotalDays, 2)
        }
    } catch {
        Write-Warning "Falha ao obter uptime: $($_.Exception.Message)"
    }

    # Disco (C:)
    try {
        $disk = if ($isLocal) {
            Get-LocalCim 'Win32_LogicalDisk' "DeviceID='C:'"
        } else {
            Get-RemoteCim 'Win32_LogicalDisk' "DeviceID='C:'" $ComputerName
        }
        if ($disk.Size -and $disk.FreeSpace) {
            $freePct = [double](($disk.FreeSpace / $disk.Size) * 100)
            $result.FreePct = [math]::Round($freePct, 2)
            $result.DiskOK  = ($freePct -ge $MinFreePct)
        }
    } catch {
        Write-Warning "Falha ao obter disco: $($_.Exception.Message)"
    }

    # Serviços críticos (exemplo)
    try {
        $critical = 'LanmanWorkstation','Dhcp','Dnscache'
        $svc = if ($isLocal) {
            Get-Service -Name $critical
        } else {
            Get-Service -ComputerName $ComputerName -Name $critical
        }
        $stopped = $svc | Where-Object { $_.Status -ne 'Running' }
        $result.ServicesOK = (-not $stopped)
    } catch {
        Write-Warning "Falha ao verificar serviços: $($_.Exception.Message)"
    }

    if ($Json) {
        $result | ConvertTo-Json -Depth 4
    } else {
        [pscustomobject]$result
    }
}
