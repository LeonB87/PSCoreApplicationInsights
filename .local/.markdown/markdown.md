
## Invoke-ApplicationInsightsMeasuredCommand
```PowerShell @{syntaxItem=System.Object[]}```
## New-ApplicationInsightsClient
```PowerShell @{syntaxItem=@{parameter=System.Management.Automation.PSObject[]; name=New-ApplicationInsightsClient}}```
### Description
Create a new Application insights Client by supplying an Instrumentation Key of your Application Insights instance.
### Examples
#### Example 1
```PowerShell
 New-ApplicationInsightsClient -InstrumentationKey c323cf10-da34-4a73-9eac-000000000000
```
#### Example 2
```PowerShell
 $client = New-ApplicationInsightsClient -InstrumentationKey c323cf10-da34-4a73-9eac-000000000000
```
## Set-ApplicationInsightsClientInformation
```PowerShell @{syntaxItem=@{parameter=System.Management.Automation.PSObject[]; name=Set-ApplicationInsightsClientInformation}}```
### Description
Changes the Telemetry Client information. This currently supports changing the user and Device information.
This information will be displayed in the Application Insights logging.
### Examples
#### Example 1
```PowerShell
 $userInformation = @{AuthenticatedUserId = "John Doe"; UserAgent = "PS Core 7.2.5"} ; Set-ApplicationInsightsClientInformation -UserInformation $userInformation
```
## Write-ApplicationInsightsException
```PowerShell @{syntaxItem=System.Object[]}```
## Write-ApplicationInsightsMetric
```PowerShell @{syntaxItem=System.Object[]}```
## Write-ApplicationInsightsRequest
```PowerShell @{syntaxItem=System.Object[]}```
## Write-ApplicationInsightsTrace
```PowerShell @{syntaxItem=@{parameter=System.Management.Automation.PSObject[]; name=Write-ApplicationInsightsTrace}}```
### Description
Write a simple Trace message to the Application Insights service. Supports several Severity levels
### Examples
#### Example 1
```PowerShell
 Write-ApplicationInsightsTrace -Client $client -Message "This is a test message as Critical" -SeverityLevel "Critical"
```
#### Example 2
```PowerShell
 $properties = [System.Collections.Generic.Dictionary[string, string]]::new()
$properties.Add("target", "azkv-powershell-001")
$properties.Add("type", "Keyvault")
Write-ApplicationInsightsTrace -Client $client -Message "Created new keyvault" -SeverityLevel "Information" -properties $properties
```
