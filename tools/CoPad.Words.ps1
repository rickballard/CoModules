param([string]$UiPath)
Set-StrictMode -Version Latest; $ErrorActionPreference="Stop"
Add-Type -AssemblyName PresentationFramework

# Paths
$Repo  = Split-Path $PSScriptRoot -Parent
$Tools = Join-Path $Repo "tools"
$CoPing = Join-Path $Tools "CoPing.ps1"
if(-not (Test-Path $CoPing)){ [System.Windows.MessageBox]::Show("Missing tools\CoPing.ps1","CoPad",0,"Error") | Out-Null; exit 1 }

if(-not $UiPath){
  $UiPath = Join-Path (Split-Path $Repo -Parent) "docs\methods\CoWords.ui.json"
}
if(-not (Test-Path $UiPath)){
  [System.Windows.MessageBox]::Show("Missing $UiPath","CoPad",0,"Error") | Out-Null; exit 1
}
$items = Get-Content $UiPath -Raw | ConvertFrom-Json -EA Stop

$run = Join-Path $HOME "Downloads\CoCacheLocal\run"
New-Item -Type Directory -Force -Path $run | Out-Null
$firstRunFlag = Join-Path $run "copad.v2.first.done"
$firstRun = -not (Test-Path $firstRunFlag)

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="CoPad · CoWords" Width="540" Height="640" WindowStartupLocation="CenterScreen" Topmost="True">
  <DockPanel Margin="12">
    <StackPanel DockPanel.Dock="Top" Orientation="Horizontal" Margin="0,0,0,8">
      <TextBlock Text="CoPad · CoWords" FontWeight="Bold" FontSize="16" Margin="0,0,12,0"/>
      <CheckBox Name="Pin" Content="Pin on top" IsChecked="True" VerticalAlignment="Center"/>
    </StackPanel>
    <ScrollViewer VerticalScrollBarVisibility="Auto">
      <StackPanel Name="Rows" />
    </ScrollViewer>
    <TextBlock Name="Status" DockPanel.Dock="Bottom" Text="Ready" Margin="0,8,0,0"/>
  </DockPanel>
</Window>
"@

$win = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))
$rows = $win.FindName("Rows")
$status = $win.FindName("Status")
$pin = $win.FindName("Pin")
$pin.Add_Checked({ $win.Topmost = $true })  | Out-Null
$pin.Add_Unchecked({ $win.Topmost = $false }) | Out-Null

function Send-CoWord([string]$word){
  try { & $CoPing -To "COAGENT" -Msg $word | Out-Null; $status.Text = "Sent: " + $word }
  catch { $status.Text = "Failed: " + $word }
}

foreach($i in $items){
  $row = New-Object Windows.Controls.Border
  $row.Margin = '0,4,0,4'
  $row.Padding = '6'
  $row.BorderThickness = '1'
  $row.CornerRadius = '6'
  $row.BorderBrush = 'LightGray'

  $grid = New-Object Windows.Controls.Grid
  $grid.ColumnDefinitions.Add((New-Object Windows.Controls.ColumnDefinition)) | Out-Null
  $col2 = New-Object Windows.Controls.ColumnDefinition
  $col2.Width = '3'
  $grid.ColumnDefinitions.Add($col2) | Out-Null

  $btn = New-Object Windows.Controls.Button
  $btn.Content = $i.label
  $btn.Margin = '0,0,8,0'
  $btn.Padding = '10,8'
  $btn.Add_Click({ param($s,$e) Send-CoWord $i.word })
  [Windows.Controls.Grid]::SetColumn($btn,0)
  $grid.Children.Add($btn) | Out-Null

  $right = New-Object Windows.Controls.StackPanel
  $right.Orientation = 'Vertical'
  [Windows.Controls.Grid]::SetColumn($right,1)

  $hint = New-Object Windows.Controls.TextBlock
  $hint.Text = $i.hint
  $hint.FontStyle = 'Italic'
  $right.Children.Add($hint) | Out-Null

  $expander = New-Object Windows.Controls.Expander
  $expander.Header = '…'
  $expander.IsExpanded = $firstRun
  $tb = New-Object Windows.Controls.TextBlock
  $tb.TextWrapping = 'Wrap'
  $tb.Margin = '0,4,0,0'
  $tb.Text = $i.detail + "`nAlso accepts: " + $i.word
  $expander.Content = $tb
  $right.Children.Add($expander) | Out-Null

  $grid.Children.Add($right) | Out-Null
  $row.Child = $grid
  $rows.Children.Add($row) | Out-Null
}

if($firstRun){ Set-Content -Path $firstRunFlag -Value ((Get-Date).ToString('u')) }

$win.ShowDialog() | Out-Null