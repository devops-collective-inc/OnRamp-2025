# Bonus content

# Sidebar: Don't use string concatenation
'C:\' + 'OnRamp'
'C:\' + '\OnRamp'
'C:\' + 'OnRamp\'
'C:\' + '\OnRamp\'
Join-Path -Path 'C:\' -ChildPath '\OnRamp\'
Split-Path -Path 'C:\OnRamp'
Split-Path -Path 'C:\OnRamp' -Leaf

# Execution policy (Windows only)
Get-ExecutionPolicy
Get-ExecutionPolicy -List

## Execution Policy

## User Access Control (UAC)

# Run the following command to determine the version of PowerShell you're using.
$PSVersionTable
$PSVersionTable.PSVersion

# Use with the less than or equal to comparison operator
$PSVersionTable.PSVersion.Major -le 5

# Real world scenario: Add OS specific variables that exist in PowerShell 7 to Windows PowerShell.
if ($PSVersionTable.PSVersion.Major -le 5) {
    $IsWindows = $true
    $IsLinux = $false
    $IsMacOS = $false
    $IsCoreCLR = $false
}

if ($IsWindows) {
    Set-Location -Path $env:SystemDrive\
}

#region Basic navigation

<#
    Tab expansion or tab completion is a feature in PowerShell that allows you to type a few characters of a command, parameter, or path and then press the Tab key to complete the rest of the item. If there are multiple items that match the characters you've typed, pressing the Tab key multiple times will cycle through the available options.
#>

# By default, tab expansion works differently on Windows vs Linux and macOS.

<#
    Intellisense is a feature in PowerShell that provides context-aware code completion suggestions as you type. It helps you write code faster and with fewer errors by suggesting cmdlets, parameters, variables, and other elements based on the context of your script.
#>

# Use the Tab key to complete the path.

# Get the current directory path. Similar to the pwd (print working directory) command in Linux.
Get-Location

# Save the current directory so you can return to it later. Similar to pushd in other command-line environments.
Push-Location

# Tab expansion can be used to complete values for parameters as well. Use ctrl+space to trigger intellisense.

# Create a new directory.
New-Item -Name NewFolder -ItemType Directory

# One of the tricks I use is to run a command without a parameter value to determine if the error will reveal more information.

# Changes the current directory to the one specified. Similar to the cd command.
Set-Location -Path C:\NewFolder

# Create a new file.
New-Item -Name example.txt -ItemType File

# Create multiple files. Once you figure out how to perform a task in PowerShell once, it's easy to replicate it multiple times.
1..100 | ForEach-Object {New-Item -Name example$_.txt -ItemType File}

# Clear the screen
Clear-Host

# Lists the items (files and directories) in the current directory or one you specify. Similar to ls or dir.
Get-ChildItem

# Return to the directory saved by the last Push-Location command.
Pop-Location

# Delete a file or directory. Be cautious with this command, as it can delete files and directories permanently.
Remove-Item -Path C:\NewFolder\example.txt  # Removes a file
Get-ChildItem -Path C:\NewFolder

Remove-Item -Path NewFolder -Recurse -WhatIf  # Removes a directory and its contents
Remove-Item -Path NewFolder -Recurse -Confirm

# List PSDrives
Get-PSDrive

# Navigating the Certificate PSDrive
Get-ChildItem -Path Cert:
Get-ChildItem -Path Cert:\LocalMachine
Get-ChildItem -Path Cert:\LocalMachine\My
Get-ChildItem -Path Cert:\LocalMachine\My | Select-Object -First 1 -Property *

# Real world scenario: Find certificates that are expiring in the next 90 days.
Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object NotAfter -lt (Get-Date).AddDays(90)

#endregion

#region Running native commands

notepad.exe
ping 8.8.8.8

#endregion