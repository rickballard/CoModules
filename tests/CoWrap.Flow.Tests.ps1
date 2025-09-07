#requires -Version 7
Describe "CoWrap → CoUnWrap flow (safe, non-CI)" -Tag 'cowrap-e2e' {
  BeforeAll {
    $script:_dl = Join-Path $env:TEMP ('cowrap_dl_' + [guid]::NewGuid())
    $script:_lc = Join-Path $env:TEMP ('cocl_'      + [guid]::NewGuid())
    New-Item -Type Directory -Force -Path $_dl,$_lc | Out-Null

    $script:_prevDl  = $env:COCACHE_DOWNLOADS
    $script:_prevLoc = $env:COCACHE_LOCAL
    $script:_prevSid = $env:COSESSION_ID

    $env:COCACHE_DOWNLOADS = $_dl
    $env:COCACHE_LOCAL     = $_lc
    $env:COSESSION_ID      = "TEST-" + [guid]::NewGuid()
  }

  It "produces a CoWrap zip" {
    & "$HOME\Downloads\CoCacheLocal\bin\Wrap.ps1" -ToSession 'ANY' -Agent 'T' | Out-Null
    $count = (Get-ChildItem $_dl -Filter 'CoWrap-*.zip' -ErrorAction SilentlyContinue | Measure-Object).Count
    $count | Should -BeGreaterThan 0
  }

  It "consumes it and marks the source as DELETABLE" {
    & "$HOME\Downloads\CoCacheLocal\bin\Unwrap.ps1" -Agent 'T' | Out-Null
    $count = (Get-ChildItem $_dl -Filter 'CoWrap_DELETABLE-*.zip' -ErrorAction SilentlyContinue | Measure-Object).Count
    $count | Should -Be 1
  }

  AfterAll {
    $env:COCACHE_DOWNLOADS = $_prevDl
    $env:COCACHE_LOCAL     = $_prevLoc
    $env:COSESSION_ID      = $_prevSid
    Remove-Item -Recurse -Force $_dl,$_lc -ErrorAction SilentlyContinue
  }
}
