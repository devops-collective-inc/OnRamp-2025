#region Presentation Info

<#
    One-liners and the pipeline
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

#region One-liners

<#
    A PowerShell one-liner is one continuous pipeline. It's a common misconception that
    a command on one physical line is a PowerShell one-liner, but this isn't always true.
#>

Get-Service |
    Where-Object CanPauseAndContinue -eq $true |
    Select-Object -Property *

<# Natural line break characters

    Natural line breaks can occur at commonly used characters, including comma (`,`) and opening
    brackets (`[`), braces (`{`), and parenthesis (`(`). Others that aren't so common include the
    semicolon (`;`), equals sign (`=`), and both opening single and double quotes (`'`,`"`).

#>

<# Line continuation

    Using the backtick ` or grave accent character as a line continuation is controversial.
    It's best to avoid it if possible. Using a backtick following a natural line break character is
    a common mistake. This redundancy is unnecessary and can clutter the code.

#>

# Demonstrate in VS Code and Windows Terminal
Get-Service -Name w32time |

#This is not a one-liner
$Service = 'w32time'; Get-Service -Name $Service

<#
    Many programming and scripting languages require a semicolon at the end of each line.
    However, in PowerShell, semicolons at the end of lines are unnecessary and not recommended.
    You should avoid them for cleaner and more readable code.
#>

#endregion


#region Filter left

<#
    It's a best practice in PowerShell to filter the results as early as possible in the pipeline.
    Achieving this involves applying filters using parameters on the initial command, usually at the
    beginning of the pipeline. This is commonly referred to as filtering left.
#>

Get-Service -Name w32time

<#
    It's common to see online examples of a PowerShell command being piped to the Where-Object cmdlet
    to filter its results. This technique is inefficient if an earlier command in the pipeline has a
    parameter to perform the filtering.
#>

Get-Service | Where-Object Name -eq w32time

#endregion

#region Command sequencing for effective filtering

<#
    The following example fails to produce results because the CanPauseAndContinue property is
    absent when Select-Object is piped to Where-Object. This is because the CanPauseAndContinue
    property wasn't included in the selection made by Select-Object. Effectively, it has been
    excluded or filtered out.
#>

Get-Service |
    Select-Object -Property DisplayName, Running, Status |
    Where-Object CanPauseAndContinue

# Reversing the order of Select-Object and Where-Object produces the desired results.

Get-Service |
    Where-Object CanPauseAndContinue |
    Select-Object -Property DisplayName, Status

#endregion

#region The pipeline

# You can often use the output of one command as input for another command.

# Depending on how thorough help for a command is, it may include an INPUTS and OUTPUTS section.

help Stop-Service -Full
(Get-Help -Name Stop-Service).inputTypes

<#
    You can determine that information by checking the different parameters in the full version
    of the help for the Stop-Service cmdlet.
#>

help Stop-Service -Full
help Stop-Service -Parameter InputObject, Name

<#
    When handling pipeline input, a parameter that accepts pipeline input both by property name and
    by value prioritizes by value binding first. If this method fails, it attempts to process
    pipeline input by property name. However, the term by value can be misleading. A more
    accurate description is by type.
#>

# Determine what type of output the Get-Service command produces.
Get-Service -Name w32time | Get-Member

# Get-Service produces a ServiceController object type.

<#
    As shown in the help for Stop-Service cmdlet, the InputObject parameter accepts
    ServiceController objects through the pipeline by value. This implies that when you pipe
    the output of the Get-Service cmdlet to Stop-Service, the ServiceController objects
    produced by Get-Service bind to the InputObject parameter of Stop-Service.
#>

#endregion

#region Format Right

<#
    The rule for manually formatting a command's output is similar to the rule about filtering left
    except it needs to occur as far to the right as possible.
#>

# The most common format commands are Format-Table and Format-List.
# A command that returns more than four properties defaults to a list unless custom formatting is used.

Get-Service -Name w32time |
    Select-Object -Property Status, DisplayName, Can*

# Use the Format-Table cmdlet to manually override the formatting and show the output in a table instead of a list.

Get-Service -Name w32time |
    Select-Object -Property Status, DisplayName, Can* |
    Format-Table

# The default output for Get-Service is three properties in a table.
Get-Service -Name w32time

# Use the Format-List cmdlet to override the default formatting and return the results in a list.
Get-Service -Name w32time | Format-List

<#
    The number one thing to be aware of with the format cmdlets is they produce format objects
    that are different than normal objects in PowerShell.
#>

Get-Service -Name w32time | Format-List | Get-Member

<#
    What this means is format commands can't be piped to most other commands. They can be piped
    to some of the Out-* commands, but that's about it. This is why you want to perform any
    formatting at the very end of the line (format right).
#>

#endregion

#region Aliases

<#
    An alias in PowerShell is a shorter name for a command. PowerShell includes a set of built-in
    aliases and you can also define your own aliases.
#>

# Determine what the real command is for an alias
Get-Alias -Name gcm
Get-Alias gcm, gm, gmo
gal gc, ps, gps

# Determine the aliases for a command
Get-Alias -Definition Get-ChildItem

#endregion

#region Providers

<#
    A provider in PowerShell is an interface that allows file system like access to a datastore.
    There are a number of built-in providers in PowerShell.
#>

Get-PSProvider

<#
    The actual drives that these providers use to expose their datastore can be determined with the
    Get-PSDrive cmdlet. The Get-PSDrive cmdlet not only displays drives exposed by providers,
    but it also displays Windows logical drives including drives mapped to network shares.
#>

Get-PSDrive

<#
    Third-party modules such as the Active Directory PowerShell module and the SQLServer PowerShell
    module both add their own PowerShell provider and PSDrive.
#>

# PSDrives can be accessed just like a traditional file system.
Get-ChildItem -Path Cert:\LocalMachine\CA

#endregion

#region Comparison Operators

<#
    PowerShell contains a number of comparison operators that are used to compare values or find
    values that match certain patterns. The following table contains a list of comparison operators
    in PowerShell.

    All of the operators listed below are case-insensitive. Place a "c" in front of the operator to
    make it case-sensitive. For example, "-ceq" is the case-sensitive version of the "-eq"
    comparison operator.

    |    Operator    |                          Definition                          |
    | -------------- | ------------------------------------------------------------ |
    | -eq            | Equal to                                                     |
    | -ne            | Not equal to                                                 |
    | -gt            | Greater than                                                 |
    | -ge            | Greater than or equal to                                     |
    | -lt            | Less than                                                    |
    | -le            | Less than or equal to                                        |
    | -Like          | Match using the * wildcard character                         |
    | -notlike       | Does not match using the * wildcard character                |
    | -match         | Matches the specified regular expression                     |
    | -notmatch      | Does not match the specified regular expression              |
    | -contains      | Determines if a collection contains a specified value        |
    | -notcontains   | Determines if a collection does not contain a specific value |
    | -in            | Determines if a specified value is in a collection           |
    | -notin         | Determines if a specified value is not in a collection       |
    | -replace       | Replaces the specified value                                 |
#>

# Proper case "PowerShell" is equal to lower case "powershell" using the equals comparison operator.
'PowerShell' -eq 'powershell'

# It's not equal using the case-sensitive version of the equals comparison operator.
'PowerShell' -ceq 'powershell'

# The not equal comparison operator reverses the condition.
'PowerShell' -ne 'powershell'

<#
    Be careful when using methods to transform data because you can run into unforeseen problems,
    such as failing the Turkey Test. My recommendation is to use an operator instead of a method
    whenever possible to avoid these types of problems.
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
