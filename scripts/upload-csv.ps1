Param(
  [string]$Bucket="datasets",
  [string]$FileUrl="https://people.sc.fsu.edu/~jburkardt/data/csv/airtravel.csv",
  [string]$DestName="airtravel.csv",
  [string]$MinioEndpoint="http://localhost:30900",
  [string]$AccessKey="minioadmin",
  [string]$SecretKey="minioadmin123!"
)

$ErrorActionPreference = "Stop"

$downloadDir = Join-Path $PWD "downloads"
if (!(Test-Path $downloadDir)) { New-Item -ItemType Directory -Path $downloadDir | Out-Null }
$localPath = Join-Path $downloadDir $DestName

Write-Host "Downloading sample CSV..."
Invoke-WebRequest -Uri $FileUrl -OutFile $localPath

Write-Host "Ensuring MinIO client (mc) is available..."
$mcPath = Join-Path $PWD "mc.exe"
if (!(Test-Path $mcPath)) {
  $mcUrl = "https://dl.min.io/client/mc/release/windows-amd64/mc.exe"
  Invoke-WebRequest -Uri $mcUrl -OutFile $mcPath
}

Write-Host "Configuring mc alias..."
& $mcPath alias set local $MinioEndpoint $AccessKey $SecretKey

Write-Host "Creating bucket if missing..."
& $mcPath mb local/$Bucket 2>$null

Write-Host "Uploading CSV to MinIO..."
& $mcPath cp $localPath local/$Bucket/$DestName

Write-Host "Set public download on bucket (optional)..."
& $mcPath anonymous set download local/$Bucket

Write-Host "Done. Public URL: $MinioEndpoint/$Bucket/$DestName"