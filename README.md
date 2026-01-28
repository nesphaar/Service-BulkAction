# Service-BulkAction
**🛠️ Bulk Service Manager (PowerShell)**

A lightweight interactive PowerShell tool to start or stop Windows services in bulk by searching for text inside the service Name or DisplayName.

Designed for Windows 10 and newer.

**✨ Features**

Interactive menu (numeric selection)

Bulk START or STOP services

Search by substring (contains match)

Case-insensitive matching

Confirmation prompt before executing

Works with both:

Service Name

Display Name

**📦 Script**

File: Service-BulkAction.ps1

**🚀 Usage**
1️⃣ Run the script
.\Service-BulkAction.ps1


If script execution is blocked:

Set-ExecutionPolicy RemoteSigned -Scope Process

2️⃣ Select action
1) START services
2) STOP services

3️⃣ Enter search text

Example:

Veeam

This will match services like:

Veeam Backup Service
AWS Veeam Service
BVeeamS

4️⃣ Confirm execution
Confirm action STOP? (y/n)

🧠 How It Works

The script uses a wildcard contains search:

-like "*SearchText*"

This matches any service whose Name or DisplayName contains the text.

**⚠️ WARNING (Important)**

This script can stop multiple critical services if used incorrectly.
**
⚠️ Avoid generic keywords like:**

SQL
Agent
Service
Update
Microsoft

Always review the list before confirming.

**🧑‍💻 Requirements**

Windows 10 / Windows Server 2016+

PowerShell 5.1 or PowerShell 7+

Administrator privileges recommended
