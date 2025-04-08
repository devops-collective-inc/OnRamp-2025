#region Presentation Info

<#
    Functions and script modules
    OnRamp track - PowerShell + DevOps Global Summit
    Author:  Mike F. Robbins
    Website: https://mikefrobbins.com/
#>

#endregion

#region Safety

# Prevent the entire script from running instead of a selection

# The throw keyword causes a terminating error. You can use the
# throw keyword to stop the process of a command, function, or script.
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
$vsCodeSettings = Get-Content -Path $vsCodeSettingsPath
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

# Set location
$Path = 'C:\OnRamp'
if (-not(Test-Path -Path $Path -PathType Container)) {
    New-Item -Path $Path -ItemType Directory | Out-Null
}
Set-Location -Path $Path

#endregion

#region Dot-Sourcing functions

<#
    To avoid Scoping gotcha's, test your functions from the PowerShell console
    instead of just inside VS Code or other IDEs.
#>

# Creating and dot-sourcing a function
# Define the script path
$scriptPath = "$Path\Get-MrComputerName.ps1"

# Create the file if it doesn't exist
New-Item -Path $scriptPath -ItemType File -Force

# Open the file in VS Code
code $scriptPath

# Add code for the Get-MrPSVersion function to the ps1 file
Set-Content -Path "$Path\Get-MrComputerName.ps1" -Value @'
function Get-MrComputerName {
    $env:COMPUTERNAME
}
'@

# Demonstrate running the the script. Why doesn't anything happen?
.\Get-MrComputerName.ps1

# Try to call the function
Get-MrComputerName

# Check to see if the function exists on the Function PSDrive
Get-ChildItem -Path Function:\Get-MrComputerName

# The function needs to be dot-sourced to load it into the global scope
# The relative path can be used
. .\Get-MrComputerName.ps1

# Try to call the function again
Get-MrComputerName

# Show that the function exists on the Function PS Drive
Get-ChildItem -Path Function:\Get-MrComputerName

# Remove the function from the Function PSDrive
Get-ChildItem -Path Function:\Get-MrComputerName | Remove-Item

# Show that the function no longer exists on the Function PS Drive
Get-ChildItem -Path Function:\Get-MrComputerName
Get-MrComputerName

#endregion

#region Parameter Naming

function Test-MrParameter {

    param (
        $ComputerName
    )

    Write-Output $ComputerName

}

Test-MrParameter -ComputerName Server01, Server02

<#
    Why did I use ComputerName instead of Computer, ServerName, or Host for my parameter
    name? Because I wanted my function standardized like the built-in cmdlets.
#>

function Get-MrParameterCount {
    param (
        [string[]]$ParameterName
    )

    foreach ($Parameter in $ParameterName) {
        $Results = Get-Command -ParameterName $Parameter -ErrorAction SilentlyContinue

        [pscustomobject]@{
            ParameterName   = $Parameter
            NumberOfCmdlets = $Results.Count
        }
    }
}

Get-MrParameterCount -ParameterName ComputerName, Computer, ServerName, Host, Machine
Get-MrParameterCount -ParameterName Path, FilePath

<#
    There are several built-in commands with a ComputerName parameter, but depending on what
    modules are loaded there are little to none with any of the other names that were tested.
#>

function Test-MrParameter {

    param (
        $ComputerName
    )

    Write-Output $ComputerName

}

<#
    This function doesn't have any common parameters. You can view all of the
    availble parameters with Get-Command.
#>

Get-Command -Name Test-MrParameter -Syntax
(Get-Command -Name Test-MrParameter).Parameters.Keys

#endregion

#region Advanced Functions

<#
    Turning a function into an advanced function sounds really complicated, but
    it's so simply that there's almost no reason not to turn all functions into
    advanced functions. Adding CmdletBinding turns a function into an advanced function.
#>

function Test-MrCmdletBinding {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
        $ComputerName
    )

    Write-Output $ComputerName

}

<#
    CmdletBinding does require a param block, but the param block can be empty.
#>

# There are now additional (common) parameters.

Get-Command -Name Test-MrCmdletBinding -Syntax
(Get-Command -Name Test-MrCmdletBinding).Parameters.Keys

#endregion

#region Parameter Validation

<#
    Validate input early on. Why allow your code to continue on a path
    when it's not possible to complete successfully without valid input?
#>

# Type Constraints

# Always type the variables that are being used for your parameters (specify a datatype).

function Test-MrParameterValidation {

    [CmdletBinding()]
    param (
        [string]$ComputerName
    )

    Write-Output $ComputerName

}

Test-MrParameterValidation -ComputerName Server01
Test-MrParameterValidation -ComputerName Server01, Server02
Test-MrParameterValidation

<#
    Typing the ComputerName parameter as a string only allows one value to be specified for it.
    Specifying more than one value generates an error. The problem though, is this doesn't prevent
    someone from specifying a null or empty value for that parameter or omitting it altogether.
