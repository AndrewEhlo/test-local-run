param (
    [string]$targetFolder = "VirtoLocal",
    [string]$frontendRelease = "latest", # https://github.com/VirtoCommerce/vc-frontend/releases
    [string]$vcModulesBundle = "v10" # https://github.com/VirtoCommerce/vc-modules/tree/master/bundles
)

# download packages.json file for the backend
$backendDir = Join-Path $targetFolder "backend"
New-Folder $backendDir
$stablePackagesJsonUrl = "https://raw.githubusercontent.com/VirtoCommerce/vc-modules/refs/heads/master/bundles/$vcModulesBundle/package.json"
$stablePackagesJsonPath = Join-Path $backendDir "stable-packages.json"
Invoke-WebRequest -Uri $stablePackagesJsonUrl -OutFile $stablePackagesJsonPath

build backend
vc-build install --package-manifest-path $stablePackagesJsonPath `
    --probing-path $backendDir/publish/platform/app_data/modules `
    --discovery-path $backendDir/publish/modules `
    --root $backendDir/publish/platform `
    --skip-dependency-solving

# build backend Docker image
docker build --no-cache -t "vc-platform:local-latest" -f $backendDir/Dockerfile $backendDir
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to build backend Docker image" -ForegroundColor Red
    Write-Host "Build command failed with exit code: $LASTEXITCODE" -ForegroundColor Red
    Write-Host "Build output: $buildResult" -ForegroundColor Red
    exit 1
}

#remove publish folder
if (Test-Path -Path ./backend/publish) {
    Remove-Item -Recurse -Force ./backend/publish
}

# download and extract frontend files
$frontendDir = Join-Path $targetFolder "frontend"
New-Folder $frontendDir
if ($frontendRelease -eq "latest") {
    $releaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/VirtoCommerce/vc-frontend/releases/latest"
}
else {
    $releases = Invoke-RestMethod -Uri "https://api.github.com/repos/VirtoCommerce/vc-frontend/releases"
    $releaseInfo = $releases | Where-Object { $_.tag_name -eq $frontendRelease }
}
$assets = $releaseInfo.assets
$zipName = $assets.name
Invoke-WebRequest -Uri $assets.browser_download_url -OutFile $frontendDir/$zipName
Expand-Archive -Path $frontendDir/$zipName -DestinationPath $frontendDir/artifact
Remove-Item -Path $frontendDir/$zipName

# build frontend Docker image
Write-Host "Building frontend Docker image..." -ForegroundColor Yellow
$buildResult = docker build -t "vc-frontend:local-latest" -f $frontendDir/Dockerfile $frontendDir
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to build frontend Docker image" -ForegroundColor Red
    Write-Host "Build command failed with exit code: $LASTEXITCODE" -ForegroundColor Red
    Write-Host "Build output: $buildResult" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Frontend Docker image built successfully" -ForegroundColor Green
Remove-Item -Recurse -Force $frontendDir/artifact