Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
try { Set-PSRepository PSGallery -InstallationPolicy Trusted } catch {}
try { Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null } catch {}
try { Install-Module Pester -Scope CurrentUser -Force -MinimumVersion 5.5.0 -Repository PSGallery -SkipPublisherCheck } catch {}
try { Import-Module Pester -Force } catch {}
Invoke-Pester -Path tests
git commit --allow-empty -m "ci: trigger after heartbeat wrap"
