Import-Module .\src\PSCoreApplicationInsights\PSCoreApplicationInsights.psm1 -Force

Describe "Creating a Client" {

    New-ApplicationInsightsClient -InstrumentationKey "492e4c9e-d902-4645-9275-82d48a6667c8"

    It "should exist" {
        $global:AIClient | should -not -BeNullOrEmpty
    }

    It "Should create a TelemetryClient" {
        $global:AIClient.GetType().Name | should -BeExactly "TelemetryClient"
    }

    It "Should have the set instrumentation key" {
        $global:AIClient.InstrumentationKey | Should -Be "492e4c9e-d902-4645-9275-82d48a6667c8"
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
}


# Describe "Sending Trace" {


#     $VerbosePreference = 'Continue'
#     $message = "This is my message"

#     $verbose = Write-ApplicationInsightsTrace -Message $message -Verbose 4>&1

#     It "Should send a trace to Application Insights" {
#         $verbose.message.Contains("VERBOSE: Sent message '$message' to Application Insights.")
#     }

#     It "Should flush the client" {
#         $verbose.message.Contains("VERBOSE: Client Flushed")
#     }

#     $properties = [System.Collections.Generic.Dictionary[string, string]]::new()
#     $properties.Add("target", "azkv-powershell-001")
#     $properties.Add("type", "Keyvault")
#     $verbose = Write-ApplicationInsightsTrace -Message $message -properties $properties -Verbose 4>&1

#     It "Should find 2 properties" {
#         $verbose.message.Contains("Received '2' properties to add to the message")
#     }

#     It "Should send a trace to Application Insights with 2 properties" {
#         $verbose.message.Contains("VERBOSE: Sent message '$message' with '2' properties to Application Insights.")
#     }

#     It "Should flush the client" {
#         $verbose.message.Contains("VERBOSE: Client Flushed")
#     }


#     $verbose = Write-ApplicationInsightsTrace -Message $message -SeverityLevel Information -Verbose 4>&1

#     It "Should set the severity level to 'Information'" {
#         $verbose.message.Contains("Received 'Information' severity level for the message 'This is my message'")
#     }

#     It "Should send a trace to Application Insights" {
#         $verbose.message.Contains("VERBOSE: Sent message '$message' to Application Insights.")
#     }

#     It "Should flush the client" {
#         $verbose.message.Contains("VERBOSE: Client Flushed")
#     }

#     $verbose = Write-ApplicationInsightsTrace -Message $message -SeverityLevel Warning -Verbose 4>&1

#     It "Should set the severity level to 'Warning'" {
#         $verbose.message.Contains("Received 'Information' severity level for the message 'This is my message'")
#     }

#     It "Should send a trace to Application Insights" {
#         $verbose.message.Contains("VERBOSE: Sent message '$message' to Application Insights.")
#     }

#     It "Should flush the client" {
#         $verbose.message.Contains("VERBOSE: Client Flushed")
#     }

#     $verbose = Write-ApplicationInsightsTrace -Message $message -SeverityLevel Critical -Verbose 4>&1

#     It "Should set the severity level to 'Critical'" {
#         $verbose.message.Contains("Received 'Information' severity level for the message 'This is my message'")
#     }

#     It "Should send a trace to Application Insights" {
#         $verbose.message.Contains("VERBOSE: Sent message '$message' to Application Insights.")
#     }

#     It "Should flush the client" {
#         $verbose.message.Contains("VERBOSE: Client Flushed")
#     }

#     $verbose = Write-ApplicationInsightsTrace -Message $message -SeverityLevel Error -Verbose 4>&1

#     It "Should set the severity level to 'Error'" {
#         $verbose.message.Contains("Received 'Information' severity level for the message 'This is my message'")
#     }

#     It "Should send a trace to Application Insights" {
#         $verbose.message.Contains("VERBOSE: Sent message '$message' to Application Insights.")
#     }

#     It "Should flush the client" {
#         $verbose.message.Contains("VERBOSE: Client Flushed")
#     }

#     $verbose = Write-ApplicationInsightsTrace -Message $message -SeverityLevel Warning -Verbose 4>&1

#     It "Should set the severity level to 'Warning'" {
#         $verbose.message.Contains("Received 'Information' severity level for the message 'This is my message'")
#     }

#     It "Should send a trace to Application Insights" {
#         $verbose.message.Contains("VERBOSE: Sent message '$message' to Application Insights.")
#     }

#     It "Should flush the client" {
#         $verbose.message.Contains("VERBOSE: Client Flushed")
#     }


# }