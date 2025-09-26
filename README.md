# AWS Logs Fetcher

This project downloads audit logs from **AWS AppFabric S3 buckets** and stores them locally. After fetching, it automatically **pushes only new logs** to this GitHub repository.

---

## 📂 Project Structure

```
C:\AppFabric-Logs
   ├── OneLogin
   │   ├── raw-logs
   │   └── ocsf-logs
   ├── ServiceNow
   │   ├── raw-logs
   │   └── ocsf-logs
   └── PingIdentity
       ├── raw-logs
       └── ocsf-logs
```

---

## ⚙️ Prerequisites

1. **Install AWS CLI** and configure with:

   ```sh
   aws configure
   ```

   (needs access keys for an IAM user/role with S3 read permissions).

2. **Install Git** and make sure you can push to GitHub (set up SSH or PAT).

3. **Install PowerShell** (already included in Windows 10/11).

---

## ▶️ How to Use

### Option 1: Clone via Git

```sh
cd C:\
git clone https://github.com/neerajtrianz/AppFabric-Logs AppFabric-Logs
```

### Option 2: Download ZIP

1. Go to this repo on GitHub.
2. Click **Code → Download ZIP**.
3. Extract it to:

   ```
   C:\AppFabric-Logs
   ```

---

## ▶️ Run Manually

1. Inside the repo, you’ll find:

   ```
   fetch_all_logs_daily.ps1
   ```
2. Double-click the desktop shortcut (or right-click → Run with PowerShell).

   * It will download logs from S3.
   * Save them under `C:\AppFabric-Logs`.
   * Push only **new logs** to GitHub.

---

## 🔄 Automating with Task Scheduler (Windows)

1. Open Task Scheduler (`Win + R → taskschd.msc`).
2. Create a new task with these settings:

   * **Program/script:**

     ```
     powershell.exe
     ```
   * **Add arguments:**

     ```
     -ExecutionPolicy RemoteSigned -File "C:\AppFabric-Logs\fetch_all_logs_verified.ps1"
     ```
   * Schedule: Daily at your chosen time.

Now the script runs automatically each day.

---

## ✅ Notes

* Only new/changed logs are committed and pushed.
* Repo keeps full history of logs in GitHub.

