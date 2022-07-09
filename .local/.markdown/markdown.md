
## Invoke-ApplicationInsightsMeasuredCommand
### Description
Invoke a scriptblock that is measured by Application Insights. This created a timespan and writes the timing to Application Insights. The output of the scriptblock is returned.
### Syntax
```PowerShell Invoke-ApplicationInsightsMeasuredCommand [[-Client] <TelemetryClient>] [-scriptblock] <ScriptBlock> [-name] <String> [<CommonParameters>]```
### Examples
#### Example 1
```PowerShell
 Invoke-ApplicationInsightsMeasuredCommand -ScriptBlock { start-sleep -seconds 1 } -Name "slow script"
```
## Parameters
### Client
The Application Insights Telemetry Client. Defaults to $global:AIClient
| | |
|-|-|
| Type: | TelemetryClient |
| PipelineInput : | false |
| Position : | 1 |
| Required : | false |

### scriptblock
The scriptblock you wish to execute and measure.
| | |
|-|-|
| Type: | ScriptBlock |
| PipelineInput : | false |
| Position : | 2 |
| Required : | true |

### name
This is a name you wish to give to the scriptblock. This is used to identify the scriptblock in Application Insights.
| | |
|-|-|
| Type: | String |
| PipelineInput : | false |
| Position : | 3 |
| Required : | true |

## New-ApplicationInsightsClient
### Description
Create a new Application insights Client by supplying an Instrumentation Key of your Application Insights instance.
### Syntax
```PowerShell New-ApplicationInsightsClient [-InstrumentationKey] <Guid> [-WhatIf] [-Confirm] [<CommonParameters>]```
### Examples
#### Example 1
```PowerShell
 New-ApplicationInsightsClient -InstrumentationKey c323cf10-da34-4a73-9eac-000000000000
```
#### Example 2
```PowerShell
 $client = New-ApplicationInsightsClient -InstrumentationKey c323cf10-da34-4a73-9eac-000000000000
```
## Parameters
### InstrumentationKey
The Instrumentation Key of your Application Insights instance.
| | |
|-|-|
| Type: | Guid |
| PipelineInput : | false |
| Position : | 1 |
| Required : | true |

## Set-ApplicationInsightsClientInformation
### Description
Changes the Telemetry Client information. This currently supports changing the user and Device information.
This information will be displayed in the Application Insights logging.
### Syntax
```PowerShell Set-ApplicationInsightsClientInformation [[-Client] <TelemetryClient>] [[-UserInformation] <Hashtable>] [[-DeviceInformation] <Hashtable>] [-WhatIf] [-Confirm] [<CommonParameters>]```
### Examples
#### Example 1
```PowerShell
 $userInformation = @{AuthenticatedUserId = "John Doe"; UserAgent = "PS Core 7.2.5"} ; Set-ApplicationInsightsClientInformation -UserInformation $userInformation
```
## Parameters
### Client
The Application Insights Telemetry Client. Defaults to $global:AIClient
| | |
|-|-|
| Type: | TelemetryClient |
| PipelineInput : | false |
| Position : | 1 |
| Required : | false |

### UserInformation
A hashtable with User Information

To find valid properties, Create a client and look at the current properties. $global:AIClient.context.User
| | |
|-|-|
| Type: | Hashtable |
| PipelineInput : | false |
| Position : | 2 |
| Required : | false |

### DeviceInformation
A hashtable with device information.

To find valid properties, Create a client and look at the current properties. $global:AIClient.context.Device
| | |
|-|-|
| Type: | Hashtable |
| PipelineInput : | false |
| Position : | 3 |
| Required : | false |

## Write-ApplicationInsightsException
### Syntax
```PowerShell [32;1msyntaxItem[0m
[32;1m----------[0m
{@{name=Write-ApplicationInsightsException; CommonParameters=True; parameter=System.Object[]}, @{name=Write-ApplicationInsightsException; CommonParameters=True; parameter=System.Object[]}}```
## Parameters
### Client
### Exception
### ExceptionString
### Metrics
| | |
|-|-|
| Type: | Dictionary[string,double] |
| PipelineInput : | false |
| Position : | Named |
| Required : | false |
| parameterSetName : | (All) |

### properties
| | |
|-|-|
| Type: | Dictionary[string,string] |
| PipelineInput : | false |
| Position : | Named |
| Required : | false |
| parameterSetName : | (All) |

## Write-ApplicationInsightsMetric
### Syntax
```PowerShell [32;1msyntaxItem[0m
[32;1m----------[0m
{@{name=Write-ApplicationInsightsMetric; CommonParameters=True; parameter=System.Object[]}}```
## Parameters
### Client
### Metric
### Name
### properties
| | |
|-|-|
| Type: | Dictionary[string,string] |
| PipelineInput : | false |
| Position : | 3 |
| Required : | false |
| parameterSetName : | (All) |

## Write-ApplicationInsightsRequest
### Syntax
```PowerShell [32;1msyntaxItem[0m
[32;1m----------[0m
{@{name=Write-ApplicationInsightsRequest; CommonParameters=True; parameter=System.Object[]}}```
## Parameters
### Client
### Duration
### Name
### StartTime
### properties
| | |
|-|-|
| Type: | Dictionary[string,string] |
| PipelineInput : | false |
| Position : | 6 |
| Required : | false |
| parameterSetName : | (All) |

### responseCode
### success
### url
| | |
|-|-|
| Type: | string |
| PipelineInput : | false |
| Position : | 7 |
| Required : | false |
| parameterSetName : | (All) |

## Write-ApplicationInsightsTrace
### Description
Write a simple Trace message to the Application Insights service. Supports several Severity levels
### Syntax
```PowerShell Write-ApplicationInsightsTrace [[-Client] <TelemetryClient>] [-Message] <String> [[-SeverityLevel] <String>] [[-properties] <Dictionary`2>] [<CommonParameters>]```
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
## Parameters
### Client
This is the Telemetry Client used to send the message. If not specified, Defaults to "$global:AICient"
| | |
|-|-|
| Type: | TelemetryClient |
| PipelineInput : | false |
| Position : | 1 |
| Required : | false |

### Message
The message you want to send to Application Insights.
| | |
|-|-|
| Type: | String |
| PipelineInput : | false |
| Position : | 2 |
| Required : | true |

### SeverityLevel
The severity level of the message. Default is 'Information'.

Allowed values: 'Verbose', 'Information', 'Warning', 'Error', 'Critical'
| | |
|-|-|
| Type: | String |
| DefaultValue : | information |
| PipelineInput : | false |
| Position : | 3 |
| Required : | false |

### properties
A Dictionary of properties you want to send with the message.
| | |
|-|-|
| Type: | Dictionary`2 |
| PipelineInput : | false |
| Position : | 4 |
| Required : | false |

