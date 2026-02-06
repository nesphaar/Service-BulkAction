# **Service-BulkAction**

🛠️ **Bulk Service Manager (PowerShell)**

Interactive PowerShell script to manage Windows services in bulk by searching text in the service **Name** or **DisplayName**.

Designed for Windows 10 / Windows Server 2016+.

---

## **✨ Features**

- Interactive numeric menu
- Bulk **START / STOP / STATUS**
- Bulk service configuration:
  - **ENABLE (Automatic)**
  - **ENABLE (Delayed Start)**
  - **MANUAL**
  - **DISABLE**
- Case-insensitive substring search
- Preview of changes: **Current StartType → New StartType**
- Confirmation before executing actions
- Extra confirmation before **DISABLE**
- Clean handling of *Access Denied* / protected services
- Automatic error logging to file

---

## **🚀 Usage**

Run the script:

```powershell
.\Service-BulkAction.ps1
```

If blocked:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope Process
```
⚠️ Run PowerShell as Administrator for full functionality.

---

## **🔎 How Search Works**

The script matches services where Name or DisplayName contains the provided text:
```powershell
-like "*SearchText*"
```

---

## **⚠️ Warning**
This script can modify multiple services at once.
Avoid generic keywords such as:

Microsoft
Update
SQL
Service

Always review the preview list before confirming any action.

---

## **🧑‍💻 Requirements**

Windows 10 / Windows Server 2016+
PowerShell 5.1 or PowerShell 7+
Administrator privileges recommended
