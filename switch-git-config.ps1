# Git Config Switcher for PowerShell
# Easy switching between git configurations

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigFile = Join-Path $ScriptDir "config.json"

# Show current git configuration
function Show-CurrentConfig {
    Write-Host "Current Git Configuration:" -ForegroundColor Blue
    $currentName = git config user.name
    $currentEmail = git config user.email
    Write-Host "  Name: $currentName"
    Write-Host "  Email: $currentEmail"
    Write-Host ""
}

# Check if config file exists
if (-not (Test-Path $ConfigFile)) {
    Write-Host "Error: config.json not found!" -ForegroundColor Red
    Write-Host "Please copy config.example.json to config.json and edit it with your settings:"
    Write-Host "  Copy-Item config.example.json config.json"
    exit 1
}

# Load configuration from JSON
try {
    $config = Get-Content $ConfigFile -Raw | ConvertFrom-Json
    $profiles = $config.profiles
} catch {
    Write-Host "Error: Failed to parse config.json!" -ForegroundColor Red
    Write-Host "Please ensure config.json is valid JSON format."
    exit 1
}

# Display current configuration
Show-CurrentConfig

# Show menu
Write-Host "Which configuration would you like to switch to?" -ForegroundColor Yellow
for ($i = 0; $i -lt $profiles.Count; $i++) {
    $profile = $profiles[$i]
    Write-Host "$($i + 1)) $($profile.label) ($($profile.name) <$($profile.email)>)"
}
Write-Host "$($profiles.Count + 1)) Cancel"
Write-Host ""

$choice = Read-Host "Select (1-$($profiles.Count + 1))"

# Validate input
if ($choice -notmatch '^\d+$') {
    Write-Host "Invalid selection." -ForegroundColor Red
    exit 1
}

$choiceNum = [int]$choice

# Handle selection
if ($choiceNum -eq ($profiles.Count + 1)) {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit 0
} elseif ($choiceNum -ge 1 -and $choiceNum -le $profiles.Count) {
    $selectedProfile = $profiles[$choiceNum - 1]
    git config --global user.name "$($selectedProfile.name)"
    git config --global user.email "$($selectedProfile.email)"
    Write-Host "✓ Switched to $($selectedProfile.label) account." -ForegroundColor Green
} else {
    Write-Host "Invalid selection." -ForegroundColor Red
    exit 1
}

Write-Host ""
Show-CurrentConfig
