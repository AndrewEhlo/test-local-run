param (
    [string]$targetFolder = "VirtoLocal",
    [string]$postgresVersion = "16.9",
    [string]$elasticsearchVersion = "8.18.0"
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

function New-RandomPassword {
    param([int]$Length = 12)
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
    $password = ""
    for ($i = 0; $i -lt $Length; $i++) {
        $password += $chars[(Get-Random -Maximum $chars.Length)]
    }
    return $password
}

# create target folder
New-Folder $targetFolder

# create .env file
Write-Host "Creating .env file..." -ForegroundColor Yellow
$envFile = Join-Path $targetFolder ".env"

$envFileContent = @"
PGSQL_VERSION=$postgresVersion
STACK_VERSION=$elasticsearchVersion
PLATFORM_PORT=8090
ES_PORT=9200
KIBANA_PORT=5601
DB_PASSWORD=$(New-RandomPassword)
REDIS_PASSWORD=$(New-RandomPassword)
ELASTIC_PASSWORD=$(New-RandomPassword)
KIBANA_PASSWORD=$(New-RandomPassword)
PGSQL_PORT=5432
REDIS_PORT=6379
FRONTEND_PORT=80
"@
Set-Content -Path $envFile -Value $envFileContent
Write-Host "✓ .env file created" -ForegroundColor Green

# download management scripts
Write-Host "Downloading management scripts..." -ForegroundColor Yellow
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AndrewEhlo/test-local-run/refs/heads/main/build-VC-solution.ps1" -OutFile (Join-Path $targetFolder "build-VC-solution.ps1")
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AndrewEhlo/test-local-run/refs/heads/main/start-VC-solution.ps1" -OutFile (Join-Path $targetFolder "start-VC-solution.ps1")
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AndrewEhlo/test-local-run/refs/heads/main/stop-VC-solution.ps1" -OutFile (Join-Path $targetFolder "stop-VC-solution.ps1")
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AndrewEhlo/test-local-run/refs/heads/main/remove-VC-solution.ps1" -OutFile (Join-Path $targetFolder "remove-VC-solution.ps1")
Write-Host "✓ Management scripts downloaded" -ForegroundColor Green

# donwload scripts-helpers
Write-Host "Downloading scripts-helpers..." -ForegroundColor Yellow
$scriptsDir = Join-Path $targetFolder "scripts"
$backendDir = Join-Path $targetFolder "backend"
$frontendDir = Join-Path $targetFolder "frontend"
New-Folder $scriptsDir
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AndrewEhlo/test-local-run/refs/heads/main/scripts/check-installed-modules.ps1" -OutFile (Join-Path $scriptsDir "check-installed-modules.ps1")
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AndrewEhlo/test-local-run/refs/heads/main/scripts/setup-sampledata.ps1" -OutFile (Join-Path $scriptsDir "setup-sampledata.ps1")
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AndrewEhlo/test-local-run/refs/heads/main/scripts/watch-url-up.ps1" -OutFile (Join-Path $scriptsDir "watch-url-up.ps1")
Write-Host "✓ Scripts-helpers downloaded" -ForegroundColor Green

# download config files for the backend
Write-Host "Downloading config files for the backend..." -ForegroundColor Yellow
New-Folder $backendDir
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AndrewEhlo/test-local-run/refs/heads/main/backend/Dockerfile" -OutFile (Join-Path $backendDir "Dockerfile")
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AndrewEhlo/test-local-run/refs/heads/main/scripts/wait-for-it.sh" -OutFile (Join-Path $backendDir "wait-for-it.sh")
Write-Host "✓ Config files for the backend downloaded" -ForegroundColor Green

#download config files for the frontend
Write-Host "Downloading config files for the frontend..." -ForegroundColor Yellow
New-Folder $frontendDir
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AndrewEhlo/test-local-run/refs/heads/main/frontend/Dockerfile" -OutFile (Join-Path $frontendDir "Dockerfile")
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AndrewEhlo/test-local-run/refs/heads/main/frontend/nginx.conf" -OutFile (Join-Path $frontendDir "nginx.conf")
Write-Host "✓ Config files for the frontend downloaded" -ForegroundColor Green

# download docker-compose file
Write-Host "Downloading docker-compose file..." -ForegroundColor Yellow
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AndrewEhlo/test-local-run/refs/heads/main/docker-compose.yml" -OutFile (Join-Path $targetFolder "docker-compose.yml")
Write-Host "✓ docker-compose file downloaded" -ForegroundColor Green

Write-Host "Done" -ForegroundColor Green
