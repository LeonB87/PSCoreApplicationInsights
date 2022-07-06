Import-Module .\src\PSCoreApplicationInsights\PSCoreApplicationInsights.psm1 -Force

Describe "Creating a Client" {
    New-ApplicationInsightsClient -InstrumentationKey "c323cf10-da34-4a73-9eac-47dad64d840b"

    It "should exist" {
        $global:AIClient | should -not -BeNullOrEmpty
    }

    It "Should create a TelemetryClient" {
        $global:AIClient.GetType().Name | should -BeExactly "TelemetryClient"
    }

    It "Should have the set instrumentationkey" {
        $global:AIClient.InstrumentationKey | Should -Be "c323cf10-da34-4a73-9eac-47dad64d840b"
    }
}

Describe "Client Properties" {

    It "Should have a default user Agent" {
        $global:AIClient.Context.User.UserAgent | should -Not -BeNullOrEmpty
    }

    It "Should have a specific default user Agent" {
        $global:AIClient.Context.User.UserAgent | should -Be ("PS $($psversiontable.PSEdition) $($psversiontable.PSVersion)")
    }

    It "Should have a specific default user" {
        $global:AIClient.Context.User.AuthenticatedUserId | should -Be (whoami)
    }


    $updatedUserInformation = @{
        AuthenticatedUserId = "MyNewUserId12345"
        UserAgent           = "Modified User Agent"
    }

    # Set-ApplicationInsightsClientInformation -UserInformation $updatedUserInformation

    # It "Should update the Authenticated User Id"{
    #     $global:AIClient.Context.User.AuthenticatedUserId | should -Be "MyNewUserId12345"
    # }

    # It "Should update the UserAgent" {
    #     $global:AIClient.Context.User.UserAgent | should -Be "Modified User Agent"
    # }

}