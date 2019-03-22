::SysCheck v1.8 By Lucas "Lucaspec72" Pecquenard
@echo off
mode con: cols=35 lines=10
setlocal enabledelayedexpansion
for /f "tokens=2 delims==" %%f in ('wmic computersystem get totalphysicalmemory /value ^| find "="') do set ram=%%f
chcp 65001 >null
del null
echo checking computersystem
echo [ZZZZZZZZZZZZZZZZZZZZZ]>SysCheck.log
echo [ZZZ]COMPUTER INFO[ZZZ]>>SysCheck.log
echo [ZZZZZZZZZZZZZZZZZZZZZ]>>SysCheck.log
wmic /APPEND:SysCheck.log computersystem get Name, domain, Manufacturer, Model, NumberofProcessors, PrimaryOwnerName, Username, Roles /format:List >hiddenlog
echo checking memorychip
echo [ZZZZZZZZZZZZZZ]>>SysCheck.log
echo [ZZZ]MEMORY[ZZZ]>>SysCheck.log
echo [ZZZZZZZZZZZZZZ]>>SysCheck.log
set "advanced=%ram%"
echo %advanced%>temp.tmp
for %%l in (temp.tmp) do set /a len=%%~zl
set /a len-=2
set "reverse="
set "char="
for /l %%i in (0,1,%len%) do (
  for /f "usebackq" %%a in (temp.tmp) do (
    set "char=%%a"
    set "reverse=!char:~%%i,1!!reverse!"
  )
)
SET Text=!reverse!
SET Return=
FOR /L %%I IN (0,3,100) DO (
    CALL SET Letter=!Text:~%%I,3!
    IF NOT "!Letter!" == "" (
        SET Return=!Return!+!Letter!
    ) ELSE (
        goto loopdone
    )
)
:loopdone
SET Return=%Return:~1,999%
set "advanced=%Return%"
echo %advanced%>temp.tmp
for %%l in (temp.tmp) do set /a len=%%~zl
set /a len-=2
set "reverse="
set "char="
for /l %%i in (0,1,%len%) do (
  for /f "usebackq" %%a in (temp.tmp) do (
    set "char=%%a"
    set "reverse=!char:~%%i,1!!reverse!"
  )
)
echo !reverse!>temp.tmp
for /f "tokens=1 delims=+" %%f in (temp.tmp) do set "myVar=%%f"
del temp.tmp
echo Amount of RAM = %myVar%Gb (%ram% Bytes)>>SysCheck.log
wmic /APPEND:SysCheck.log memorychip get BankLabel, Caption, CreationClassName, DataWidth, Description, Devicelocator, FormFactor, HotSwappable, InstallDate, InterleaveDataDepth, InterleavePosition, Manufacturer, MemoryType, Model, Name, OtherIdentifyingInfo, PartNumber, PositionInRow, PoweredOn, Removable, Replaceable, SerialNumber, SKU, Speed, Status, Tag, TotalWidth, TypeDetail, Version /format:list >hiddenlog
echo checking cpu
echo [ZZZZZZZZZZZ]>>SysCheck.log
echo [ZZZ]CPU[ZZZ]>>SysCheck.log
echo [ZZZZZZZZZZZ]>>SysCheck.log
wmic /APPEND:SysCheck.log cpu get Name, Caption, MaxClockSpeed, DeviceID, status, NumberOfCores, processorid, NumberOfLogicalProcessors /format:List >hiddenlog
echo checking bios
echo [ZZZZZZZZZZZZ]>>SysCheck.log
echo [ZZZ]BIOS[ZZZ]>>SysCheck.log
echo [ZZZZZZZZZZZZ]>>SysCheck.log
wmic /APPEND:SysCheck.log bios get name, version, serialnumber /format:List >hiddenlog
echo checking diskdrive
echo [ZZZZZZZZZZZZZZZ]>>SysCheck.log
echo [ZZZ]SDD/HDD[ZZZ]>>SysCheck.log
echo [ZZZZZZZZZZZZZZZ]>>SysCheck.log
wmic /APPEND:SysCheck.log diskdrive get Name, Manufacturer, Model, InterfaceType, MediaLoaded, MediaType >hiddenlog
echo checking idecontroller
echo [ZZZZZZZZZZZ]>>SysCheck.log
echo [ZZZ]IDE[ZZZ]>>SysCheck.log
echo [ZZZZZZZZZZZ]>>SysCheck.log
wmic /APPEND:SysCheck.log idecontroller get Name, Manufacturer, DeviceID, Status >hiddenlog
echo checking logicaldisk
echo [ZZZZZZZZZZZZZZZ]>>SysCheck.log
echo [ZZZ]STORAGE[ZZZ]>>SysCheck.log
echo [ZZZZZZZZZZZZZZZ]>>SysCheck.log
set vartest=NaN
set _result=NaN 2
(for /f "tokens=1-3" %%a in ('
  WMIC LOGICALDISK GET FreeSpace^,Name^,Size ^|FINDSTR /I /V "Name"
  ') do (
    echo wsh.echo "%%b" ^& " free=" ^& FormatNumber^(cdbl^(%%a^)/1024/1024/1024, 2^)^& " GB"^& " size=" ^& FormatNumber^(cdbl^(%%c^)/1024/1024/1024, 2^)^& " GB" > tmp.vbs
    if not "%%c"=="" (
      echo( 
      cscript //nologo tmp.vbs >>temp.tmp
      for /f "delims=" %%x in (temp.tmp) do set varnoy=%%x
      SET knowwhy=!varnoy:�=!
      echo !knowwhy!>>SysCheck.log
    )
  )
)> linefix.tmp
del linefix.tmp
del temp.tmp
echo.>>SysCheck.log
wmic /APPEND:SysCheck.log logicaldisk get Name, Compressed, Description, DriveType, FileSystem, SupportsDiskQuotas, VolumeDirty, VolumeName >hiddenlog
echo checking os
echo [ZZZZZZZZZZZZZZZZZZZZZZZZ]>>SysCheck.log
echo [ZZZ]OPERATING SYSTEM[ZZZ]>>SysCheck.log
echo [ZZZZZZZZZZZZZZZZZZZZZZZZ]>>SysCheck.log
wmic /APPEND:SysCheck.log os get Version, Caption, CountryCode, CSName, Description, InstallDate, SerialNumber, ServicePackMajorVersion, WindowsDirectory, CurrentTimeZone, FreePhysicalMemory, FreeVirtualMemory, LastBootUpTime, NumberofProcesses, NumberofUsers, Organization, RegisteredUser, Status /format:list >hiddenlog
echo checking VideoController(GPU)
echo [ZZZZZZZZZZZ]>>SysCheck.log
echo [ZZZ]GPU[ZZZ]>>SysCheck.log
echo [ZZZZZZZZZZZ]>>SysCheck.log
wmic /APPEND:SysCheck.log path win32_VideoController get Name, DeviceID, DriverVersion, Status, AdapterRAM >hiddenlog
findstr /v /r /c:"^$" /c:"^[\ \	]*$" "SysCheck.log" > "SysCheck_Log.txt"
del SysCheck.log
del hiddenlog
del tmp.vbs
echo Thank you for using SysCheck v1.8
timeout /t 1 /nobreak>null
del null
start SysCheck_Log.txt
exit