:: criticalSystemFileBackup.bat		6/2018 ryan.jenson@bradleycorp.com
:: Created to automatically copy PIM's critical files to another location for backup purposes.
:: 7Zip CLI support must be installed for script to work.
:: 7zip CLI syntax:		https://sevenzip.osdn.jp/chm/cmdline/
@echo off
SETLOCAL EnableDelayedExpansion
TITLE Backup System Critical Files
echo Backup all of PIM's critical system files
echo >nul 2>nul
echo >nul 2>nul


:: A date in the ISO format of YYYYMMDD to be used as zip folder name and log timestamp (with time as -HH:mm)
SET isoDate=%date:~10,4%%date:~4,2%%date:~7,2%
SET militaryTime=%time:~0,2%%time:~3,2%
SET logStamp=%isoDate%-%time:~0,2%:%time:~3,2%	
SET logFile=%~n0.log
SET storageDir=\\p1-pimtest.bradleycorp.local\E$\RepoBackups
echo %logStamp% %~nx0 initiated from %COMPUTERNAME% on %isoDate% at %time% >>%logFile%





SET zipName=_%COMPUTERNAME%_%~n0_%isoDate%-%militaryTime%
:: Don't overwrite existing file if there's a conflict. Yes, it will kill the script but it's unlikely that, the next time it runs, there will be a folder with the same ISO Date timestand in it's name
IF EXIST %storageDir%\%zipName%.zip (
	echo %logStamp% A file with the name of "%zipName%.zip" already exists. Exiting Program. >>%logFile%
	EXIT
)  




:::::::::::::::
:: BEGIN BACKUP
:::::::::::::::
:: This process is written to tenderly copy the files to a safe location before introducing compression and scrap file deletion
ECHO %logStamp% Beginning copy of ..\server at %time% >>%logFile%
xcopy /I /E /C /Y /X /H E:\Informatica\PIM\server %~dp0%zipName%\server>nul 2>nul
ECHO %logStamp% Beginning copy of ..\MessageQueue\activemq at %time% >>%logFile%
xcopy /I /E /C /Y /X /H E:\Informatica\PIM\MessageQueue\activemq %~dp0%zipName%\activemq>nul 2>nul
ECHO %logStamp% Beginning copy of ..\clusterix\configuration at %time% >>%logFile%
xcopy /I /E /C /Y /X /H E:\Informatica\PIM\clusterix\configuration %~dp0%zipName%\clusterix\configuration>nul 2>nul

::::::::::::::::::::::::::::::::::::
:: CHECK PRESCENSE OF CRITICAL FILES
::::::::::::::::::::::::::::::::::::
IF EXIST %~dp0%zipName%\server\configuration\HPM\Repository.repository (
	ECHO %logStamp% The "Repository.repository" file was successfully backed up. >>%logFile%
) ELSE ECHO ERROR "Repository.repository" file WAS NOT successfully backed up! >>%logFile%

IF EXIST %~dp0%zipName%\server\configuration\HPM\Repository_en.properties (
	ECHO %logStamp% The "Repository_en.properties" file was successfully backed up. >>%logFile%
) ELSE ECHO ERROR "Repository_en.properties" file WAS NOT successfully backed up! >>%logFile%

IF EXIST %~dp0%zipName%\server\configuration\HPM\webdefinitions (
	ECHO %logStamp% The "webdefinitions" file was successfully backed up. >>%logFile%
) ELSE ECHO ERROR "webdefinitions" folder WAS NOT successfully backed up! >>%logFile%



echo %logStamp% Beginning compression of files at %TIME% >>%logFile% 
7z a -tzip %zipName%.zip %zipName% -sdel
echo %logStamp% Files have been has been copied to %zipName%.zip as of %TIME% >>%logFile% 




::::::::::::::::::::::::::::::::::::
:: MOVE BACKUP TO PIMTEST ALT SERVER
::::::::::::::::::::::::::::::::::::

echo %logStamp% Moving %zipName%.zip off site to %storageDir% at %TIME% >>%logFile% 
MOVE %zipName%.zip %storageDir%

IF EXIST %storageDir%\%zipName%.zip (
	ECHO %logStamp% The backups were successfully transferred offsite. >>%logFile%
) ELSE ECHO ERROR %zipName%.zip folder WAS NOT successfully backed up! >>%logFile%




:::::::::::::::::
:: /END OF SCRIPT
:::::::::::::::::
echo %logStamp% %~nx0 completed at %TIME%! >>%logFile%
echo ******************************************************************************** >>%logFile% 
ENDLOCAL
::PAUSE
EXIT










:::::::::::::::::::
:: UNUSED RESOURCES
:::::::::::::::::::




:: Find out what server we're on so that the backup is named properly
::IF "%COMPUTERNAME%"=="P1-PIMPROD" (
::	SET zipName=_PROD_%~n0_%isoDate%
::	echo %logStamp% %~nx0 has dectected that this is the PRODUCTION server. Backup to be named _PROD_criticalSystemFileBackup_%isoDate% >>%logFile%
::	) ELSE IF "%COMPUTERNAME%"=="P1-PIM" (
::		SET zipName=_DEV_%~n0_%isoDate%
::		echo %logStamp% %~nx0 has dectected that this is the DEV/TEST server. Backup to be named _DEV_criticalSystemFileBackup_%isoDate% >>%logFile%
::	) 

