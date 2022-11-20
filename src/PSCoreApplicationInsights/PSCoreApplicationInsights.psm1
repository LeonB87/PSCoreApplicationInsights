function New-ApplicationInsightsClient {
    <#
    .SYNOPSIS
    Create a new Application insights Client

    .DESCRIPTION
    Create a new Application insights Client by supplying an Instrumentation Key of your Application Insights instance.

    .PARAMETER InstrumentationKey
    The Instrumentation Key of your Application Insights instance.

    .EXAMPLE
    New-ApplicationInsightsClient -InstrumentationKey c323cf10-da34-4a73-9eac-000000000000

    Create a new Application Insights Telemetry Client and store it in $global:AIClient

    .EXAMPLE
    $client = New-ApplicationInsightsClient -InstrumentationKey c323cf10-da34-4a73-9eac-000000000000

    Create a new Application Insights Telemetry Client and store it in a variable.

    .NOTES
    General notes
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "The Application Insights Instrumentation Key that is used to send the messages to the correct Application Insights Instance.")]
        [ValidateNotNullOrEmpty()]
        [Guid]
        $InstrumentationKey
    )


    if ($PSCmdlet.ShouldProcess([Microsoft.ApplicationInsights.TelemetryClient], "New")) {
        $global:AIClient = [Microsoft.ApplicationInsights.TelemetryClient]::new()
    }

    if ($PSCmdlet.ShouldProcess('$global:AIClient', "Set InstrumentationKey")) {
        $global:AIClient.InstrumentationKey = $InstrumentationKey
    }

    $defaultUserInformation = @{
        AuthenticatedUserId = whoami
        UserAgent           = ("PS $($psversiontable.PSEdition) $($psversiontable.PSVersion)")
    }

    $defaultDeviceInformation = @{
        OperatingSystem = $psversiontable.OS
    }

    if ($PSCmdlet.ShouldProcess('$global:AIClient', 'Set-ApplicationInsightsClientInformation')) {
        $global:AIClient = Set-ApplicationInsightsClientInformation -UserInformation $defaultUserInformation -DeviceInformation $defaultDeviceInformation -Client $global:AIClient -WhatIf:$WhatIfPreference
    }

    return $global:AIClient
}

Export-ModuleMember -Function New-ApplicationInsightsClient
function Confirm-ApplicationInsightsClient {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [Microsoft.ApplicationInsights.TelemetryClient]
        $Client
    )

    if ($null -eq $client) {
        if ($null -eq $global:AIClient) {
            write-error ("No Application insight client defined. Please use 'New-ApplicationInsightsClient' to create one.")
            return;
        } else {
            $client = $global:AIClient
        }
    }


    [bool] $isValid = $true
    Write-Verbose ("Checking if the Application Insights Client is valid...")

    if ([string]::IsNullOrWhiteSpace($client.InstrumentationKey)) {
        Write-Verbose ("The Instrumentation Key is not set.")
        $isValid = $false
    }

    if ($client.Isenabled() -eq $false) {
        Write-Verbose ("The Application Insights Client is not enabled.")
        $isValid = $false
    }

    if ($isValid -eq $true) {
        Write-Verbose ("The Application Insights Client is valid.")
    }
    else {
        throw ("The Application Insights Client is not valid.")
    }
}

