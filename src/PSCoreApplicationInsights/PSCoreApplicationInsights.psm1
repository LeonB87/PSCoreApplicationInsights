function New-ApplicationInsightsClient {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "The Application Insights Instrumentation Key that is used to send the messages to the correct Application Insights Instance.")]
        [ValidateNotNullOrEmpty()]
        [Guid]
        $InstrumentationKey
    )

    $Client = [Microsoft.ApplicationInsights.TelemetryClient]::new()
    $Client.InstrumentationKey = $InstrumentationKey

    $defaultUserInformation = @{
        AuthenticatedUserId = whoami
        UserAgent           = ("PS $($psversiontable.PSEdition) $($psversiontable.PSVersion)")
    }

    $defaultDeviceInformation = @{
        OperatingSystem = $psversiontable.OS

    }

    $client = Set-ApplicationInsightsClientInformation -UserInformation $defaultUserInformation -DeviceInformation $defaultDeviceInformation -Client $Client

    return $Client
}

Export-ModuleMember -Function New-ApplicationInsightsClient
function Confirm-ApplicationInsightsClient {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Microsoft.ApplicationInsights.TelemetryClient]
        $Client
    )

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
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
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
    }

    process {
        if (-not $null -eq $UserInformation) {

            foreach ($property in $Client.Context.User.psobject.Properties.name) {
                Write-Verbose ("Checking property '$($property)' in supplied hashtable")
                if (-not [string]::IsNullOrWhiteSpace($UserInformation[$property])) {
                    Write-Verbose ("Found property '$($property)' with a value. Changing value from '$($Client.Context.User.$property)' to '$($UserInformation[$property])'")

                    $Client.Context.User.$property = $UserInformation[$property]
                }
            }
        }

        if (-not $null -eq $DeviceInformation) {

            foreach ($property in $Client.Context.Device.psobject.Properties.name) {
                Write-Verbose ("Checking property '$($property)' in supplied hashtable")
                if (-not [string]::IsNullOrWhiteSpace($DeviceInformation[$property])) {
                    Write-Verbose ("Found property '$($property)' with a value. Changing value from '$($Client.Context.Device.$property)' to '$($DeviceInformation[$property])'")

                    $Client.Context.Device.$property = $DeviceInformation[$property]
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
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Microsoft.ApplicationInsights.TelemetryClient]
        $Client,

        [Parameter(Mandatory = $true)]
        [string]
        $Message,

        [Parameter(Mandatory = $false)]
        [validateSet('Information', 'Verbose', 'Warning', 'Error', 'Critical')]
        [string]
        $SeverityLevel = "information",

        [Parameter(Mandatory = $false, HelpMessage = "This is a dictionary<string, string> with additional information that will be added as 'customDimensions' in Application Insights")]
        [System.Collections.Generic.Dictionary[string, string]]
        $properties
    )
    BEGIN {
        Write-Verbose ("Received '$($SeverityLevel)' severity level for the message '$($Message)'")

        if ($properties.Count -ge 1) {
            Write-Verbose ("Received '$($properties.Count)' properties to add to the message.")
        }

        Confirm-ApplicationInsightsClient $client
    }
    PROCESS {
        if ($properties.Count -ge 1) {
            $Client.TrackTrace($Message, [Microsoft.ApplicationInsights.DataContracts.SeverityLevel]::$($SeverityLevel), $properties)
        }
        else {
            $Client.TrackTrace($Message, [Microsoft.ApplicationInsights.DataContracts.SeverityLevel]::$($SeverityLevel))
        }

    }
    END {
        $Client.Flush()
    }
}

Export-ModuleMember -Function Write-ApplicationInsightsTrace

function Write-ApplicationInsightsMetric {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
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

        if ($properties.Count -ge 1) {
            Write-Verbose ("Received '$($properties.Count)' properties to add to the message.")
        }
    }
    PROCESS {
        if ($properties.Count -ge 1) {
            $client.TrackMetric($name, $Metric, $properties)
        }
        else {
            $client.TrackMetric($name, $Metric)
        }

    }
    END {
        $Client.Flush()
    }
}

Export-ModuleMember -Function Write-ApplicationInsightsMetric
function Write-ApplicationInsightsException {
    [CmdletBinding(DefaultParameterSetName = "Exception")]
    param (
        [Parameter(Mandatory = $true)]
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

        if ($PSCmdlet.ParameterSetName -eq "StringException") {
            $Exception = [System.Exception]::new($ExceptionString)
        }
    }
    PROCESS {
        $client.TrackException($Exception, $properties, $Metrics)

        $client.TrackExce
    }
    END {
        $Client.Flush()
    }
}

Export-ModuleMember -Function Write-ApplicationInsightsException

function Write-ApplicationInsightsRequest {
    [CmdletBinding()]
    param (
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

        [Parameter(Mandatory = $false, HelpMessage = "This is the URL that will be added as 'url' in Application Insights")]
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
    }
    PROCESS {

        $requestTelemetry = [Microsoft.ApplicationInsights.DataContracts.RequestTelemetry]::new()

        $requestTelemetry.Duration = $Duration
        $requestTelemetry.Name = $Name
        $requestTelemetry.ResponseCode = $responseCode
        $requestTelemetry.Success = $success
        $requestTelemetry.Timestamp = $StartTime

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

        $client.TrackRequest($requestTelemetry)
    }
    END {
        $Client.Flush()
    }
}

Export-ModuleMember -Function Write-ApplicationInsightsRequest
Function Invoke-ApplicationInsightsMeasuredCommand {
    [CmdletBinding()]
    param (
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

        Write-Verbose ("Received '$($duration)' duration for the command")
        Write-ApplicationInsightsRequest -Name $name -StartTime $startDate -Duration $duration -responseCode $statusCode -success $success
    }
    END {
        return $retVal
    }
}

Export-ModuleMember -Function Invoke-ApplicationInsightsMeasuredCommand