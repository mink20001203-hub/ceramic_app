$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$toolsDir = Join-Path $projectRoot "tools"

if (-not (Test-Path $toolsDir)) {
  Write-Error "tools directory not found: $toolsDir"
}

$jdkDir = Get-ChildItem $toolsDir -Directory | Where-Object { $_.Name -like "jdk-*" } | Select-Object -First 1
if ($null -eq $jdkDir) {
  Write-Error "No local JDK found under $toolsDir (expected folder name like jdk-21...)"
}

$env:JAVA_HOME = $jdkDir.FullName
$env:Path = "$($jdkDir.FullName)\bin;$env:Path"

Write-Host "[rules-test] JAVA_HOME=$env:JAVA_HOME"
Write-Host "[rules-test] Running npm run test:rules"

npm run test:rules