function Set-ApplicationInsightsClientInformation {
    <#
    .SYNOPSIS
    Changes the Telemetry Client information

    .DESCRIPTION
    Changes the Telemetry Client information. This currently supports changing the user and Device information.
    This information will be displayed in the Application Insights logging.

    .PARAMETER Client
    The Application Insights Telemetry Client. Defaults to $global:AIClient

    .PARAMETER UserInformation
    A hashtable with User Information

    To find valid properties, Create a client and look at the current properties. $global:AIClient.context.User

    .PARAMETER DeviceInformation
    A hashtable with device information.

    To find valid properties, Create a client and look at the current properties. $global:AIClient.context.Device

    .EXAMPLE
    $userInformation = @{AuthenticatedUserId = "John Doe"; UserAgent = "PS Core 7.2.5"} ; Set-ApplicationInsightsClientInformation -UserInformation $userInformation

    .NOTES
    Default settings are already applied when creating a new Application Insight client.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $false)]
        [Microsoft.ApplicationInsights.TelemetryClient]
        $Client,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $UserInformation,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $DeviceInformation
    )
    begin {
        if (-not $null -eq $UserInformation) {
            Write-Verbose ("Received 'User' properties to set in the client")
        }

        if (-not $null -eq $DeviceInformation) {
            Write-Verbose ("Received 'Device' properties to set in the client")
        }

        if ($null -eq $client) {
            if ($null -eq $global:AIClient) {
                write-error ("No Application insight client defined. Please use 'New-ApplicationInsightsClient' to create one.")
                return;
            } else {
                $client = $global:AIClient
            }
        }
    }

    process {
        if (-not $null -eq $UserInformation) {
            foreach ($property in $Client.Context.User.psobject.Properties.name) {
                Write-Verbose ("Checking property '$($property)' in supplied hashtable")
                if (-not [string]::IsNullOrWhiteSpace($UserInformation[$property])) {
                    Write-Verbose ("Found property '$($property)' with a value. Changing value from '$($Client.Context.User.$property)' to '$($UserInformation[$property])'")

                    if ($PSCmdlet.ShouldProcess("Set Userinformation property $($Client.Context.User.$property)", "$($UserInformation[$property])")) {
                        $Client.Context.User.$property = $UserInformation[$property]
                    }
                }
            }
        }

        if (-not $null -eq $DeviceInformation) {
            foreach ($property in $Client.Context.Device.psobject.Properties.name) {
                Write-Verbose ("Checking property '$($property)' in supplied hashtable")
                if (-not [string]::IsNullOrWhiteSpace($DeviceInformation[$property])) {
                    Write-Verbose ("Found property '$($property)' with a value. Changing value from '$($Client.Context.Device.$property)' to '$($DeviceInformation[$property])'")

                    if ($PSCmdlet.ShouldProcess("Set Device property $($Client.Context.User.$property)", "$($UserInformation[$property])")) {
                        $Client.Context.Device.$property = $DeviceInformation[$property]
                    }
                }
            }
        }
    }

    end {
        return $Client
    }

}

Export-ModuleMember -Function Set-ApplicationInsightsClientInformation

function Write-ApplicationInsightsTrace {
    <#
    .SYNOPSIS
    Write a simple Trace message to the Application Insights service.

    .DESCRIPTION
    Write a simple Trace message to the Application Insights service. Supports several Severity levels

    .PARAMETER Client
    This is the Telemetry Client used to send the message. If not specified, Defaults to "$global:AICient"

    .PARAMETER Message
    The message you want to send to Application Insights.

    .PARAMETER SeverityLevel
    The severity level of the message. The default is 'Information'.

    Allowed values: 'Verbose', 'Information', 'Warning', 'Error', 'Critical'

    .PARAMETER properties
    A Dictionary of properties you want to send with the message.

    .EXAMPLE
    Write-ApplicationInsightsTrace -Client $client -Message "This is a test message as Critical" -SeverityLevel "Critical"

    .EXAMPLE

    $properties = [System.Collections.Generic.Dictionary[string, string]]::new()
    $properties.Add("target", "azkv-powershell-001")
    $properties.Add("type", "Keyvault")
    Write-ApplicationInsightsTrace -Client $client -Message "Created new keyvault" -SeverityLevel "Information" -properties $properties

    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $false, HelpMessage = 'This is the Telemetry Client used to send the message. If not specified, Defaults to "$global:AICient"')]
        [Microsoft.ApplicationInsights.TelemetryClient]
        $Client,

        [Parameter(Mandatory = $true, HelpMessage = "This is the message being send to Application Insights.")]
        [string]
        $Message,

        [Parameter(Mandatory = $false, HelpMessage = "This is the Severity Level of the message and will show as 0..5 in Application Insights")]
        [validateSet('Information', 'Verbose', 'Warning', 'Error', 'Critical')]
        [string]
        $SeverityLevel = "information",

        [Parameter(Mandatory = $false, HelpMessage = "This is a dictionary<string, string> with additional information that will be added as 'customDimensions' in Application Insights")]
        [System.Collections.Generic.Dictionary[string, string]]
        $properties
    )
    BEGIN {
        Write-Verbose ("Received '$($SeverityLevel)' severity level for the message '$($Message)'")

        if ($null -eq $client) {
            if ($null -eq $global:AIClient) {
                write-error ("No Application insight client defined. Please use 'New-ApplicationInsightsClient' to create one.")
                return;
            } else {
                $client = $global:AIClient
            }
        }

        if ($properties.Count -ge 1) {
            Write-Verbose ("Received '$($properties.Count)' properties to add to the message.")
        }

        Confirm-ApplicationInsightsClient $client
    }
    PROCESS {
        if ($properties.Count -ge 1) {
            if ($PSCmdlet.ShouldProcess("$($client.InstrumentationKey)", "Sent message '$($Message)' with '$($properties.Count)' properties to Application Insights with severity '$($SeverityLevel)'")) {
                $Client.TrackTrace($Message, [Microsoft.ApplicationInsights.DataContracts.SeverityLevel]::$($SeverityLevel), $properties)
                Write-Verbose ("Sent message '$($Message)' with '$($properties.Count)' properties to Application Insights.")
            }

        }
        else {

            if ($PSCmdlet.ShouldProcess("$($client.InstrumentationKey)", "Sent message '$($Message)' to Application Insights with severity '$($SeverityLevel)'")) {
                $Client.TrackTrace($Message, [Microsoft.ApplicationInsights.DataContracts.SeverityLevel]::$($SeverityLevel))
                Write-Verbose ("Sent message '$($Message)' to Application Insights.")
            }

        }
    }
    END {
        $Client.Flush()
        Write-Verbose ("Client Flushed")
    }
}

