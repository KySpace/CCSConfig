# CCS Configure Scripts
This project contains script that helps set up a Code Composer Studio (CCS) project with only source code. This works for CCS before version v20 (the last version is v12), where the configuration changes a lot.
## Prerequisites
- Microsoft PowerShell (not Windows PowerShell). Should be able to be installed on Windows and Linux. https://github.com/PowerShell/PowerShell. May need admin access, but acquiring from windows store or `winget install Microsoft.PowerShell --scope user` can bypass that.
- Library in the right place, e.g. `TivaWare_C_Series-2.2.0.295`.
- CCS variables pointing to the library directory. In CCS Studio, open "Windows" menu, "Preferences" (notice that this shouldn't be the "File" menu "Properties", which is the project properties). At the bottom of the window "Show advanced settings". Find them at: 
    - C/C++: `C/C++ >> Build >> Build Variables` 
      set `TIVAWARE_DIR` to the library path.
    - Link: `General >> Workspace >> Linked Resources >> Variables` 
    set `TIVAWARE_DIR` to the library path.
required variables of each type are listed in [supported device](#supported-devices).
## Before Running
1. Clone the repository from remote.
2. In CCS, create new CCS project. 
    - Enter the project name and set the location to the repo directory. 
    - Target: Select target that matches the repo's device. (See [supported device](#supported-devices)). 
    - Connection: Select **Stellaris In-Circuit Debug Interface**.
    - Version: Use latest TI compiler (e.g. `TI v20.2.5.LTS`).
    - Template: Use **Empty Project**.
## Run
To configure the project files, invoke in PowerShell by 
```powershell
.\config_mcu.ps1 <project directory>
```
To clean up the project files, invoke in PowerShell by 
```powershell
.\clearproj.ps1 <project directory>
```
This restores the project to source-code-only with `git`. Do this when CCS is not running or the project is removed from the CCS.

Currently, the `<project directory>` has to be an absolute path.

If your PC prohibits running scripts, overcome this by running
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```
At least we can change the execution policy for the current user.
## Supported Devices
Currently we only support one device.
<table>
  <tr>
    <th>Nick Name</th>
    <th>Device</th>
    <th>Script</th>
    <th>Required Variables</th>
  </tr>
  <tr>
    <td>MCU</td>
    <td><code>TM4C123GH6PM</code></td>
    <td><code>config_mcu.ps1</code></td>
    <td>C/C++ <code>${TIVAWARE_DIR}</code></td>
  </tr>
</table>

## Why PowerShell?
Oh because it handles XML like a charm!

