function New-UserFromCsv {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateScript({ Test-Path $_ })]
        [string]$Path,
        [switch]$Json
    )

    try { $rows = Import-Csv -Path $Path } catch { throw "Falha a ler CSV: $($_.Exception.Message)" }
    if (-not $rows) { throw "CSV sem registos." }

    $out = foreach ($u in $rows) {
        $obj = [pscustomobject]@{
            Name              = $u.Name
            SamAccountName    = $u.SamAccountName
            GivenName         = $u.GivenName
            Surname           = $u.Surname
            DisplayName       = $u.DisplayName
            UserPrincipalName = $u.UserPrincipalName
        }

        # Exemplo de ação protegida por WhatIf
        if ($PSCmdlet.ShouldProcess($obj.SamAccountName, "Provisionar utilizador")) {
            # Aqui seria New-ADUser @params
            # Neste esqueleto não fazemos nada real.
        }
        $obj
    }

    if ($Json) { $out | ConvertTo-Json -Depth 4 } else { $out }
}
