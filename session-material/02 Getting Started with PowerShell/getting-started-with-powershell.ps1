#region Presentation Info

# This is an example of a single-line comment and the following is an example of a block (multi-line) comment in PowerShell.

<#
    Getting started with PowerShell
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

# macOS default path = "$HOME/Library/Application Support/Code/User/settings.json"
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
Get-Content -Path $vsCodeSettingsPath -OutVariable vsCodeSettings
$vsCodeSettings | ConvertFrom-Json | Select-Object -Property 'workbench.colorTheme', 'window.zoomLevel'

# Update the color theme to ISE and zoom level to 2
if ($vsCodeSettings -match '"workbench.colorTheme": ".*",') {
    $vsCodeSettings = $vsCodeSettings -replace '"workbench.colorTheme": ".*",', '"workbench.colorTheme": "PowerShell ISE",'
}
if ($vsCodeSettings -match '"window.zoomLevel": \d,') {
    $vsCodeSettings = $vsCodeSettings -replace '"window.zoomLevel": \d,', '"window.zoomLevel": 2,'
}

# Apply the settings
$vsCodeSettings | Out-File -FilePath $vsCodeSettingsPath

# Clear the screen
Clear-Host

#endregion

#region Terminology

#*************************************
#        PowerPoint Slides
#*************************************

#endregion

#region Updating help

<#

    - Beginning with PowerShell version 3, help doesn't ship with PowerShell. The first thing you
      need to do is to update the help.

    - Help in PowerShell 7 is independent of the help in Windows PowerShell.

#>

# Update the help for all modules installed on your system that support updatable help
Update-Help

<#

    Update-Help requires admin privileges on Windows PowerShell

#>

# Update the help for a specific module
Update-Help -Module PowerShellGet

<#

    The Update-Help cmdlet is designed to prevent unnecessary network traffic by limiting the update
    of help files to once in every 24 hours. If you need to bypass this restriction, use the Force
    parameter.

#>

Update-Help -Module PowerShellGet -Force

#endregion

#region Hands-on lab for Update-Help

# Update the help in PowerShell 7 on your system if you haven't done so already.

#endregion

#region Get-Command

# How do I figure out what the commands are?

Get-Command
Get-Command -OutVariable a
$a.Count
Get-Command -Name *process*
Get-Command -Name *process* -CommandType Cmdlet, Function, Alias

# Shortcut to quickly determine the syntax of a command
Get-Command -Name Get-Command -Syntax # Show Get-Command has a Noun parameter

Get-Help -Name Get-Command -Parameter Noun

Get-Command -Noun *Process*

# ******** What is the output of the following command? ********
Get-Command -Noun *Process* -CommandType Cmdlet, Function, Alias
Get-Command -Noun *Process*  -

Get-Command -Noun Process
Get-Command -Noun Process*

Get-Command -Module PowerShellGet

Get-Module
Get-Module -ListAvailable

Get-Command -Name Get-Module -Syntax
Get-Command -Name Stop-Process -Syntax
Get-Command -Name Get-Alias -Syntax

Get-Alias -Definition Get-Command
gcm Stop-Process -Syntax
Get-Alias -Name gcm

#endregion

#region Hands-on lab for Get-Command

# Determine the commands in the same module as Get-Process

#endregion

#region The Help system

# Getting help

# The different commands that you can use to get help. Help is a function. Man is an alias on Windows, but not Linux or macOS.
Get-Command -Name Get-Help, help, man

# To get help about a specific cmdlet or function
Get-Help -Name Stop-Process

# Use the help function. The Name parameter is being used positionally
help Stop-Process  

# To see examples of how to use a cmdlet, use the Examples parameter
help Stop-Process -Examples

# Find help about a specific parameter
help Stop-Process -Parameter Name 

# To see all information that Get-Help provides about a command, use the Full parameter.
# This includes all the details, parameters, inputs, outputs, notes, and examples.
help Stop-Process -Full

# If you prefer to read the help documentation in a web browser, use the Online parameter, which opens the online version of the help page
help Stop-Process -Online

# Understanding Help

<#
    Get-Member provides insight into the objects, properties, and methods associated with PowerShell
    commands. You can pipe any PowerShell command that produces object based output to Get-Member.
    When you pipe the output of a command to Get-Member, it reveals the structure of the object
    returned by the command, detailing its properties and methods.

    - Properties: The attributes of an object.
    - Methods: The actions you can perform on an object.
#>

help Stop-Process | Get-Member
Get-Help -Name Stop-Process | Get-Member

(Get-Help -Name Stop-Process).Syntax
(help Stop-Process).Syntax

# Context specific help

help Get-ChildItem
help Get-ChildItem -Parameter File
(Get-Command).Parameters.Values | Where-Object Name -eq 'File'

Set-Location -Path Cert:
help Get-ChildItem
help Get-ChildItem -Parameter File
(Get-Command).Parameters.Values | Where-Object Name -eq 'File'

# About topics

# PowerShell includes _about_ topics that provide detailed help on various PowerShell concepts and features. List all available _about_ topics
help about_*
help about_