#>

# Mandatory Parameters

<#
    In order to make sure a value is specified for the ComputerName
    parameter, make it a mandatory parameter.
#>

function Test-MrParameterValidation {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ComputerName
    )

    Write-Output $ComputerName

}

Test-MrParameterValidation

<#
    Now when the ComputerName parameter isn't specified, it prompts for a
    value. Notice that it only prompts for one value since the Type is a string.
    When the ComputerName parameter is specified without a value, with a null
    value, or with an empty string as its value, an error is generated.

    More than one value can be accepted by the ComputerName parameter by
    Typing it as an array of strings.
#>

function Test-MrParameterValidation {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$ComputerName
    )

    Write-Output $ComputerName

}

Test-MrParameterValidation

<#
    At least one value is required since the ComputerName parameter is
    mandatory. Now that it accepts an array of strings, it will continue
    to prompt for values when the ComputerName parameter is omitted until
    no value is provided, followed by pressing <enter>.
#>


# Default Values

# Default values can NOT be used with mandatory parameters.

function Test-MrParameterValidation {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$ComputerName = $env:COMPUTERNAME #<<-- This will not work with a mandatory parameter
    )

    Write-Output $ComputerName

}

Test-MrParameterValidation

<#
    Notice that the default value wasn't used in the previous example when the
    ComputerName parameter was omitted. Instead, it prompted for a value.

    To use a default value, specify the ValidateNotNullOrEmpty parameter validation
    attribute instead of making the parameter mandatory.
#>

# ValidateNotNullOrEmpty parameter validation attribute

function Test-MrParameterValidation {

    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )

    Write-Output $ComputerName

}

Test-MrParameterValidation
Test-MrParameterValidation -ComputerName Server01, Server02

# Enumerations

# The following example demonstrates using an enumeration to validate parameter input.

function Test-MrConsoleColorValidation {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [System.ConsoleColor[]]$Color = [System.Enum]::GetValues([System.ConsoleColor])
    )
    Write-Output $Color
}

Test-MrConsoleColorValidation
Test-MrConsoleColorValidation -Color Blue, DarkBlue
Test-MrConsoleColorValidation -Color Pink

<#
    Notice that a error is returned when an invalid value is provided that
    doesn't exist in the enumeration.

    I'm often asked the question "How do you find enumerations?" The following
    command can be used to find them.
#>

[AppDomain]::CurrentDomain.GetAssemblies().Where({-not($_.IsDynamic)}).ForEach({
    $_.GetExportedTypes().Where({$_.IsPublic -and $_.IsEnum})
})

# Valid values for the DayOfWeek enumeration.

[System.Enum]::GetValues([System.DayOfWeek])

# Type Accelerators

<#
    How much code have you seen written to validate IP addresses? Maybe it wasn't necessarily
    a lot of code, but something that took a lot of time such as formulating a complicated
    regular expression. Type accelerators to the rescue! They make the entire process of
    validating both IPv4 and IPv6 addresses simple.
#>

function Test-MrIPAddress {
    [CmdletBinding()]
    param (
        [ipaddress]$IPAddress
    )
    Write-Output $IPAddress
}

Test-MrIPAddress -IPAddress 10.1.1.255
Test-MrIPAddress -IPAddress 10.1.1.256
Test-MrIPAddress -IPAddress 2001:db8::ff00:42:8329
Test-MrIPAddress -IPAddress 2001:db8:::ff00:42:8329

# You might ask, how do I find Type Accelerators? With the following code.

[psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get |
    Sort-Object -Property Value

#endregion

#region Verbose Output

<#
    Inline comments should be used sparingly because no one other than someone digging
    through the code itself will ever see them as shown in the following example.
#>

function Test-MrVerboseOutput {

    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )

    foreach ($Computer in $ComputerName) {
        # Attempting to perform some action on $Computer
        # Don't use inline comments like this, use write verbose instead.
        Write-Output $Computer
    }

}

Test-MrVerboseOutput -ComputerName Server01, Server02 -Verbose

# A better option is to use Write-Verbose instead of writing inline comments.

function Test-MrVerboseOutput {

    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )

    foreach ($Computer in $ComputerName) {
        Write-Verbose -Message "Attempting to perform some action on $Computer"
        Write-Output $Computer
    }

}

Test-MrVerboseOutput -ComputerName Server01, Server02
Test-MrVerboseOutput -ComputerName Server01, Server02 -Verbose

<#
    When the Verbose parameter isn't specified, the comment isn't in the output
    and when it is specified, the comment is displayed.
#>

#endregion

#region Pipeline Input

# By Value

# Pipeline input by value is what I call by type.

function Test-MrPipelineInput {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [string[]]$ComputerName
    )

    PROCESS {   
        Write-Output $ComputerName    
    }

}

'Server01', 'Server02' | Get-Member
'Server01', 'Server02' | Test-MrPipelineInput

