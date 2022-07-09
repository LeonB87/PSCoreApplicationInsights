# PSCoreApplicationInsightst

[![ApplicationInsights Module](https://github.com/LeonB87/PSCoreApplicationInsights/actions/workflows/psmodule.yml/badge.svg)](https://github.com/LeonB87/PSCoreApplicationInsights/actions/workflows/psmodule.yml)

> Powershell logging to Azure Application Insight

A Powershell Core Module that simplifies logging to Application Insights. This uses the Built-in Telemetry client from Powershell Core 7 and it is built entirely in Powershell.
It offers a few simple functions to log information to Application Insights to reduce the clutter in your scripts.

## Installation

```powershell
Install-Module -Name PSCoreApplicationInsights
```

## Basic Usage

Create a new Application Insights Client

```powershell
New-ApplicationInsightsClient [-InstrumentationKey] <Guid> [-WhatIf] [-Confirm] [<CommonParameters>]
```
> Use the Instrumentation Key found in the Azure Portal on your Application Insights Instance.

The Application Insights client is stored as $global:AIClient.

to store the client in a variable to specify when writing logs:

```powershell
$client = New-ApplicationInsightsClient -InstrumentationKey c323cf10-da34-4a73-9eac-000000000000
```

## Sending Trace information application insights

### Syntax

```powershell
Write-ApplicationInsightsTrace [[-Client] <TelemetryClient>] [-Message] <String> [[-SeverityLevel] <String>] [[-properties] <System.Collections.Generic.Dictionary`2[System.String,System.String]>] [<CommonParameters>]
```

| Property | Description | Mandatory | default | Allowed Values |
| ---| ---| --- | --- | --- |
| Message |  | true | | |
| Client | The Application Insights client to write the message to. If not specifies, uses the $global:AIclient  | false | | |
| SeverityLevel | The severity level of the trace | false | Information | - Information <br> - Verbose <br> - Warning <br> - Error <br> - Critical |
| properties | a Dictionary<string,string> with custom properties that will be added as "customDimensions"| false | |

### Example 1

```powershell
Write-ApplicationInsightsTrace -Message "This is a test message as Critical" -SeverityLevel "Critical"
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

## Module Functions

### New-ApplicationInsightsClient

#### Description

Create a new Application insights Client by supplying an Instrumentation Key of your Application Insights instance.

#### Syntax


```PowerShell
 New-ApplicationInsightsClient [-InstrumentationKey] <Guid> [-WhatIf] [-Confirm] [<CommonParameters>]
```

#### Examples

##### Example 1

```PowerShell
 New-ApplicationInsightsClient -InstrumentationKey c323cf10-da34-4a73-9eac-000000000000
```

##### Example 2

```PowerShell
 $client = New-ApplicationInsightsClient -InstrumentationKey c323cf10-da34-4a73-9eac-000000000000
```

### Parameters

#### InstrumentationKey

The Instrumentation Key of your Application Insights instance.
| | |
|-|-|
| Type: | Guid |
| PipelineInput : | false |
| Position : | 1 |
| Required : | true |

### Invoke-ApplicationInsightsMeasuredCommand

#### Description

Invoke a scriptblock that is measured by Application Insights. This created a timespan and writes the timing to Application Insights. The output of the scriptblock is returned.

#### Syntax

```PowerShell
 Invoke-ApplicationInsightsMeasuredCommand [[-Client] <TelemetryClient>] [-scriptblock] <ScriptBlock> [-name] <String> [<CommonParameters>]
```

#### Examples

##### Example 1

```PowerShell
 Invoke-ApplicationInsightsMeasuredCommand -ScriptBlock { start-sleep -seconds 1 } -Name "slow script"
```

### Parameters

#### Client

The Application Insights Telemetry Client. Defaults to $global:AIClient
| | |
|-|-|
| Type: | TelemetryClient |
| PipelineInput : | false |
| Position : | 1 |
| Required : | false |

### results

Example Logs:

> ![image](https://user-images.githubusercontent.com/10503724/178105199-b1a3f4d2-378f-43f9-a08a-3476486a411a.png)

Example of the Performance blade

> ![image](https://user-images.githubusercontent.com/10503724/178105139-e437806f-d563-4975-8296-a1d69b8f653d.png)

Performance is shown on the Overview Blade

![image](https://user-images.githubusercontent.com/10503724/178105334-7b62225a-d82f-433b-b158-bf9bce5e432e.png)

## TODO

- [ ] Automate Deployment
- [ ] Write Documentation for each function
  - [x] Creating a new Application Insights Client
  - [ ] Setting Client information
  - [ ] Sending Trace
  - [ ] Sending Metric
  - [ ] Sending Exception
  - [ ] Sending Request
  - [x] Invoking Measured Command
- [ ] Create an example azure dashboard
