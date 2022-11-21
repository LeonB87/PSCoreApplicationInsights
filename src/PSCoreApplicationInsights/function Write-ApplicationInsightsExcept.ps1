function Write-ApplicationInsightsException {
    <#



    .SYNOPSIS
    Write an exception to application insight

    .DESCRIPTION
    Write an exception to application insight. You can pass a  [System.Exception] object, or a string that will be changed to an [System.Exception].

    .PARAMETER Client
    This is the Telemetry Client used to send the message. If not specified, Defaults to "$global:AICient"

    .PARAMETER Exception
    the System.Exception object to send to Application Insight

    .PARAMETER ExceptionString
    Add a string that will be set to a new [System.Exception] object.

    .PARAMETER Metrics
    (Optional) a Dictionary[string, double] of metric to add to the 'customMeasurements' column

    .PARAMETER properties
    (Optional) a Dictionary[string, string] of metric to add to the 'customDimensions' column

    .EXAMPLE
    try { 0/0 } catch {$exception = $_}
    Write-ApplicationInsightsException -Exception $exception.Exception

    .EXAMPLE
    try { 0/0 } catch {$exception = $_}
    $properties = [System.Collections.Generic.Dictionary[string, string]]::new()
    $properties.Add("target", "azkv-powershell-001")
    $properties.Add("type", "Keyvault")
    Write-ApplicationInsightsException -Exception $exception.Exception -properties $properties

    #>
    [CmdletBinding(DefaultParameterSetName = "Exception")]
    param (
        [Parameter(Mandatory = $false)]
        [Microsoft.ApplicationInsights.TelemetryClient]
        $Client,

        [Parameter(Mandatory = $true, ParameterSetName = "Exception")]
        [System.Management.Automation.ErrorRecord]
        $Exception,

        [Parameter(Mandatory = $true, ParameterSetName = "StringException")]
        [String]
        $ExceptionString,

        # [Parameter(Mandatory = $false, HelpMessage = "This is a dictionary<string, double> with additional information that will be added as 'customMeasurements' in Application Insights")]
        # [System.Collections.Generic.Dictionary[string, double]]
        # $Metrics = [System.Collections.Generic.Dictionary[string, double]]::new(),

        # [Parameter(Mandatory = $false, HelpMessage = "This is a dictionary<string, string> with additional information that will be added as 'customDimensions' in Application Insights")]
        # [System.Collections.Generic.Dictionary[string, string]]
        # $properties = [System.Collections.Generic.Dictionary[string, string]]::new(),

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Guid]$operationId = [Guid]::newGuid()
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

        $exceptionTelemetry = [Microsoft.ApplicationInsights.DataContracts.ExceptionTelemetry]::new($exception.Exception)
        $exceptionTelemetry.context.Operation.id = $operationId.Guid
        $exceptionTelemetry.ProblemId = $exception.Exception.Message
    }
    PROCESS {
        $client.TrackException($exceptionTelemetry)
        Write-Verbose ("Sent exception '$($Exception)' with '$($Metrics.Count)' metrics and '$($properties.Count)' properties to Application Insights.")
    }
    END {
        $Client.Flush()
        Write-Verbose ("Client Flushed")
    }
}


try { 0/0 } catch {$exception = $_}
Write-ApplicationInsightsException -Exception $exception