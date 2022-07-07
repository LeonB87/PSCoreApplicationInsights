Function new-powershellModuleMarkdown {
    <#
.SYNOPSIS
    Script for generating Markdown documentation based on information in PowerShell script files.

.DESCRIPTION
    All PowerShell script files have synopsis attached on the document. With this script markdown files are generated and saved within the target folder.

.PARAMETER ScriptFolder
    The folder that contains the scripts

.PARAMETER OutputFolder
    The folder were to safe the markdown files

.PARAMETER ExcludeFolders
    Exclude folder for generation. This is a comma seperated list

.PARAMETER KeepStructure
    Specified to keep the structure of the subfolders

.PARAMETER IncludeWikiTOC
Include the TOC from the Azure DevOps wiki to the markdown files

.PARAMETER SummaryLinkPattern
The pattern for the Url/ Defaults to '/Powershell/Scripts/'
this will create a link pointing to '/Powershell/Scripts/%script Basename%/%Script Name%.md

.PARAMETER SummaryTitleAsLink
Boolean whether to add links in the Summary page to the specific Powershell MD file

.NOTES
    Version:        1.0.0;
    Author:         Léon Boers;
    Creation Date:  07-07-2022;
    Purpose/Change: Initial script development;
    1.0.0:          Initial Release;

.EXAMPLE
    .\New-MDPowerShellScripts.ps1 -ScriptFolder "./" -OutputFolder "docs/powershell"  -ExcludeFolder ".local,test-templates" -KeepStructure $true -IncludeWikiTOC $false
.EXAMPLE
    .\New-MDPowerShellScripts.ps1 -ScriptFolder "./" -OutputFolder "docs/powershell"
.EXAMPLE
    .\New-MDPowerShellScripts.ps1 -ScriptFolder '.\Powershell\scripts\' -OutputFolder '.\Powershell\scripts\' -KeepStructure $true -WikiSummaryOutputfileName 'readme.md' -IncludeWikiSummary $true -IncludeWikiTOC $true -WikiTOCStyle 'Github' -SummaryTitleAsLink $true -SummaryLinkPattern '/Powershell/Scripts/'
#>
    [CmdletBinding()]

    Param (
        [Parameter(Mandatory = $true, Position = 0)][string]$moduleFolder,
        [Parameter(Mandatory = $true, Position = 1)][string]$OutputFolder
    )

    BEGIN {
        Write-Output ("moduleFolder                 : $($moduleFolder)")
        Write-Output ("OutputFolder                 : $($OutputFolder)")

    }
    PROCESS {
        try {
            Write-Information ("Starting documentation generation for folder $($moduleFolder)")

            if (!(Test-Path $OutputFolder)) {
                Write-Information ("Output path does not exists creating the folder: $($OutputFolder)")
                New-Item -ItemType Directory -Force -Path $OutputFolder
            }

            $outputFile = ("$($OutputFolder)\markdown.md")
            "" | Out-File $outputFile -Force

            $module = Get-ChildItem $moduleFolder -Filter '*.psm1' -Recurse

            if ($null -eq $module){
                return "No PowerShell Module files found in $($moduleFolder)"
            }

            Import-Module $module.FullName -Force

            $loadedModule = get-module -Name $module.BaseName

            if ($null -eq $loadedModule) {
                return "Module $($module.BaseName) not loaded"
            }
            foreach ($function in $loadedModule.ExportedCommands.Keys) {
                Write-Verbose ("Documenting function '$($function)'")

                $help = get-help -Name $function -Detailed

                ("## $($help.name)`r") | Out-File $outputFile -Append

                if ($help.syntax) {
                    ("`r``````PowerShell`r $($help.syntax)`r``````") | Out-File -FilePath $outputFile -Append
                }
                else {
                    Write-Warning ("Syntax not defined in file '$($function)'")
                }

                if ($help.description){
                    ("### Description`r") | Out-File $outputFile -Append

                    ("$($help.description.Text)`r") | Out-File $outputFile -Append

                } else {
                    Write-Warning ("Description not defined for function '$($function)'")
                }

                if ($help.Examples) {
                    ("### Examples`r") | Out-File -FilePath $outputFile -Append

                    forEach ($item in $help.Examples.Example) {
                        $title = $item.title.Replace('--------------------------', '').Replace('EXAMPLE', 'Example').trim()
                        ("#### $($title)`r") | Out-File -FilePath $outputFile -Append
                        if ($item.Code) {
                            ("``````PowerShell`r`n $($item.Code)`r`n```````r") | Out-File -FilePath $outputFile -Append
                        }
                    }
                }
                else {
                    Write-Warning ("Description not defined for function '$($function)'")
                }


            }

        }
        catch {
            Write-Error "Something went wrong while generating the output documentation: $_"
        }
    }
    END {}
}

new-powershellModuleMarkdown -moduleFolder ..\src\PSCoreApplicationInsights -OutputFolder ..\.local\.markdown