REM Default Printer Check LOGON
REM Version	0.9.
REM Author	Bardiel W. Thirtytwo
REM License	Creative Commons Attribution-ShareAlike 3.0 Unported License (CC-BY-SA) http://creativecommons.org/licenses/by-sa/3.0/
REM
REM This script is designed for use with Citrix XenDesktop 3.0, 4.0, 5.0 and 5.5.
REM It targets issues regarding default printers.
REM This scripts logs every printer that is mapped when the user logs on to it's virtual desktop
REM and veryfies which was the default printer and who set the default printer (user or not user (see below)).
REM This script is combined with Default Printer Check LOGON, which is very similar but it should run on logon.
REM 
REM To gather the client device name (which is required in this version) 
REM XDClientName.exe from ( http://support.citrix.com/article/CTX124963 ) MUST
REM be runned before this script.
REM
REM ATTENTION!! logoff and logon scritps are differnent. Do not mistake.
REM
REM Ussage: DefaultPrnCheck_LogOFF.cmd C:\temp\DefaultPrnCheck.log

@echo off
setlocal

REM Script requires log path as a parameter:
IF [%1]==[] GOTO SinParametro
REM Check if log file exists:
IF NOT EXIST %1 GOTO Inicio
REM Set maximum log size in Bytes:
SET MaxLogFile = 10485760
IF %~z1 GTR %MaxLogFile% GOTO END

:Inicio
REM XDClient es el hostname de la máquina cliente. Se le puede agregar también la IP.
SET XDClientName=
FOR /F "tokens=2*" %%A IN ('REG QUERY "HKCU\Environment" /v XDClientName^|FIND "REG_"') DO (
SET XDClientName=%%B 
)
IF "%XDClientName%"=="" GOTO NoXDClientName

REM Sets ClientName prefix.
REM UnREM this if you want this script to run only when client connects
REM from certain devices.
REM i.e.: you need this to run only when users connects from client devices
REM which do not autocreate printers. 

REM SET _prefix=%XDClientName:~0,2% 
REM IF %_prefix%==TH GOTO RUN
REM GOTO END

:RUN
echo %date% %time% on %computername% from %XDClientName% at LogOFF>> %1

REM Checks default printer:
FOR /F "tokens=2*" %%A IN ('REG QUERY "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows" /v Device^|FIND "REG_"') DO (
SET Device=%%B 
)

REM Checks who set the default printer:
REM 1	User selected
REM 0	System selected (means that default printer was selected by Windows whithout user intervention):
FOR /F "tokens=2*" %%A IN ('REG QUERY "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows" /v UserSelectedDefault^|FIND "REG_"') DO (
SET UserSelectedDefault=%%B
)

REM Logs every printer that is mapped during this session:
CALL REG QUERY "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Devices" | FIND "REG_" >> %1
)

echo Default Printer = %device% >> %1
echo User Selected Default = %UserSelectedDefault% >> %1

echo ---------------------------------------------------------- >> %1
echo. >> %1
GOTO END

:NoXDClientName
ECHO ERROR: %date% %time% on %computername% SIN VARIABLE DE ENTORNO at LogON>> %1
ECHO ---------------------------------------------------------- >> %1
ECHO. >> %1
GOTO END

:SinParametro
ECHO Debe especificar la ruta del log. Ej.: P:\Printers.txt
GOTO END

:END
