# PSCoreApplicationInsights

A Powershell Core Module that simplifies logging to Application Insights

## Installation

```powershell
Install-Module -Name PSCoreApplicationInsights
```

## Basic Usage

- Create new Application Insights Client

```powershell
$client = New-ApplicationInsightsClient -InstrumentationKey c323cf10-da34-4a73-9eac-000000000000
```

- write a trace to appliation insights

```powershell
Write-ApplicationInsightsTrace -Client $client -Message "This is a test message as Critical" -SeverityLevel "Critical"
```

## TODO:

- [ ] Automate Deployment
- [ ] Write Documentation for each function
  - [x] Creating a new Application Insights Client
  - [ ] Setting Client information
  - [ ] Sending Trace
  - [ ] Sending Metric
  - [ ] Sending Exception
  - [ ] Sending Request
  - [ ] Invoking Measured Command
- [ ] Create example azure dashboard