Export-ModuleMember -Function Write-ApplicationInsightsTrace

function Write-ApplicationInsightsMetric {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [Microsoft.ApplicationInsights.TelemetryClient]
        $Client,

        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [Double]
        $Metric,

        [Parameter(Mandatory = $false, HelpMessage = "This is a dictionary<string, string> with additional information that will be added as 'customDimensions' in Application Insights")]
        [System.Collections.Generic.Dictionary[string, string]]
        $properties
    )
    BEGIN {

        if ($null -eq $client) {
            if ($null -eq $global:AIClient) {
                write-error ("No Application insight client defined. Please use 'New-ApplicationInsightsClient' to create one.")
                return;
            } else {
                $client = $global:AIClient
            }
        }

        if ($properties.Count -ge 1) {
            Write-Verbose ("Received '$($properties.Count)' properties to add to the message.")
        }
    }
    PROCESS {
        if ($properties.Count -ge 1) {
            $client.TrackMetric($name, $Metric, $properties)
            Write-Verbose ("Sent metric '$($Name)' with '$($Metric)' value and '$($properties.Count)' properties to Application Insights.")
        }
        else {
            $client.TrackMetric($name, $Metric)
            Write-Verbose ("Sent metric '$($Name)' with '$($Metric)' value to Application Insights.")
        }

    }
    END {
        $Client.Flush()
        Write-Verbose ("Client Flushed")
    }
}

Export-ModuleMember -Function Write-ApplicationInsightsMetric
function Write-ApplicationInsightsException {
    [CmdletBinding(DefaultParameterSetName = "Exception")]
    param (
        [Parameter(Mandatory = $false)]
        [Microsoft.ApplicationInsights.TelemetryClient]
        $Client,

        [Parameter(Mandatory = $true, ParameterSetName = "Exception")]
        [System.Exception]
        $Exception,

        [Parameter(Mandatory = $true, ParameterSetName = "StringException")]
        [String]
        $ExceptionString,

        [Parameter(Mandatory = $false, HelpMessage = "This is a dictionary<string, double> with additional information that will be added as 'customMeasurements' in Application Insights")]
        [System.Collections.Generic.Dictionary[string, double]]
        $Metrics = [System.Collections.Generic.Dictionary[string, double]]::new(),

        [Parameter(Mandatory = $false, HelpMessage = "This is a dictionary<string, string> with additional information that will be added as 'customDimensions' in Application Insights")]
        [System.Collections.Generic.Dictionary[string, string]]
        $properties = [System.Collections.Generic.Dictionary[string, string]]::new()
    )
    BEGIN {
        Write-Verbose ("Running in Parameterset '$($PSCmdlet.ParameterSetName)'")

        if ($null -eq $client) {
            if ($null -eq $global:AIClient) {
                write-error ("No Application insight client defined. Please use 'New-ApplicationInsightsClient' to create one.")
                return;
            } else {
                $client = $global:AIClient
            }
        }

        if ($PSCmdlet.ParameterSetName -eq "StringException") {
            $Exception = [System.Exception]::new($ExceptionString)
        }
    }
    PROCESS {
        $client.TrackException($Exception, $properties, $Metrics)
        Write-Verbose ("Sent exception '$($Exception)' with '$($Metrics.Count)' metrics and '$($properties.Count)' properties to Application Insights.")
    }
    END {
        $Client.Flush()
        Write-Verbose ("Client Flushed")
    }
}

Export-ModuleMember -Function Write-ApplicationInsightsException

