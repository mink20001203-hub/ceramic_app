param(
  [switch]$StagedOnly = $true
)

$ErrorActionPreference = "Stop"

function Get-TargetFiles {
  if ($StagedOnly) {
    $files = git diff --cached --name-only
  } else {
    $files = git ls-files
  }
  return @($files | Where-Object { $_ -and (Test-Path $_) })
}

$forbiddenFilePatterns = @(
  '^serviceAccountKey\.json$',
  'service-account.*\.json$',
  'client_secret.*\.json$',
  '^\.env(\..+)?$',
  '\.pem$',
  '\.p12$',
  '\.jks$',
  '\.keystore$',
  '^GoogleService-Info\.plist$'
)

$warningFilePatterns = @(
  '^android/app/google-services\.json$',
  '^lib/firebase_options\.dart$'
)

$secretContentPatterns = @(
  'BEGIN PRIVATE KEY',
  '-----BEGIN RSA PRIVATE KEY-----',
  'client_secret',
  'secret[_-]?key',
  'access[_-]?token',
  'refresh[_-]?token'
)

$files = Get-TargetFiles
$blockedFiles = New-Object System.Collections.Generic.List[string]
$warnFiles = New-Object System.Collections.Generic.List[string]
$blockedContentHits = New-Object System.Collections.Generic.List[string]

foreach ($file in $files) {
  foreach ($pattern in $forbiddenFilePatterns) {
    if ($file -match $pattern) {
      $blockedFiles.Add($file) | Out-Null
      break
    }
  }
  foreach ($pattern in $warningFilePatterns) {
    if ($file -match $pattern) {
      $warnFiles.Add($file) | Out-Null
      break
    }
  }
}

# staged content 검사
$stagedDiff = git diff --cached
foreach ($pattern in $secretContentPatterns) {
  if ($stagedDiff -match $pattern) {
    $blockedContentHits.Add($pattern) | Out-Null
  }
}

if ($warnFiles.Count -gt 0) {
  Write-Host "주의: 아래 파일은 공개 저장소 업로드 전 검토가 필요합니다." -ForegroundColor Yellow
  $warnFiles | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" -ForegroundColor Yellow }
}

if ($blockedFiles.Count -gt 0 -or $blockedContentHits.Count -gt 0) {
  Write-Host ""
  Write-Host "중단: 커밋하면 안 되는 민감 정보가 감지되었습니다." -ForegroundColor Red
  $blockedFiles | Sort-Object -Unique | ForEach-Object { Write-Host " - 파일: $_" -ForegroundColor Red }
  $blockedContentHits | Sort-Object -Unique | ForEach-Object { Write-Host " - 내용 패턴: $_" -ForegroundColor Red }
  exit 1
}

Write-Host "OK: 민감 정보 차단 규칙 통과" -ForegroundColor Green
exit 0
