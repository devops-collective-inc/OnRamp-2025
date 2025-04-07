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
    To avoid Scoping gotcha's, test your functions from the PowerShell console instead
    of just inside VS Code or other IDEs.
#>

#Creating and dot-sourcing a function
# Define the script path
$scriptPath = "$Path\Get-MrComputerName.ps1"

# Create the file if it doesn't exist
New-Item -Path $scriptPath -ItemType File -Force

# Open the file in VS Code
code $scriptPath

#Add code for the Get-MrPSVersion function to the ps1 file
Set-Content -Path "$Path\Get-MrComputerName.ps1" -Value @'
function Get-MrComputerName {
    $env:COMPUTERNAME
}
'@

#Demonstrate running the the script. Why doesn't anything happen?
.\Get-MrComputerName.ps1

#Try to call the function
Get-MrComputerName

#Check to see if the function exists on the Function PSDrive
Get-ChildItem -Path Function:\Get-MrComputerName

#The function needs to be dot-sourced to load it into the global scope
#The relative path can be used
. .\Get-MrComputerName.ps1

<#
#The fully qualified path can also be used
. C:\Demo\Get-MrComputerName.ps1

#The variable containing the path to the demo folder along with the filename can also be used
. $Path\Get-MrComputerName.ps1
#>

#Try to call the function again
Get-MrComputerName

#Show that the function exists on the Function PS Drive
Get-ChildItem -Path Function:\Get-MrComputerName

#Remove the function from the Function PSDrive
Get-ChildItem -Path Function:\Get-MrComputerName | Remove-Item

#Show that the function no longer exists on the Function PS Drive
Get-ChildItem -Path Function:\Get-MrComputerName
Get-MrComputerName

#endregion

#region Parameter Naming

#*************************************
#        PowerPoint Slide 15
#*************************************

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
    As you can see in the previous set of results, there are several built-in commands with
    a ComputerName parameter, but depending on what modules are loaded there are little to
    none with any of the other names that were tested.

    Now back to the Test-MrParameter function.
#>

function Test-MrParameter {

    param (
        $ComputerName
    )

    Write-Output $ComputerName

}

<#
    This function doesn't have any common parameters. The parameters of a command can be
    viewed with intellisense in VSCode (Visual Studio Code), or by using tabbed expansion
    to tab through the available parameters.
#>

Test-MrParameter -<tab>

<#
    There are also a couple of different ways to view all of the available parameters
    for a command using Get-Command.
#>

Get-Command -Name Test-MrParameter -Syntax
(Get-Command -Name Test-MrParameter).Parameters.Keys

<#
    To learn more about parameters see the about_Functions_Advanced_Parameters help topic.
    https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters
#>

#endregion

#region Advanced Functions

<#
    Turning a function into an advanced function sounds really complicated, but it's so
    simply that there's almost no reason not to turn all functions into advanced functions.
    Adding CmdletBinding turns a function into an advanced function.
#>

function Test-MrCmdletBinding {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
        $ComputerName
    )

    Write-Output $ComputerName

}

<#
    That simple declaration adds common parameters to the Test-MrCmdletBinding function
    shown in the previous example. CmdletBinding does require a param block, but the
    param block can be empty.

    There are now additional (common) parameters. As previously mentioned, the parameters
    can be seen using intellisense.
#>

Test-MrCmdletBinding -<tab>
Test-MrCmdletBinding -<ctrl + space>

#And a couple of different ways with Get-Command.

Get-Command -Name Test-MrCmdletBinding -Syntax
(Get-Command -Name Test-MrCmdletBinding).Parameters.Keys

<#
    Recommended Reading:
    about_Functions_CmdletBindingAttribute
    https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions_cmdletbindingattribute

    about_CommonParameters
    https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_commonparameters

    about_Functions_Advanced
    https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions_advanced

    about_Functions_Advanced_Methods
    https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions_advanced_methods
#>

#endregion

#region Preventing Resume Generating Events

<#
    If your function modifies anything at all, support for WhatIf and Confirm should
    be added to it. SupportsShouldProcess adds WhatIf & Confirm parameters.
    Keep in mind, this is only needed for commands that make changes.
#>

function Test-MrSupportsShouldProcess {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        $ComputerName
    )

    Write-Output $ComputerName

}

#As shown in the following example, there are now WhatIf & Confirm parameters.

Test-MrSupportsShouldProcess -<tab>

Get-Command -Name Test-MrSupportsShouldProcess -Syntax
(Get-Command -Name Test-MrSupportsShouldProcess).Parameters.Keys

<#
    If all the commands within your function support WhatIf and Confirm, there is
    nothing more to do, but if there are commands within your function that don't
    support these, additional logic is required.
#>

#endregion

#region Parameter Validation

