function New-UserFromCsv {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [switch]$Mock,
        [switch]$Json,
        [string]$OutFile
    )

    if (-not (Test-Path -Path $Path -PathType Leaf)) {
        throw "CSV not found: $Path"
    }

    $rows = Import-Csv -Path $Path
    $results = @()

    foreach ($r in $rows) {
        $upn   = $r.UPN
        if (-not $upn) { throw "Missing UPN in CSV row: $($r | ConvertTo-Json -Compress)" }
        $alias = if ($r.Alias) { $r.Alias } else { ($upn -split "@")[0] }

        $groups = @()
        if ($r.Groups) {
            $groups = $r.Groups -split "[;,\|]" | ForEach-Object { $_.Trim() } | Where-Object { $_ }
        }

        $licenses = @()
        if ($r.Licenses) {
            $licenses = $r.Licenses -split "[;,\|]" | ForEach-Object { $_.Trim().ToUpper() } | Where-Object { $_ }
        }

        $user = [ordered]@{
            accountEnabled    = $true
            displayName       = $r.DisplayName
            mailNickname      = $alias
            userPrincipalName = $upn
            givenName         = $r.GivenName
            surname           = $r.Surname
            jobTitle          = $r.JobTitle
            department        = $r.Department
            usageLocation     = $r.UsageLocation
        }

        $payload = [ordered]@{
            type      = "User.Create"
            user      = $user
            groups    = $groups
            licenses  = $licenses
            mock      = $Mock.IsPresent
            timestamp = (Get-Date).ToString("s")
        }

        $results += [pscustomobject]$payload
    }

    if ($OutFile) {
        $dir = Split-Path -Parent $OutFile
        if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
        Remove-Item -Force -ErrorAction Ignore $OutFile
        foreach ($item in $results) {
            $item | ConvertTo-Json -Depth 6 | Out-File -FilePath $OutFile -Append -Encoding utf8
        }
    }

    if ($Json) { $results | ConvertTo-Json -Depth 6 } else { $results }

    if (-not $Mock) {
        Write-Warning "Real Microsoft Graph calls not implemented in MVP. Use -Mock por agora."
    }
}
