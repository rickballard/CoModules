param([string]$PolicyPath = "$PSScriptRoot/../policy/guardian-policy.json", [ValidateSet("quest","movement")] [string]$Mode = "quest")
Set-StrictMode -Version Latest; $ErrorActionPreference='Stop'
function Load-Policy($path) { (Get-Content -LiteralPath $path -Raw) | ConvertFrom-Json }
$policy = Load-Policy -path (Resolve-Path $PolicyPath)
$stateDir   = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(($policy.storage.state_dir -replace '%LOCALAPPDATA%', $env:LOCALAPPDATA))
$earnedPath = Join-Path $stateDir 'earned.json'

$quests = @(
  'Draw a simple map of your room; list 3 energy-savers.',
  'Minecraft (creative): build an AND gate; 2-line explanation.',
  'Khan Academy: read 10 min; write 3 new facts.',
  'Typing practice 10 min; note WPM.',
  'Watch a physics demo; 3-line summary.',
  'Zero-waste cafeteria: 5-bullet plan.',
  'Scratch: mini-project with a loop and a condition.',
  'Weather: predict tomorrow?s range; explain uncertainty.',
  'Plan a 5-plant balcony garden (light/water).',
  'Explain to an 8-year-old how a password manager helps (3 bullets).',
  'Copy one paragraph from a book; circle verbs vs nouns.',
  'Budget a $20 snack sale; target $6 profit (show math).'
)

if ($Mode -eq 'movement') {
  $task = 'Movement Break: 10 min total ? 20 jumping jacks + 20 air-squats + 10 pushups + 60-sec plank.'
} else {
  $task = $quests | Get-Random
}

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.MessageBox]::Show($task, $policy.ui.coach_name, 'OK','Information') | Out-Null

$earned = @{
  date = (Get-Date).ToString("yyyy-MM-dd")
  minutes = @{
    quest_reward = $policy.quests.reward_minutes_games
    daily_cap    = $policy.quests.daily_reward_cap_minutes
  }
}
$earned | ConvertTo-Json -Depth 5 | Out-File -LiteralPath $earnedPath -Encoding UTF8
