Import-Module .\src\PSCoreApplicationInsights\PSCoreApplicationInsights.psm1 -Force

Describe "Creating a Client" {
    New-ApplicationInsightsClient -InstrumentationKey "c323cf10-da34-4a73-9eac-47dad64d840b"

    It "Should create a client"{
        $global:AIClient.GetType().Name | should -BeExactly "TelemetryClient"
    }

    It "Should have the set instrumentationkey" {
        $global:AIClient.InstrumentationKey | Should -Be "c323cf10-da34-4a73-9eac-47dad64d840b"
    }
}