<#
    Validate input early on. Why allow your code to continue on a path when it's
    not possible to complete successfully without valid input?
#>

#Type Constraints

#Always type the variables that are being used for your parameters (specify a datatype).

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
    As shown in the previous figure, Typing the ComputerName parameter as a string only
    allows one value to be specified for it. Specifying more than one value generates
    an error. The problem though, is this doesn't prevent someone from specifying a null
    or empty value for that parameter or omitting it altogether.

    For more information see "Use a Type Constraint in PowerShell".
    https://learn.microsoft.com/previous-versions/technet-magazine/ff642464(v=msdn.10)
#>


#Mandatory Parameters

<#
    In order to make sure a value is specified for the ComputerName parameter,
    make it a mandatory parameter.
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
    Now when the ComputerName parameter isn't specified, it prompts for a value.
    Notice that it only prompts for one value since the Type is a string. When the
    ComputerName parameter is specified without a value, with a null value, or with an
    empty string as its value, an error is generated.

    More than one value can be accepted by the ComputerName parameter by Typing it as
    an array of strings.
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
    At least one value is required since the ComputerName parameter is mandatory. Now
    that it accepts an array of strings, it will continue to prompt for values when
    the ComputerName parameter is omitted until no value is provided, followed by
    pressing <enter>.
#>


#Default Values

#Default values can NOT be used with mandatory parameters.

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

<#
    Notice that $env:COMPUTERNAME was used as the default value instead of localhost
    or . which makes the command more dynamic and it's considered to be a best practice.
#>

#ValidatePattern

#ValidatePattern validates the input against a regular expression.

function Test-ValidatePattern {
    [CmdletBinding()]
    param (
        [ValidatePattern('^(?!^(PRN|AUX|CLOCK\$|NUL|CON|COM\d|LPT\d|\..*)(\..+)?$)[^\x00-\x1f\\?*:\"";|/]+$')]
        [string]$FileName
    )
    Write-Output $FileName
}

#If the value doesn’t match the regular expression, an error is generated.

Test-ValidatePattern -FileName '.con'

<#
    As you can see in the previous example, the error messages that ValidatePattern generates are
    cryptic unless you read regular expressions and since most people don’t, I typically avoid
    using it. The same type of input validation can be performed using ValidateScript  while
    providing the user of your function with a meaningful error message.
#>

#ValidateScript

#ValidateScript uses a script to validate the value:

function Test-ValidateScript {
    [CmdletBinding()]
    param (
        [ValidateScript({
            If ($_ -match '^(?!^(PRN|AUX|CLOCK\$|NUL|CON|COM\d|LPT\d|\..*)(\..+)?$)[^\x00-\x1f\\?*:\"";|/]+$') {
                $True
            }
            else {
                Throw "$_ is either not a valid filename or it is not recommended."
            }
        })]
        [string]$FileName
    )
    Write-Output $FileName
}

#Notice the meaningful error message.

Test-ValidateScript -FileName '.con'

#Enumerations

#The following example demonstrates using an enumeration to validate parameter input.

function Test-MrConsoleColorValidation {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [System.ConsoleColor[]]$Color = [System.Enum]::GetValues([System.ConsoleColor])
    )
    Write-Output $Color
}

Test-MrConsoleColorValidation -<tab>
Test-MrConsoleColorValidation
Test-MrConsoleColorValidation -Color Blue, DarkBlue
Test-MrConsoleColorValidation -Color Pink

<#
    Notice that a error is returned when an invalid value is provided that does not
    exist in the enumeration.

    I'm often asked the question "How do you find enumerations?" The following command
    can be used to find them.
#>

[AppDomain]::CurrentDomain.GetAssemblies().Where({-not($_.IsDynamic)}).ForEach({
    $_.GetExportedTypes().Where({$_.IsPublic -and $_.IsEnum})
})

#Valid values for the DayOfWeek enumeration.

[System.Enum]::GetValues([System.DayOfWeek])

#Type Accelerators

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

#You might ask, how do I find Type Accelerators? With the following code.

[psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get |
    Sort-Object -Property Value

#endregion

#region Multiple Parameter Sets

<#
    Sometimes you need to add more than one parameter set to a function you're creating.
    If that's not something you're familiar with, it can be a little confusing at first.
    In the following example, I want to either specify the Name or Module parameter,
    but not both at the same time. I also want the Path parameter to be available when
    using either of the parameter sets.
#>

function Test-MrMultiParamSet {
    [CmdletBinding(DefaultParameterSetName='Name')]
    param (
        [Parameter(Mandatory,
                   ParameterSetName='Name')]
        [string[]]$Name,

        [Parameter(Mandatory,
                   ParameterSetName='Module')]
        [string[]]$Module,

        [string]$Path
    )
    $PSCmdlet.ParameterSetName
}

<#
    Taking a look at the syntax shows the function shown in the previous example does
    indeed have two different parameter sets and the Path parameter exists in both of
    them. The only problem is both the Name and Module parameters are mandatory and it
    would be nice to have Name available positionally.
#>

Get-Command -Name Test-MrMultiParamSet -Syntax
Test-MrMultiParamSet -Name 'Testing Name Parameter Set' -Path C:\Demo\
Test-MrMultiParamSet -Module 'Testing Name Parameter Set' -Path C:\Demo\
Test-MrMultiParamSet 'Testing Name Parameter Set' -Path C:\Demo\

#Simply specifying Name as being in position zero solves that problem.

function Test-MrMultiParamSet {
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param (
        [Parameter(Mandatory,
            ParameterSetName = 'Name',
            Position = 0)]
        [string[]]$Name,

        [Parameter(Mandatory,
            ParameterSetName = 'Module')]
        [string[]]$Module,

        [string]$Path
    )
    $PSCmdlet.ParameterSetName
}

<#
    Notice that “Name” is now enclosed in square brackets when viewing the syntax for
    the function. This means that it’s a positional parameter and specifying the parameter
    name is not required as long as its value is specified in the correct position. Keep
    in mind that you should always use full command and parameter names in any code that
    you share.
#>

Get-Command -Name Test-MrMultiParamSet -Syntax
Test-MrMultiParamSet 'Testing Name Parameter Set' -Path C:\Demo\

<#
    While continuing to work on the parameters for this function, I decided to make
    the Path parameter available positionally as well as adding pipeline input support
    for it. I’ve seen others add those requirements similar to what’s shown in the
    following example.
#>

function Test-MrMultiParamSet {
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param (
        [Parameter(Mandatory,
            ParameterSetName = 'Name',
            Position = 0)]
        [string[]]$Name,

        [Parameter(Mandatory,
            ParameterSetName = 'Module')]
        [string[]]$Module,

        [Parameter(ParameterSetName = 'Name')]
        [Parameter(ParameterSetName = 'Module')]
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName,
                   Position = 1)]
        [string]$Path        
    )
    $PSCmdlet.ParameterSetName
}

<#
    This might initially seem to work, but what appears to happen is that it ignores
    the Parameter blocks for both the Name and Module parameter set names for the Path
    parameter because they are effectively blank. This is because another totally
    separate parameter block is specified for the Path parameter. Looking at the help
    for the Path parameter shows that it accepts pipeline input, but looking at the
    individual parameter sets seems to suggest that it doesn’t. It’s confused to say
    the least.
#>

'C:\Demo' | Test-MrMultiParamSet Test01
help Test-MrMultiParamSet -Parameter Path
(Get-Command -Name Test-MrMultiParamSet).ParameterSets.Parameters.Where({$_.Name -eq 'Path'})

<#
    There’s honestly no reason to specify the individual parameter sets for the Path
    parameter if all of the options are going to be the same for all of the parameter
    sets.
#>

function Test-MrMultiParamSet {
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param (
        [Parameter(Mandatory,
            ParameterSetName = 'Name',
            Position = 0)]
        [string[]]$Name,

        [Parameter(Mandatory,
            ParameterSetName = 'Module')]
        [string[]]$Module,

        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName,
                   Position = 1)]
        [string]$Path        
    )
    $PSCmdlet.ParameterSetName
}

<#
    Removing those two empty parameter declarations above the Path parameter that reference
    the individual parameter sets clears up the problems.
#>

'C:\Demo' | Test-MrMultiParamSet Test01
help Test-MrMultiParamSet -Parameter Path
(Get-Command -Name Test-MrMultiParamSet).ParameterSets.Parameters.Where({$_.Name -eq 'Path'})

<#
    If you want to specify different options for the Path parameter to be used in different
    parameter sets, then you would need to explicitly specify those options as shown in the
    following example. To demonstrate this, I’ve omitted pipeline input by property name when
    the Module parameter set is used.
#>

function Test-MrMultiParamSet {
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param (
        [Parameter(Mandatory,
            ParameterSetName = 'Name',
            Position = 0)]
        [string[]]$Name,

        [Parameter(Mandatory,
            ParameterSetName = 'Module')]
        [string[]]$Module,

        [Parameter(ParameterSetName = 'Name',
                   Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName,
                   Position = 1)]
        [Parameter(ParameterSetName = 'Module',
                   Mandatory,
                   ValueFromPipeline,
                   Position = 1)]
        [string]$Path        
    )
    $PSCmdlet.ParameterSetName
}

#Now everything looks correct.

'C:\Demo' | Test-MrMultiParamSet Test01
help Test-MrMultiParamSet -Parameter Path
(Get-Command -Name Test-MrMultiParamSet).ParameterSets.Parameters.Where({$_.Name -eq 'Path'})

