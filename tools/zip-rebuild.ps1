param([string]$OutCareer = 'dist/careerOS',[string]$OutLife='dist/lifeOS')
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
function Ensure-Dir([string]$p){ if(-not (Test-Path $p)){ New-Item -ItemType Directory -Path $p | Out-Null } }
Ensure-Dir $OutCareer; Ensure-Dir $OutLife
$tmp = Join-Path $env:TEMP ('zipbuild_' + [guid]::NewGuid())
New-Item -ItemType Directory $tmp | Out-Null

# ---- careerOS_generic_v3 ----
$coGen = Join-Path $tmp 'careerOS_generic_v3'; New-Item -ItemType Directory $coGen | Out-Null
if(Test-Path 'careerOS\templates\mentor_prompts.md'){ Copy-Item 'careerOS\templates\mentor_prompts.md' $coGen }
if(Test-Path 'careerOS\templates\vibecoding.md'){ Copy-Item 'careerOS\templates\vibecoding.md' $coGen }
if(Test-Path 'careerOS\data\career_paths.json'){ Copy-Item 'careerOS\data\career_paths.json' $coGen }
Set-Content (Join-Path $coGen 'README.md') '# careerOS generic v3 (samples)' -Encoding UTF8
Compress-Archive -Path (Join-Path $coGen '*') -DestinationPath (Join-Path $OutCareer 'careerOS_generic_v3.zip') -Force

# ---- careerOS_personalize_v3 ----
$coPer = Join-Path $tmp 'careerOS_personalize_v3'; New-Item -ItemType Directory $coPer | Out-Null
Set-Content (Join-Path $coPer 'README.md') '# careerOS personalize v3 — starter' -Encoding UTF8
$starterCo = '{"profile/resume.md":"# Resume — starter (replace)","strategy/market-map.md":"# Market Map — choose 1-2 paths to test first","strategy/job-targets.md":"# Job Targets — list 5 with comp bands + inclusivity notes"}'
Set-Content (Join-Path $coPer 'career_starter.json') $starterCo -Encoding UTF8
Set-Content (Join-Path $coPer 'populate.ps1') @('param([string]$RepoPath="",[switch]$Confirm)','if(-not $Confirm){ Write-Host "Use -Confirm"; exit 1 }','$starter = Get-Content (Join-Path (Split-Path $MyInvocation.MyCommand.Path) ''career_starter.json'') -Raw | ConvertFrom-Json','foreach($p in $starter.PSObject.Properties){','  $dest = Join-Path $RepoPath $p.Name','  New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null','  Set-Content $dest $p.Value -Encoding UTF8','}') -Encoding UTF8
Compress-Archive -Path (Join-Path $coPer '*') -DestinationPath (Join-Path $OutCareer 'careerOS_personalize_v3.zip') -Force

# ---- lifeOS_generic_v1 ----
$loGen = Join-Path $tmp 'lifeOS_generic_v1'; New-Item -ItemType Directory $loGen | Out-Null
if(Test-Path 'lifeOS\guides\diet_agent.md'){ Copy-Item 'lifeOS\guides\diet_agent.md' $loGen }
if(Test-Path 'lifeOS\guides\fitness_ai_friend.md'){ Copy-Item 'lifeOS\guides\fitness_ai_friend.md' $loGen }
if(Test-Path 'lifeOS\policies\values_guardrails.md'){ Copy-Item 'lifeOS\policies\values_guardrails.md' $loGen }
if(Test-Path 'lifeOS\data\life_routines.json'){ Copy-Item 'lifeOS\data\life_routines.json' $loGen }
Set-Content (Join-Path $loGen 'README.md') '# lifeOS generic v1 (samples)' -Encoding UTF8
Compress-Archive -Path (Join-Path $loGen '*') -DestinationPath (Join-Path $OutLife 'lifeOS_generic_v1.zip') -Force

# ---- lifeOS_personalize_v1 ----
$loPer = Join-Path $tmp 'lifeOS_personalize_v1'; New-Item -ItemType Directory $loPer | Out-Null
Set-Content (Join-Path $loPer 'README.md') '# lifeOS personalize v1 — starter' -Encoding UTF8
$starterLo = '{"vision/life-vision.md":"# Life Vision — starter (replace)","routines/custom.json":"{ ""daily"": [], ""weekly"": [] }","guardrails/overrides.md":"# Personal guardrails — add your own lines you won''t cross"}'
Set-Content (Join-Path $loPer 'life_starter.json') $starterLo -Encoding UTF8
Set-Content (Join-Path $loPer 'populate.ps1') @('param([string]$RepoPath="",[switch]$Confirm)','if(-not $Confirm){ Write-Host "Use -Confirm"; exit 1 }','$starter = Get-Content (Join-Path (Split-Path $MyInvocation.MyCommand.Path) ''life_starter.json'') -Raw | ConvertFrom-Json','foreach($p in $starter.PSObject.Properties){','  $dest = Join-Path $RepoPath $p.Name','  New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null','  Set-Content $dest $p.Value -Encoding UTF8','}') -Encoding UTF8
Compress-Archive -Path (Join-Path $loPer '*') -DestinationPath (Join-Path $OutLife 'lifeOS_personalize_v1.zip') -Force

Write-Host ('Rebuilt zips to {0} and {1}' -f $OutCareer, $OutLife)
