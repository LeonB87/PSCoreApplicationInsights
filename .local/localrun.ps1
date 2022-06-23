<#
.SYNOPSIS
    Script for running local validation and documentation generation

.DESCRIPTION
    Script for running local validation and documentation generation. Run before each commit

.EXAMPLE
    .\LocalRun.ps1

#>
BEGIN {
    Write-Host '## Starting the local run of the analyzer scripts!' -ForegroundColor DarkBlue
}
PROCESS {
    Write-Host '## Processing the local PowerShell script and their operation' -ForegroundColor Green

    Write-Output ("Running automatic documentation of PowerShell")

    $OutputFolder = ".\.local\.markdown"
    $parameters = @{
        Module                = "PsCoreApplicationInsights"
        OutputFolder          = $OutputFolder
        AlphabeticParamsOrder = $true
        WithModulePage        = $true
        ExcludeDontShow       = $true
        Encoding              = [System.Text.Encoding]::UTF8
    }
    New-MarkdownHelp @parameters -force

    Write-Host '### Invoke script analyzer' -ForegroundColor Blue

    invoke-scriptanalyzer -Path .\src\PSCoreApplicationInsights\ -ReportSummary -ExcludeRule 'PSAvoidGlobalVars'

}
END {
    Write-Host '## Ending the local run of the analyzer scripts!' -ForegroundColor DarkBlue
}