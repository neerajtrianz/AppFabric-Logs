# Root folder to store logs locally
$localRoot = "C:\AWS-Logs"

# Define S3 paths for each connector and log type
$connectors = @(
    @{
        Name = "OneLogin"
        Raw = "s3://onelogin-s3-logs-neeraj-appfabric/raw/AWSAppFabric/AuditLog/RAW/JSON/ONELOGIN/"
        OCSF = "s3://onelogin-s3-logs-neeraj-appfabric/ocsf/AWSAppFabric/AuditLog/OCSF/JSON/ONELOGIN/"
    },
    @{
        Name = "ServiceNow"
        Raw = "s3://servicenow-s3-logs-neeraj-appfabric/raw/AWSAppFabric/AuditLog/RAW/JSON/SERVICENOW/"
        OCSF = "s3://servicenow-s3-logs-neeraj-appfabric/ocsf/AWSAppFabric/AuditLog/OCSF/JSON/SERVICENOW/"
    },
    @{
        Name = "PingIdentity"
        Raw = "s3://pingone-s3-logs-neeraj-appfabric/raw/AWSAppFabric/AuditLog/RAW/JSON/PINGIDENTITY/"
        OCSF = "s3://pingone-s3-logs-neeraj-appfabric/ocsf/AWSAppFabric/AuditLog/OCSF/JSON/PINGIDENTITY/"
    }
)

# Function to sync S3 folder to local
function Sync-S3Folder {
    param(
        [string]$s3Path,
        [string]$localPath,
        [string]$logType
    )

    Write-Output "Processing $($logType) logs for $($localPath.Split('\')[-2]) ..."

    try {
        # Ensure local directory exists
        if (!(Test-Path $localPath)) {
            New-Item -Path $localPath -ItemType Directory -Force | Out-Null
        }

        # Sync S3 to local folder
        aws s3 sync $s3Path $localPath --region us-east-1
        Write-Output "$($logType) logs downloaded successfully to $localPath"
    }
    catch {
        Write-Warning "Could not list or download S3 objects from $s3Path"
    }
}

# Loop through connectors and sync raw + ocsf
foreach ($conn in $connectors) {
    $name = $conn.Name

    # Raw logs
    $rawLocal = Join-Path -Path $localRoot -ChildPath "$name\raw-logs"
    Sync-S3Folder -s3Path $conn.Raw -localPath $rawLocal -logType "raw"

    # OCSF logs
    $ocsfLocal = Join-Path -Path $localRoot -ChildPath "$name\ocsf-logs"
    Sync-S3Folder -s3Path $conn.OCSF -localPath $ocsfLocal -logType "ocsf"
}

Write-Output "All logs processing completed."

# -----------------------------
# Push to GitHub
# -----------------------------
try {
    cd $localRoot
    git add .
    git commit -m "Updated logs on $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    git push origin main
    Write-Output "Logs pushed to GitHub successfully."
}
catch {
    Write-Warning "Failed to push logs to GitHub. Check Git configuration and remote URL."
}