function Write-ApplicationInsightsRequest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [Microsoft.ApplicationInsights.TelemetryClient]
        $Client,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.DateTimeOffset]
        $StartTime,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Timespan]
        $Duration,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $responseCode = "200",

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Bool]
        $success,

        [Parameter(Mandatory = $false, HelpMessage = "This is a dictionary<string, string> with additional information that will be added as 'customProperties' in Application Insights")]
        [System.Collections.Generic.Dictionary[string, string]]
        $properties = [System.Collections.Generic.Dictionary[string, string]]::new(),

        [Parameter(Mandatory = $false, HelpMessage = "This is the URL that will be added as 'url' property in Application Insights")]
        [ValidateNotNullOrEmpty()]
        [string]
        $url
    )
    BEGIN {
        Write-Verbose ("Received '$($Name)' name for the request")
        Write-Verbose ("Received '$($StartTime)' start time for the request")
        Write-Verbose ("Received '$($Duration)' duration for the request")
        Write-Verbose ("Received '$($responseCode)' response code for the request")
        Write-Verbose ("Received '$($success)' success for the request")

        if ($null -eq $client) {
            if ($null -eq $global:AIClient) {
                write-error ("No Application insight client defined. Please use 'New-ApplicationInsightsClient' to create one.")
                return;
            } else {
                Write-Verbose ("Using global client")
                $client = $global:AIClient
            }
        } else {
            Write-Verbose ("Using supplied client")
        }

    }
    PROCESS {

        $requestTelemetry = [Microsoft.ApplicationInsights.DataContracts.RequestTelemetry]::new()

        $requestTelemetry.Duration = $Duration
        $requestTelemetry.Name = $Name
        $requestTelemetry.ResponseCode = $responseCode
        $requestTelemetry.Success = $success
        $requestTelemetry.Timestamp = $StartTime

        $client.Context.Operation.Name = $Name
        $client.Context.Operation.Id = [guid]::NewGuid().Guid

        if ($properties.Count -ge 1) {
            Write-Verbose ("Received '$($properties.Count)' properties to add to the request.")
            foreach ($key in $properties.Keys) {
                Write-Verbose ("Received '$($key)' property to add to the request.")
                $requestTelemetry.Properties[$key] = $properties[$key]
            }
        }

        if (-not [string]::IsNullOrWhiteSpace($url)) {
            Write-Verbose ("Received '$($url)' url for the request")
            $requestTelemetry.Url = $url
        }

        Write-Verbose ("Sending request telemetry")
        $client.TrackRequest($requestTelemetry)

    }
    END {
        $Client.Flush()
        Write-Verbose ("Client Flushed")
    }
}

Export-ModuleMember -Function Write-ApplicationInsightsRequest
Function Invoke-ApplicationInsightsMeasuredCommand {
    <#
    .SYNOPSIS
    Invoke a scriptblock that is measured by Application Insights.

    .DESCRIPTION
    Invoke a scriptblock that is measured by Application Insights. This created a timespan and writes the timing to Application Insights. The output of the scriptblock is returned.

    .PARAMETER Client
    The Application Insights Telemetry Client. Defaults to $global:AIClient

    .PARAMETER scriptblock
    The scriptblock you wish to execute and measure.

    .PARAMETER name
    This is a name you wish to give to the scriptblock. This is used to identify the scriptblock in Application Insights.

    .EXAMPLE
    Invoke-ApplicationInsightsMeasuredCommand -ScriptBlock { start-sleep -Milliseconds 150 } -Name "Performing task X"

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [Microsoft.ApplicationInsights.TelemetryClient]
        $Client,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [scriptblock]
        $scriptblock,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $name
    )
    BEGIN {

        if ($null -eq $client) {
            if ($null -eq $global:AIClient) {
                write-error ("No Application insight client defined. Please use 'New-ApplicationInsightsClient' to create one.")
                return;
            } else {
                $client = $global:AIClient
            }
        }

        Write-Verbose ("Received '$($name)' name for the command")
    }
    PROCESS {

        $success = $true
        $statusCode = "200"

        $startDate = [System.DateTime]::UtcNow

        try {
            $retVal = $scriptblock.Invoke()
        }
        catch [System.Exception] {
            Write-Verbose ("Caught exception in the scriptblock")
            $statusCode = $_
            $success = $false
            throw
        }
        finally {
            $endDate = [System.DateTime]::UtcNow
        }

        $duration = New-TimeSpan -Start $startDate -End $endDate

        Write-Verbose ("Received '$($duration)' as duration for the command")
        Write-ApplicationInsightsRequest -Name $name -StartTime $startDate -Duration $duration -responseCode $statusCode -success $success
    }
    END {
        $Client.Flush()
        Write-Verbose ("Client Flushed")
        return $retVal
    }
}

Export-ModuleMember -Function Invoke-ApplicationInsightsMeasuredCommand