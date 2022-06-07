# PSCoreApplicationInsightst

> Powershell logging to Azure Application Insights

A Powershell Core Module that simplifies logging to Application Insights. This uses the Built-in Telemetry client from Powershell Core 7 and it is built entirely in Powershell.
It offers a few simple functions to log information to Application Insights to reduce the clutter in your scripts.

## Installation

```powershell
Install-Module -Name PSCoreApplicationInsights
```

## Basic Usage

Create a new Application Insights Client
> Use the Instrumentation Key found in the Azure Portal on your Application Insights Instance.

```powershell
$client = New-ApplicationInsightsClient -InstrumentationKey c323cf10-da34-4a73-9eac-000000000000
```

## Sending Trace information application insights

Command:

```powershell
Write-ApplicationInsightsTrace [-Client] <TelemetryClient> [-Message] <String> [[-SeverityLevel] <String>] [[-properties] <Dictionary`2>] [<CommonParameters>]
```

| Property | Description | Mandatory | default | Allowed Values |
| ---| ---| --- | --- | --- |
| Message | | true | | |
| SeverityLevel | The severity level of the trace | false | Information | - Information <br> - Verbose <br> - Warning <br> - Error <br> - Critical |
| properties | a Dictionary<string,string> with custom properties that will be added as "customDimensions"| false | |

### Example 1

```powershell
Write-ApplicationInsightsTrace -Client $client -Message "This is a test message as Critical" -SeverityLevel "Critical"
```

Result:

> ![image](https://user-images.githubusercontent.com/10503724/172461749-8254dc0a-50a9-4ed8-9643-dd62cf3a5b65.png)

### Example 2

```powershell
    $properties = [System.Collections.Generic.Dictionary[string, string]]::new()

    $properties.Add("target", "azkv-powershell-001")
    $properties.Add("type", "Keyvault")

    Write-ApplicationInsightsTrace -Client $client -Message "Created new keyvault" -SeverityLevel "Information" -properties $properties
```

Result:

> ![image](https://user-images.githubusercontent.com/10503724/172466760-b0a0c258-3a77-4f8e-91ea-7b487bf05042.png)

## TODO

- [ ] Automate Deployment
- [ ] Write Documentation for each function
  - [x] Creating a new Application Insights Client
  - [ ] Setting Client information
  - [ ] Sending Trace
  - [ ] Sending Metric
  - [ ] Sending Exception
  - [ ] Sending Request
  - [ ] Invoking Measured Command
- [ ] Create an example azure dashboard
