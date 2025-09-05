Import-Module "$PSScriptRoot/../tools/CoAgent/CoAgent.Expiry.psm1" -Force
Describe "CoAgent.Expiry" {
  It "flags installs older than MaxHours as expired and fresh as not expired" {
    $tmp = Join-Path $env:TEMP ("coa_" + [IO.Path]::GetRandomFileName())
    New-Item -ItemType Directory -Path $tmp | Out-Null
    $env:COAGENT_STATE_DIR = $tmp
    # old stamp (~26h)
    $old = [DateTime]::UtcNow.AddHours(-26).ToString("o")
    $obj = @{ installedUtc = $old; version = "test" }
    ($obj | ConvertTo-Json) | Out-File -LiteralPath (Join-Path $tmp "install.json") -Encoding utf8
    (Test-CoAgentExpired -MaxHours 24) | Should -BeTrue
    # fresh stamp
    Write-CoAgentInstallStamp -Version "test"
    (Test-CoAgentExpired -MaxHours 24) | Should -BeFalse
    Remove-Item -Recurse -Force $tmp
    $env:COAGENT_STATE_DIR = $null
  }
}