<#
    For more information about using multiple parameter sets in your functions, see the
    about_Functions_Advanced_Parameters help topic.
    https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters
#>

#endregion

#region Return Keyword

<#
    The return keyword is probably the most over used keyword in PowerShell that’s used in
    unnecessary scenarios. You’ll often find it used to simply return the output of a function.
#>

function New-MrGuid {
    $Guid = [System.Guid]::NewGuid()
    Return $Guid
}

New-MrGuid

<#
    In that scenario, using the return keyword is totally unnecessary. If you do want to
    return the value of the variable, simply let PowerShell take care of returning the output.
#>

function New-MrGuid {
    $Guid = [System.Guid]::NewGuid()
    $Guid
}

New-MrGuid

<#
    Although I didn’t specify it in the previous example, I typically use Write-Output
    instead of just specifying the variable itself.
#>

function New-MrGuid {
    $Guid = [System.Guid]::NewGuid()
    Write-Output $Guid
}

New-MrGuid

<#
    In the previous example, there’s no reason to store the value in a variable, simply
    create the new GUID and let PowerShell handle returning the output all in one command.
#>

function New-MrGuid {
    [System.Guid]::NewGuid()
}

New-MrGuid

<#
    The return keyword does have a couple of valid use cases though. The following
    function does not use the return keyword.
#>

function Test-Return {
    [CmdletBinding()]
    param (
        [int[]]$Number
    )
    foreach ($N in $Number) {
        if ($N -ge 4) {
            $N
        }
    }
}

#Without the return keyword any number greater than or equal to four is returned.

Test-Return -Number 3, 5, 7, 9

#Notice that the return keyword has been added to the function without any other changes.

function Test-Return {
    [CmdletBinding()]
    param (
        [int[]]$Number
    )
    foreach ($N in $Number) {
        if ($N -ge 4) {
            Return $N
        }
    }
}

<#
    With the return keyword, the first value that is greater than or equal to 4 will be
    returned and then the foreach loop will exit without testing the numbers 7 or 9.
#>

Test-Return -Number 3, 5, 7, 9

<#
    Not only does it exit the foreach loop, but the entire function so if additional code
    existed after the foreach loop, it wouldn’t be executed either. A slightly modified
    version of the previous function will be used to demonstrate this.
#>

#For the first test, the return keyword is omitted.

function Test-Return {
    [CmdletBinding()]
    param (
        [int[]]$Number
    )
    $i = 0
    foreach ($N in $Number) {
        if ($N -ge 4) {
            $i++
            $N
        }
    }
    Write-Verbose -Message "A total of $i items were returned."
}

<#
    The verbose output after the foreach loop is included in the output when specifying
    the verbose parameter.
#>

Test-Return -Number (1..10) -Verbose

#The return keyword has been added to the following function.

function Test-Return {
    [CmdletBinding()]
    param (
        [int[]]$Number
    )
    $i = 0
    foreach ($N in $Number) {
        if ($N -ge 4) {
            $i++
            Return $N
        }
    }
    Write-Verbose -Message "A total of $i items were returned."
}

Test-Return -Number (1..10) -Verbose

<#
    Notice that although the verbose parameter was specified, the verbose output is not included
    because the return keyword causes the function to exit before it gets to that point.

    Of course, if the portion of the code with the return keyword isn’t run, the verbose
    output will be included in the output when the verbose parameter is specified.
#>

Test-Return -Number (1..3) -Verbose

<#
    Classes - The return keyword is required when using them (this is the other use case).

    For more information about the return keyword, see the about_Return help topic.
    https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_return
#>

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
        #Attempting to perform some action on $Computer
        #Don't use inline comments like this, use write verbose instead.
        Write-Output $Computer
    }

}

Test-MrVerboseOutput -ComputerName Server01, Server02 -Verbose

#A better option is to use Write-Verbose instead of writing inline comments.

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
    As shown in the previous figure, when the Verbose parameter isn't specified, the
    comment isn't in the output and when it is specified, the comment is displayed.

    To learn more, see the Write-Verbose help topic
    https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/write-verbose
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

'Server01', 'Server02' | Test-MrPipelineInput
'Server01', 'Server02' | Get-Member

<#
    As shown in the previous example, when Pipeline input by value is used, the Type
    that is specified for the parameter can be piped in.

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

#The begin block does not have access to the items that are piped to a command.

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

<#
    For more information, see the about_Try_Catch_Finally help topic.
    https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_try_catch_finally
#>

#endregion

#region Comment Based Help is Dead, Long live Comment Based Help

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

<#
    For more information see the about_Comment_Based_Help help topic.
    https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_comment_based_help
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