# Read a specific _about_ topic, such as about_Variables
help about_Variables

# View the online version of the about_Variables help topic
# ******** What will the following command do? ********
help about_Variables -Online

# Finding commands with Get-Help

help process -OutVariable process
$process.Count
help *process*
help pr?cess
help *pr?cess*
help '-process'
help *-process
help processes -OutVariable processes
$processes.Count
$processes.Count / $process.Count

[System.Management.Automation.Cmdlet]::CommonParameters
[System.Management.Automation.Cmdlet]::OptionalCommonParameters

#endregion

#region Running commands

$path = 'C:\OnRamp'
if (-not(Test-Path -Path $Path -PathType Container)) {
    New-Item -Path $Path -ItemType Directory | Out-Null
}
Set-Location -Path $Path

## Execution Policy

$scriptPath = "$Path\Get-PwshProcess.ps1"

# Create the file if it doesn't exist
New-Item -Path $scriptPath -ItemType File -Force

# Open the file in VS Code
code $scriptPath

#Add code for the Get-MrPSVersion function to the ps1 file
Set-Content -Path "$Path\Get-PwshProcess.ps1" -Value @'
Get-Process -Name pwsh
'@

#Demonstrate running the the script. Why doesn't anything happen?
.\Get-PwshProcess.ps1

## User Access Control (UAC)

# Get all the PowerShell version 7 processes that are running
Get-Process -Name pwsh

# Display vs actual properties
Get-Process -Name pwsh | Get-Member

# Filtering with Where-Object
Get-Process | Where-Object {$_.Name -eq 'pwsh'}

# Simplified syntax (not really)
Get-Process | Where-Object Name -eq pwsh
Get-Process | Where-Object -Property Name -EQ pwsh
Get-Process | Where-Object -Value pwsh -Property Name -EQ

# Compound Where-Object syntax
Get-Process | Where-Object {$_.Name -eq 'pwsh' -and $_.Parent -like '*WindowsTerminal*'}
Get-Process | Where-Object {$_.Name -eq 'pwsh' -and $_.Parent -match 'WindowsTerminal'}

#endregion

#region Extending the capability of PowerShell

<#
    Microsoft.PowerShell.PSResourceGet is a module with commands for discovering,
    installing, updating and publishing PowerShell artifacts like Modules, DSC Resources,
    Role Capabilities, and Scripts.
#>

Get-Module -Name Microsoft.PowerShell.PSResourceGet, PowerShellGet -ListAvailable

$env:PSModulePath
$env:PSModulePath -split ';'
$env:PSModulePath -split [System.IO.Path]::PathSeparator

Find-Module -Name Microsoft.PowerShell.PSResourceGet
Install-Module -Name Microsoft.PowerShell.PSResourceGet

Get-Module -Name Microsoft.PowerShell.PSResourceGet -ListAvailable

Get-Command -Module Microsoft.PowerShell.PSResourceGet

#endregion

#region Variables

# Commands for working with variables
Get-Command -Noun variable

# Don't use hungarian notation
$strName
$intNumber

# Instead define its type if it will only contain one type of object
[string]$name
[int]$number

# Use camel case for user defined variables
$resourceGroupName

# Use pascal case for parameters
$ComputerName

# Dollar sign ($) isn't part of the variable name
Get-Process -Name pwsh -OutVariable pwshProcess
Write-Output $pwshProcess

#endregion

#region Cleanup

#Reset the settings changes for this presentation

# macOS default path = "$HOME/Library/Application Support/Code/User/settings.json"
$macSettingsPath = "$HOME/Library/Application Support/Code/User/profiles/-12baa4e9/settings.json"
$windowsSettingsPath = "$env:APPDATA\Code\User\settings.json"
$linuxSettingsPath = "$HOME/.config/Code/User/settings.json"

switch ($true) {
    {Test-Path -Path $macSettingsPath -PathType Leaf} {$vsCodeSettingsPath = $macSettingsPath; break}
    {Test-Path -Path $windowsSettingsPath -PathType Leaf} {$vsCodeSettingsPath = $windowsSettingsPath; break}
    {Test-Path -Path $linuxSettingsPath -PathType Leaf} {$vsCodeSettingsPath = $linuxSettingsPath; break}
    default {Write-Warning -Message 'Unable to locate VS Code settings.json file'}
}

$vsCodeSettings = Get-Content -Path $vsCodeSettingsPath
$vsCodeSettings | ConvertFrom-Json | Select-Object -Property 'workbench.colorTheme', 'window.zoomLevel'

if ($vsCodeSettings -match '"workbench.colorTheme": ".*",') {
    $vsCodeSettings = $vsCodeSettings -replace '"workbench.colorTheme": ".*",', '"workbench.colorTheme": "Visual Studio Dark",'
}
if ($vsCodeSettings -match '"window.zoomLevel": \d,') {
    $vsCodeSettings = $vsCodeSettings -replace '"window.zoomLevel": \d,', '"window.zoomLevel": 0,'
}

$vsCodeSettings | Out-File -FilePath $vsCodeSettingsPath

#endregion
