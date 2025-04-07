#region Presentation info

<#
   Install prerequisites for OnRamp
   OnRamp track - PowerShell + DevOps Global Summit
   Author:  Mike F. Robbins
   Website: https://mikefrobbins.com/
#>

#endregion

#region Safety

# Prevent the entire script from running instead of a selection

# The throw keyword causes a terminating error. You can use the throw keyword to stop the process of a command, function, or script.
throw "You're not supposed to run the entire script"

#endregion

#region Presentation prep

# Locate the VS Code settings.json file
$macSettingsPath = "$HOME/Library/Application Support/Code/User/profiles/-12baa4e9/settings.json"
$windowsSettingsPath = "$env:APPDATA\Code\User\settings.json"
$linuxSettingsPath = "$HOME/.config/Code/User/settings.json"

switch ($true) {
    {Test-Path -Path $macSettingsPath -PathType Leaf} {$vsCodeSettingsPath = $macSettingsPath; break}
    {Test-Path -Path $windowsSettingsPath -PathType Leaf} {$vsCodeSettingsPath = $windowsSettingsPath; break}
    {Test-Path -Path $linuxSettingsPath -PathType Leaf} {$vsCodeSettingsPath = $linuxSettingsPath; break}
    default {Write-Warning -Message 'Unable to locate VS Code settings.json file'}
}

# Return the current color theme and zoom level for VS Code
$VSCodeSettings = Get-Content -Path $VSCodeSettingsPath
$VSCodeSettings | ConvertFrom-Json | Select-Object -Property 'workbench.colorTheme', 'window.zoomLevel'

# Update the color theme to ISE and zoom level to 2
if ($VSCodeSettings -match '"workbench.colorTheme": ".*",') {
   $VSCodeSettings = $VSCodeSettings -replace '"workbench.colorTheme": ".*",', '"workbench.colorTheme": "PowerShell ISE",'
}
if ($VSCodeSettings -match '"window.zoomLevel": \d,') {
   $VSCodeSettings = $VSCodeSettings -replace '"window.zoomLevel": \d,', '"window.zoomLevel": 2,'
}

# Apply the settings
$VSCodeSettings | Out-File -FilePath $VSCodeSettingsPath

# Clear the screen
Clear-Host

#endregion

#region Check your PowerShell version

# Determine your version of PowerShell
$PSVersionTable.PSVersion

# $Host or $Host.Version doesn't show the version of PowerShell. It shows the version of the terminal emulator.
$Host
$Host.Version

# To check if you have the latest version, compare your version to the newest release by running.
Invoke-RestMethod -Uri https://api.github.com/repos/powershell/powershell/releases/latest |
   Select-Object -ExpandProperty tag_name

# Install PowerShell 7 on Windows
winget search --id Microsoft.Powershell --source winget

<#
   If no results are returned, your winget version is outdated. Refer to the troubleshooting
   section below.
#>

# Install the latest version of PowerShell 7
winget install --id Microsoft.Powershell --source winget

#endregion

#region Install Visual Studio Code (VS Code)

# Install VS Code using winget
winget install --id Microsoft.VisualStudioCode --source winget


# Update environment variables to include the path to the VS Code executable (or restart PowerShell)
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Install the PowerShell extension for VS Code
code --install-extension ms-vscode.powershell

#endregion

#region Install Windows Terminal

# Windows Terminal is pre-installed on recent versions of Windows 11

# Determine if Windows Terminal is installed
Get-Command -Name wt.exe

# If not installed, use winget to install it
winget install --id Microsoft.WindowsTerminal --source winget

#endregion

#region Install Git

# Install git source control with winget
winget install --id Git.Git --source winget

#endregion

#region Install the GitHub CLI

# Install the GitHub CLI (gh) with winget
winget install --id GitHub.cli -source winget

#endregion

#Region Troubleshooting

# If winget doesn’t return any results, it might be outdated

# To repair it, install the Microsoft.WinGet.Client module from the PowerShell Gallery.
Install-Module -Name Microsoft.WinGet.Client

# Run the repair command.
Repair-WinGetPackageManager

#endregion

#region Linux and macOS installation instructions

<#
   How to install PowerShell 7 and essential tools on Linux
   https://mikefrobbins.com/2024/09/26/how-to-install-powershell-7-and-essential-tools-on-linux/

   How to install PowerShell 7 and essential tools on macOS
   https://mikefrobbins.com/2024/11/14/how-to-install-powershell-7-and-essential-tools-on-macos/
#>

#endregion

#region Cleanup

#Reset the settings changes for this presentation
$macSettingsPath = "$HOME/Library/Application Support/Code/User/profiles/-12baa4e9/settings.json"
$windowsSettingsPath = "$env:APPDATA\Code\User\settings.json"
$linuxSettingsPath = "$HOME/.config/Code/User/settings.json"

switch ($true) {
    {Test-Path -Path $macSettingsPath -PathType Leaf} {$vsCodeSettingsPath = $macSettingsPath; break}
    {Test-Path -Path $windowsSettingsPath -PathType Leaf} {$vsCodeSettingsPath = $windowsSettingsPath; break}
    {Test-Path -Path $linuxSettingsPath -PathType Leaf} {$vsCodeSettingsPath = $linuxSettingsPath; break}
    default {Write-Warning -Message 'Unable to locate VS Code settings.json file'}
}

$VSCodeSettings = Get-Content -Path $VSCodeSettingsPath
$VSCodeSettings | ConvertFrom-Json | Select-Object -Property 'workbench.colorTheme', 'window.zoomLevel'

if ($VSCodeSettings -match '"workbench.colorTheme": ".*",') {
   $VSCodeSettings = $VSCodeSettings -replace '"workbench.colorTheme": ".*",', '"workbench.colorTheme": "Visual Studio Dark",'
}
if ($VSCodeSettings -match '"window.zoomLevel": \d,') {
   $VSCodeSettings = $VSCodeSettings -replace '"window.zoomLevel": \d,', '"window.zoomLevel": 0,'
}

$VSCodeSettings | Out-File -FilePath $VSCodeSettingsPath

 #endregion
