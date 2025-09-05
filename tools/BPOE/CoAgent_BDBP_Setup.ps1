
<# 
  CoAgent_BDBP_Setup.ps1
  Purpose: Create CoAgent BDBP docs (private/public) + BDBP method note in the CoModules repo.
  Includes heartbeat indicators for potentially slow steps (fetch/push/PR).
  Author: ChatGPT (GPT-5 Thinking)
#>

[CmdletBinding()]
param(
  [string]$RepoPath = "$HOME\Documents\GitHub\CoModules",
  [string]$BranchName = ("docs/bdbp-coagent-" + (Get-Date -Format "yyMMdd-HHmm")),
  [switch]$SkipGit,
  [switch]$OpenPR,
  [switch]$UpdateReadme
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Import heartbeat helpers if present alongside script or in tools/BPOE
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$hb1 = Join-Path $here 'CoHeartbeat.psm1'
$hb2 = Join-Path $RepoPath 'tools\BPOE\CoHeartbeat.psm1'
if (Test-Path $hb1) { Import-Module $hb1 -Force }
elseif (Test-Path $hb2) { Import-Module $hb2 -Force }
else { Write-Host "[warn] CoHeartbeat.psm1 not found — proceeding without spinner." }

function Write-Utf8NoBom { param([string]$Path,[string]$Content)
  $utf8 = New-Object System.Text.UTF8Encoding($false)
  $lf = $Content -replace "`r`n", "`n" -replace "`r","`n"
  [System.IO.File]::WriteAllText($Path, $lf, $utf8)
}

function Ensure-Repo { 
  if (-not (Test-Path $RepoPath)) { throw "RepoPath not found: $RepoPath" }
  Set-Location $RepoPath
  git rev-parse --is-inside-work-tree *> $null
}

function Ensure-Branch { 
  param([string]$Name)
  if ($SkipGit) { return }
  try { Invoke-WithHeartbeat { git fetch --all --prune } -Activity "git fetch --all --prune" 2>$null } catch { git fetch --all --prune }
  try { git switch -c $Name | Out-Null } catch { git switch $Name | Out-Null }
}

function Ensure-Folders {
  $pubDir  = "docs/business/public"
  $privDir = "docs/business/private"
  $methDir = "docs/methods"
  New-Item -ItemType Directory -Force -Path $pubDir, $privDir, $methDir | Out-Null
}

# -------- Embedded documents (abridged public content to keep script size sane) --------
$PublicBP = @'
# CoAgent — Business Plan (Public Summary)
**Date:** 20250905  
**Mission:** Make it effortless and trustworthy for anyone to contribute to GitHub-centric work, across Windows, macOS, and Linux.

## What CoAgent Is
A tiny, signed agent (CLI + background service) that helps people **capture**, **prepare**, and **submit** their work to GitHub (Issues, PRs, Discussions) with clear status and built-in diagnostics.  It works offline, survives flaky networks, and keeps secrets in the OS keychain.

## Who It Helps (examples)
- **Open-source projects:** better-structured issues/PRs, faster triage.  
- **Enterprises:** standard, policy-locked paths for inner-source contributions; audit-friendly.  
- **NGOs & Schools:** offline capture, consent-aware submissions, easy onboarding across OSes.  
- **Civic projects (e.g., CoCivium):** consistent “Idea → Decision → Implementation” flows with traceability.

## Why It’s Different
- **Git-native** (no heavy runtimes); **signed & notarized**; **proxy-friendly**; and **template-driven** so submissions are higher quality.  
- **Cross-platform** from day one (Windows/macOS/Ubuntu).

## How It’s Offered
- **Free core (Apache-2.0):** enroll, queue, status/doctor, templates, signed releases with SBOMs.  
- **Paid extensions (later):** organization controls, SSO/SCIM, fleet management, audit exports, white-labelling, curated Job Packs.

## Roadmap (high-level)
Prototype → P0 General Availability (Windows/macOS/Ubuntu) → Enterprise controls → Mobile companions.

## CoCivium Example
For CoCivium contributors, CoAgent turns Idea Cards into Discussion threads or PRs using standard templates and preserves consent and provenance along the way.

For details and contributions, see the repository’s docs and roadmap.
'@

$PrivateBDBP = @'
# CoAgent — BDBP (Business-Development Business Plan) — **Private**
**Date:** 20250905  
**Owner:** CoModules / CoCivium (Rick — HumanGate ON)  
**Scope:** Investor + BizDev perspective for internal planning. Mirrors a public BP with additional candid details (pricing bands, partner strategy, risk notes).

## Segments & ICPs (prioritized)
- OSS maintainers & foundations (free → Pro seats)
- Civic/NGO networks (org plan)
- Enterprise DevEx/Platform (Enterprise)
- Education & Labs (site license)
- DAOs / web3 collectives (Pro/Enterprise)

## Top Use Cases (beyond CoCivium)
Issue/PR templating at scale; incident post-mortems; schema change requests; policy acknowledgements; non-PII security intake; homework pipeline; field research capture; internal RFCs; release-notes harvester; submit-once mirror-many.

## GTM & Pricing (confidential, rev-test)
Bottom-up OSS + top-down enterprise pilots.  Pro $4–8 seat/mo; Enterprise $2–5 per managed endpoint/mo with mins.

## Implementation (summary)
Rust binaries; GitHub App auth; native keychains; queue; TUF-verified updates via Winget/Homebrew/apt/dnf; systemd/LaunchAgents/Task Scheduler; SBOM + SLSA; proxy/offline; minimal telemetry; fleet policy in Enterprise.

## ROI Model (example)
500 engineers × 0.5 hr/wk saved × $100/hr ≈ $104k/year; Enterprise at $3/endpoint/mo × 500 = $18k/year; gross ROI ~6×.
'@

$Method = @'
# BDBP Method — Business-Development Business Plan
**Date:** 20250905  
Defines the BDBP perspective and dual public/private plan convention.  See docs/business/public and docs/business/private.  Update after releases and partner talks; archive superseded versions.
'@

# -------- Write files --------
Ensure-Repo
Ensure-Branch -Name $BranchName
Ensure-Folders

$pubFile  = "docs/business/public/CoAgent_BP_Public.md"
$privFile = "docs/business/private/CoAgent_BDBP_Private.md"
$methFile = "docs/methods/BDBP_METHOD.md"

Write-Utf8NoBom -Path $pubFile  -Content $PublicBP
Write-Utf8NoBom -Path $privFile -Content $PrivateBDBP
Write-Utf8NoBom -Path $methFile -Content $Method

if (-not $SkipGit) {
  git add $pubFile, $privFile, $methFile
  git commit -m "docs(bdbp): add CoAgent BDBP (private), public BP, and BDBP method; establish public/private business folders" | Out-Null
  try { Invoke-WithHeartbeat { git push -u origin (git branch --show-current) } -Activity "git push" 2>$null } catch { git push -u origin (git branch --show-current) }
  if ($OpenPR) {
    try { Invoke-WithHeartbeat { gh pr create --fill --label docs --label business } -Activity "gh pr create" 2>$null } catch { Write-Host "[warn] PR creation via gh failed — open via web if needed." }
  }
}

if ($UpdateReadme) {
$note = @"
> **Business-Development Business Plans (BDBP):** This repo maintains a public business plan under `docs/business/public/` and a private BDBP under `docs/business/private/`.  See `docs/methods/BDBP_METHOD.md` for rationale and maintenance cadence.
"@
  if (Test-Path "README.md") { Add-Content -Path "README.md" -Value "`n$note`n"; git add README.md; git commit -m "docs(bdbp): README note on BDBP public/private convention" | Out-Null }
}

Write-Host "`nDone.  Files written:"
Get-Item $pubFile, $privFile, $methFile | Format-Table Name,Length,LastWriteTime

# SIG # Begin signature block
# MIIFjAYJKoZIhvcNAQcCoIIFfTCCBXkCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDOPrUJXHtAVpOJ
# Sgf3+cAVVE4xXOtzLOMjoSCCf3cyYKCCAwQwggMAMIIB6KADAgECAhBA9a8p9kJq
# gEvoqXEAmoJ5MA0GCSqGSIb3DQEBCwUAMBgxFjAUBgNVBAMMDUNvTW9kdWxlcyBE
# ZXYwHhcNMjUwOTA1MTc1MDM5WhcNMjYwOTA1MTgxMDM5WjAYMRYwFAYDVQQDDA1D
# b01vZHVsZXMgRGV2MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2dw6
# iFLyaavQTn4hDT6SqThIesb3LnKHyCVOvUsJ0vL549+2JvMDvL9KENRvKswYB6kp
# OzPPn5PVOirYxXte/tGs6eKyWS0tUg2SVsEw1bSwZYv/47UjzyV5flEnPb5E0wkS
# q16dqL1a6xhCylkCWbbuc1k5xlP4cbdTJL/x/Z/Uc1MBd50LxcvzbbYXWsoQlxh9
# QhTMviBkOPUSJ7OH5EmoS1zWj9yMpMtQPWsHxOfDbx3LXIH+sJ9dFbY+Gzg+XmCt
# Biijkt1nO0ZHl41tcLOS1iwfpBP9efj7fAmCma9yLIuRk56nLIOXy14DKuCXMo6J
# M5GX8WRmwCyeP3GXMQIDAQABo0YwRDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAww
# CgYIKwYBBQUHAwMwHQYDVR0OBBYEFGDbSGZBfORpT4uijbMW5ShZ5UWyMA0GCSqG
# SIb3DQEBCwUAA4IBAQAnrvPwqigCpaNqluJEyfI4CgF+leKcPs9xzixdsMcS4llj
# i7w9Qxp/h2b/64RwRv7rO8NEXaryHyzSzfPpvsQj1I45P5gwumXZI8QCs8jz41MH
# aQ+4jwiw8DmZ0H66V8Vb//VbD/snw1b9Kfi5vA8j1nEe81NO8QEqnEW6JEP5Ca7t
# qjXwnVvA5WFdxFponab9/wh/JklFjcuz3sG6+YMhMyFlIluZkgpszEfzedstMao0
# pjssH3rqRPGCB6GbPiyfiBJ5kgqdiW9qRggcQxA2hfOX3VoCZ9M/I3DtCm69tn7F
# P2zM6krnx9LLjHpfjmfY8ZHOXDbO7fZ0lp3xJ8KOMYIB3jCCAdoCAQEwLDAYMRYw
# FAYDVQQDDA1Db01vZHVsZXMgRGV2AhBA9a8p9kJqgEvoqXEAmoJ5MA0GCWCGSAFl
# AwQCAQUAoIGEMBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkD
# MQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJ
# KoZIhvcNAQkEMSIEIM/DwS9jTDx/gA+FXjv9aHjDcYDdF2z9ezc0VsQkpZ0IMA0G
# CSqGSIb3DQEBAQUABIIBAFbX2preKCtEXYGOvA0r2y2i3SC4i74b2TdDm4cpXDuZ
# G2LH5184XJw38P12PGkVWlalPD9mLEJV6N1SGpWcjIP/srfJsWn+7QB4Inlwl53Y
# AluRPX2nSW6KYo+mTUiJiGNh34pznsLDLqWm1KCaWdueTPZymGPKrE7SWjnyQUCZ
# FV3CVbnaoaYN9HLoW06rSQjiuWW6IpIGDMJGu4oniQWJdC+Nt7KGueN9LIbR00Yt
# KT01E15PcRECbpNs1KeMZVtZTYdtYZDBu/dq7owAd9QaqBD51M/xX0BCpCe5dDme
# wgrspnsOyrBSShvVkmwy54SnPgVqc5GbzHI4zJr+mlg=
# SIG # End signature block
