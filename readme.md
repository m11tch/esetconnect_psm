# PowerShell module for ESET Connect

**usage:**
```powershell
Import-Module ./esetconnect.psm1 -Force
Invoke-EsetConnectAuthentication -Username "name@domain.com" -Password "passwordhere" -BaseUri "automation.eset.systems"
#Get Current Syslog Config
Get-EsetConnectSyslogConfiguration
#Set Syslog Config
Set-EsetConnectSyslogConfiguration -LogType json -MinLogLevel critical -Enabled -Format syslog -EventThreat -Hostname "syslogserver.local"

#Get all Tasks
Get-EsetConnectDeviceTasks
#Get specific Task
Get-EsetConnectDeviceTasks -TaskUuid "2b7ed474-fa17-4fdb-b34c-26b171b300f2"

#Get All groups
Get-EsetConnectDeviceGroups

#Get All Detections
Get-EsetConnectDetections
#select specific columns
Get-EsetConnectDetections | Select-Object -Property display_name, uuid
#Get Specific Detection
Get-EsetConnectDetections -DetectionUuid ec879237-d1c3-3742-ecab-05fed9ea9a58
#Get Detections for specifc device
Get-EsetConnectDetections -DeviceUuid 83c7522f-f4a7-4a80-a055-8e1329201129
```
