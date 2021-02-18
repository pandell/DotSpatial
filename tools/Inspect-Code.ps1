#!/usr/bin/env pwsh

#Requires -Version 7
#spell-checker:words inspectcode lastexitcode pwsh resharper

<#
.SYNOPSIS
Runs R# inspection analyzer for this project.

.DESCRIPTION
This script executes JetBrains InspectCode command-line tool for the specified solution
or the first solution found in parent directory.

.PARAMETER ClearCache
Deletes cache directory from previous run if it exists.
By default cache from previous run will be used
to reduce time needed to run the inspections.

.PARAMETER SolutionPath
Path to the solution to run inspections against.
By default the first solution found in the parent directory (..).

.EXAMPLE
tools/Inspect-Code.ps1
# => Runs R# analysis using existing cache for the first solution found.

.EXAMPLE
tools/Inspect-Code.ps1 -ClearCache
# => Clears cache and runs R# analysis for the first solution found.

.EXAMPLE
tools/Inspect-Code.ps1 SamplePliWeb.sln -ClearCache
# => Clears cache and runs R# analysis for SamplePliWeb.sln

.LINK
https://www.jetbrains.com/help/resharper/InspectCode.html

#>
Param(
    [switch] $ClearCache = $false,
    $SolutionPath = $null
)

# setup error handling policy
$ErrorActionPreference = "Stop"
trap {
    $Host.UI.WriteErrorLine("Failed to run Inspect-Code.ps1: $_")
    $Host.UI.WriteErrorLine($_.ScriptStackTrace)
    exit 1
}

# lookup solution if not specified, otherwise validate solution path
if ($null -eq $SolutionPath) {
    $solutions = Get-ChildItem "$PSScriptRoot/../*.sln"
    $solutionCount = ($solutions).Count
    if ($solutionCount -eq 0) {
        Write-Host -ForegroundColor Red "No solutions found, please specify SolutionPath."
        exit 2
    } elseif ($solutionCount -gt 1) {
        Write-Warning "⚠ Multiple solutions found, please specify SolutionPath if default is incorrect."
    }
    $SolutionPath = $solutions[0].FullName
    Write-Host -ForegroundColor DarkGreen "Defaulting solution to $SolutionPath"
} elseif (-not (Test-Path $SolutionPath)) {
    Write-Host -ForegroundColor Red "Solution path '$($SolutionPath)', not found."
    exit 2
}

# prepare inspectcode environment
$solutionName = [System.IO.Path]::GetFileNameWithoutExtension($SolutionPath)
$inspectHome = [IO.Path]::GetFullPath("$([IO.Path]::GetTempPath())/inspectcode-$solutionName")
$inspectOut = [IO.Path]::GetFullPath("$inspectHome/report.xml")
$inspectCache = [IO.Path]::GetFullPath("$inspectHome/cache")
if (Test-Path $inspectCache) {
    if ($ClearCache) {
        Write-Host -ForegroundColor DarkYellow "Removing existing cache $inspectCache"
        Remove-Item -Force -Recurse $inspectCache
    } else {
        Write-Host -ForegroundColor DarkGreen "Using existing cache $inspectCache"
    }
}

# run "dotnet build" to make sure "Debug" build is up-to-date
# this fixes an issue in inspectcode where inspectcode doesn't
# include dynamically-generated files in analysis (thus reporting
# false positives caused by the missing files, e.g. "Resources.Designer.cs")
Write-Host -ForegroundColor DarkGray "dotnet build"
dotnet build

# run inspectcode
Write-Host -ForegroundColor DarkGray "dotnet tool restore"
dotnet tool restore | Out-Null
Write-Host -ForegroundColor DarkGray "dotnet tool run jb inspectcode"
dotnet tool run jb inspectcode --severity=SUGGESTION --output=$inspectOut --format=xml --caches-home=$inspectCache $SolutionPath
$inspectResultColor = if ($LASTEXITCODE -eq 0) { "Green" } else { "Red" }
Write-Host -NoNewline -ForegroundColor DarkGray "inspectcode exit code: "
Write-Host -ForegroundColor $inspectResultColor $LASTEXITCODE

# print issues
[xml]$report = Get-Content $inspectOut
$issueTypes = $report.SelectNodes("//IssueType") | Group-Object -AsHashTable -Property Id
$issues = $report.SelectNodes("//Issue")
if ($issues.Count) {
    $issues | ForEach-Object {
        $issueType = $issueTypes[$_.TypeId]
        Write-Host -ForegroundColor DarkRed -NoNewline "$($_.File):$($_.Line): "
        if ($issueType) {
            Write-Host -ForegroundColor Yellow -NoNewline "$($issueType.Severity): "
        }
        Write-Host -ForegroundColor DarkYellow $_.Message
    }
    Write-Host -ForegroundColor Red "Found $($issues.Count) issues"
    exit 2
} else {
    Write-Host -ForegroundColor Green "No issues found 👍"
}
