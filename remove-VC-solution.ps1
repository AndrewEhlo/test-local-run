param (
    [string]$solutionFolder = "VirtoLocal"
)

$dockerComposePath = "$solutionFolder/docker-compose.yml"
if (-not (Test-Path -Path $dockerComposePath)) {
    Write-Host "Error: Docker compose file not found: $dockerComposePath" -ForegroundColor Red
    exit 1
}

docker-compose -f $dockerComposePath down -v
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to remove VC solution" -ForegroundColor Red
    Write-Host "docker-compose command failed with exit code: $LASTEXITCODE" -ForegroundColor Red
    exit 1
}
docker rmi vc-platform:local-latest
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to remove backend Docker image" -ForegroundColor Red
    Write-Host "docker rmi command failed with exit code: $LASTEXITCODE" -ForegroundColor Red
    exit 1
}
docker rmi vc-frontend:local-latest
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to remove frontend Docker image" -ForegroundColor Red
    Write-Host "docker rmi command failed with exit code: $LASTEXITCODE" -ForegroundColor Red
    exit 1
}