<#
    When Pipeline input by value is used, the Type that is specified for the parameter
    can be piped in.

    When a different type of object is piped in, it doesn't work successfully though
    as shown in the following example.
#>

$Object = New-Object -TypeName PSObject -Property @{'ComputerName' = 'Server01', 'Server02'}
$Object | Get-Member
$Object | Test-MrPipelineInput


#Pipeline Input by Property Name

<#
    Pipeline input by property name is a little more straight forward as it looks for
    input that matches the actual property name such as ComputerName in the following
    example.
#>

function Test-MrPipelineInput {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName)]
        [string[]]$ComputerName
    )

    PROCESS {   
        Write-Output $ComputerName    
    }

}

'Server01', 'Server02' | Test-MrPipelineInput


$Object | Test-MrPipelineInput


#Pipeline Input by Value and by Property Name

<#
    Both By Value and By Property Name can both be added to the same parameter.
    In this scenario, By Value is always attempted first and By Property Name
    will only ever be attempted if By Value doesn't work.
#>

function Test-MrPipelineInput {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [string[]]$ComputerName
    )

    PROCESS {  
        Write-Output $ComputerName
    }

}

'Server01', 'Server02' | Test-MrPipelineInput
$Object | Test-MrPipelineInput

#### Important Considerations when using Pipeline Input

# The begin block does not have access to the items that are piped to a command.

function Test-MrPipelineInput {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [string[]]$ComputerName
    )

    BEGIN {
        Write-Output "Test $ComputerName"
    }

}

'Server01', 'Server02' | Test-MrPipelineInput
$Object | Test-MrPipelineInput

<#
    Notice that the actual computer name does not follow word Test in the output shown
    in the previous figure.
#>

#endregion

#region Error Handling

<#
    Use try / catch where you think an error may occur. Only terminating errors are
    caught. Turn a non-terminating error into a terminating one. Don't change
    $ErrorActionPreference unless absolutely necessary and change it back if you do.
    Use -ErrorAction on a per command basis instead.

    In the following example, an unhandled exception is generated when a computer
    cannot be contacted.
#>

function Test-MrErrorHandling {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [string[]]$ComputerName
    )

    PROCESS {
        foreach ($Computer in $ComputerName) {
            Test-WSMan -ComputerName $Computer
        }
    }

}

Test-MrErrorHandling -ComputerName DoesNotExist

<#
    Simply adding a try/catch block still causes an unhandled exception to occur
    because the command doesn't generate a terminating error.
#>

function Test-MrErrorHandling {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [string[]]$ComputerName
    )

    PROCESS {
        foreach ($Computer in $ComputerName) {
            try {
                Test-WSMan -ComputerName $Computer
            }
            catch {
                Write-Warning -Message "Unable to connect to Computer: $Computer"
            }
        }
    }

}

Test-MrErrorHandling -ComputerName DoesNotExist

<#
    Specify the ErrorAction parameter with Stop as the value turns a non-terminating
    error into a terminating one. Don't modify the global $ErrorActionPreference variable.
    If you do change it such as in a scenario when you're using a non-PowerShell command
    that doesn't support ErrorAction on the command itself, change it back immediately
    after that command.
#>

function Test-MrErrorHandling {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [string[]]$ComputerName
    )

    PROCESS {
        foreach ($Computer in $ComputerName) {
            try {
                Test-WSMan -ComputerName $Computer -ErrorAction Stop
            }
            catch {
                Write-Warning -Message "Unable to connect to Computer: $Computer"
            }
        }
    }

}

Test-MrErrorHandling -ComputerName DoesNotExist

#endregion

#region Comment Based Help

#The following example demonstrates how to add comment based help to your functions.

function Get-MrAutoStoppedService {

    <#
.SYNOPSIS
    Returns a list of services that are set to start automatically, are not
    currently running, excluding the services that are set to delayed start.

.DESCRIPTION
    Get-MrAutoStoppedService is a function that returns a list of services from
    the specified remote computer(s) that are set to start automatically, are not
    currently running, and it excludes the services that are set to start automatically
    with a delayed startup.

.PARAMETER ComputerName
    The remote computer(s) to check the status of the services on.

.PARAMETER Credential
    Specifies a user account that has permission to perform this action. The default
    is the current user.

.EXAMPLE
     Get-MrAutoStoppedService -ComputerName 'Server1', 'Server2'

.EXAMPLE
     'Server1', 'Server2' | Get-MrAutoStoppedService

.EXAMPLE
     Get-MrAutoStoppedService -ComputerName 'Server1', 'Server2' -Credential (Get-Credential)

.INPUTS
    String

.OUTPUTS
    PSCustomObject

.NOTES
    Author:  Mike F. Robbins
    Website: https://mikefrobbins.com/
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    param (

    )

    #Function Body

}

<#
    This provides the users of your function with a consistent help experience with
    your functions that's just like using the default built-in cmdlets.
#>

help Get-MrAutoStoppedService -Full

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
