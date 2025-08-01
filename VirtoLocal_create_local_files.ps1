param (
    [string]$targetFolder = "VirtoLocal",
    [string]$postgresVersion = "16.9",
    [string]$elasticsearchVersion = "8.18.0",
    [string]$frontendRelease = "latest", # https://github.com/VirtoCommerce/vc-frontend/releases
    [string]$vcModulesBundle = "v10" # https://github.com/VirtoCommerce/vc-modules/tree/master/bundles
)
function New-Folder($folder) {
    try {
        $folder = Resolve-Path $folder -ErrorAction Stop
        Write-Host "Folder exists: $folder" -ForegroundColor Green
    }
    catch {
        Write-Host "Target folder '$folder' does not exist, creating it..." -ForegroundColor Yellow
        New-Item $folder -ItemType Directory
    }
}

# create target folder
New-Folder $targetFolder

# create .env file
$envFile = Join-Path $targetFolder ".env"

# Function to generate random password
function New-RandomPassword {
    param([int]$Length = 12)
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
    $password = ""
    for ($i = 0; $i -lt $Length; $i++) {
        $password += $chars[(Get-Random -Maximum $chars.Length)]
    }
    return $password
}

$envFileContent = @"
PGSQL_VERSION=$postgresVersion
STACK_VERSION=$elasticsearchVersion
DOCKER_PLATFORM_PORT=8090
ES_PORT=9200
KIBANA_PORT=5601
DB_PASSWORD=$(New-RandomPassword)
REDIS_PASSWORD=$(New-RandomPassword)
ELASTIC_PASSWORD=$(New-RandomPassword)
KIBANA_PASSWORD=$(New-RandomPassword)
"@
Set-Content -Path $envFile -Value $envFileContent

# download files
# donwload scripts
$scriptsDir = Join-Path $targetFolder "scripts"
New-Folder $scriptsDir
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AndrewEhlo/test-local-run/refs/heads/main/scripts/check-installed-modules.ps1" -OutFile (Join-Path $scriptsDir "check-installed-modules.ps1")
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AndrewEhlo/test-local-run/refs/heads/main/scripts/setup-sampledata.ps1" -OutFile (Join-Path $scriptsDir "setup-sampledata.ps1")
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AndrewEhlo/test-local-run/refs/heads/main/scripts/wait-for-it.sh" -OutFile (Join-Path $scriptsDir "wait-for-it.sh")
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AndrewEhlo/test-local-run/refs/heads/main/scripts/watch-url-up.ps1" -OutFile (Join-Path $scriptsDir "watch-url-up.ps1")

# download packages.json file for the backend
$backendDir = Join-Path $targetFolder "backend"
New-Folder $backendDir
$stablePackagesJsonUrl = "https://raw.githubusercontent.com/VirtoCommerce/vc-modules/refs/heads/master/bundles/$vcModulesBundle/package.json"
$stablePackagesJsonPath = Join-Path $backendDir "stable-packages.json"
Invoke-WebRequest -Uri $stablePackagesJsonUrl -OutFile $stablePackagesJsonPath

# download Dockerfile for the backend
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AndrewEhlo/test-local-run/refs/heads/main/backend/Dockerfile" -OutFile (Join-Path $backendDir "Dockerfile")

# download frontend files
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

#download cofig files for the frontend
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AndrewEhlo/test-local-run/refs/heads/main/frontend/Dockerfile" -OutFile (Join-Path $frontendDir "Dockerfile")
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AndrewEhlo/test-local-run/refs/heads/main/frontend/nginx.conf" -OutFile (Join-Path $frontendDir "nginx.conf")


# download docker-compose file
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AndrewEhlo/test-local-run/refs/heads/main/docker-compose.yml" -OutFile (Join-Path $targetFolder "docker-compose.yml")
