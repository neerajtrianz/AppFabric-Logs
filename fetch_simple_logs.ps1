# ============================================
# PowerShell script: download S3 logs in simplified structure
# and push to GitHub
# ============================================

# Base directory (GitHub repo root)
$BaseDir = "C:\AWS-Logs"

# AWS CLI path
$AwsCli = "C:\Program Files\Amazon\AWSCLIV2\aws.exe"

# Git executable path
$GitExe = "C:\Program Files\Git\bin\git.exe"

# =============================
# Define connectors and S3 prefixes
# =============================
$Connectors = @(
    @{ Name="ServiceNow"; Type="raw";  S3Path="s3://servicenow-s3-logs-neeraj-appfabric/raw/" },
    @{ Name="ServiceNow"; Type="ocsf"; S3Path="s3://servicenow-s3-logs-neeraj-appfabric/ocsf/" },
    @{ Name="OneLogin";   Type="raw";  S3Path="s3://onelogin-s3-logs-neeraj-appfabric/raw/" },
    @{ Name="OneLogin";   Type="ocsf"; S3Path="s3://onelogin-s3-logs-neeraj-appfabric/ocsf/" },
    @{ Name="PingIdentity"; Type="raw";  S3Path="s3://pingone-s3-logs-neeraj-appfabric/raw/" },
    @{ Name="PingIdentity"; Type="ocsf"; S3Path="s3://pingone-s3-logs-neeraj-appfabric/ocsf/" }
)

# =============================
# Loop through connectors
# =============================
foreach ($conn in $Connectors) {

    # Local folder per connector and type
    $LocalFolder = Join-Path $BaseDir $conn.Name
    $LocalFolder = Join-Path $LocalFolder ($conn.Type + "-logs")

    if (!(Test-Path $LocalFolder)) {
        New-Item -Path $LocalFolder -ItemType Directory -Force | Out-Null
    }

    Write-Output "Processing $($conn.Name) $($conn.Type) logs ..."

    # 1. List all objects in S3 prefix
    $s3List = & $AwsCli s3 ls $conn.S3Path --recursive | ForEach-Object {
        ($_ -split "\s+")[-1]  # get the key (last column)
    }

    # 2. Download each object individually and rename to <YYYYMMDD>.json
    foreach ($key in $s3List) {

        # Extract date from the S3 key (assumes YYYYMMDD appears in the path)
        if ($key -match "\d{8}") {
            $date = $Matches[0]
        } else {
            # If no date in path, use current date
            $date = Get-Date -Format "yyyyMMdd"
        }

        # Local file path
        $FileName = Join-Path $LocalFolder ($date + ".json")

        # Download the file
        & $AwsCli s3 cp ("s3://" + $conn.S3Path + $key) $FileName --region us-east-1
    }
}

Write-Output "All logs downloaded in simplified structure!"

# =============================
# Commit & push to GitHub
# =============================
cd $BaseDir

# Stage changes
& $GitExe add .

# Commit only if there are changes
$Status = & $GitExe status --porcelain
if ($Status) {
    $CommitMessage = "Daily log update: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    & $GitExe commit -m $CommitMessage
    & $GitExe push origin main
    Write-Output "Changes committed and pushed to GitHub."
} else {
    Write-Output "No changes to commit."
}
