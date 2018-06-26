:: globalCompressor.bat		5/2018 ryan.jenson@bradleycorp.com
:: Created to take care of files that build up in various "archive" folders throughout the PIM Prod environment.
:: 7Zip CLI support must be installed for script to work.
:: 7zip CLI syntax:		https://sevenzip.osdn.jp/chm/cmdline/
:: Enter the absolute directory paths in the "directory[n]" array below. DO NOT END THE LINE WITH A "\"
@echo off
SETLOCAL EnableDelayedExpansion
title GLOBAL COMPRESSOR
echo Compress all 'archive' files across all import/export folders
echo This script is written to work across any filepath on the system.
echo >nul 2>nul
echo >nul 2>nul

:: A date in the ISO format of YYYYMMDD to be used as zip folder name and log timestamp (with time as -HH:mm)
SET isoDate=%date:~10,4%%date:~4,2%%date:~7,2%
SET militaryTime=%time:~0,2%:%time:~3,2%
SET logStamp=%isoDate%-%time:~0,2%:%time:~3,2%	
SET zipName=_compressed_%isoDate%
SET logFile=log_globalCompressor.txt
echo %logStamp% %~nx0 initiated on %isoDate% at %time% >>%logFile%


::::::::::::::::::::::::::::::::::::::::
:: LIST THE FULL DIRECTORIES TO COMPRESS - Put your folders to archive here:
::::::::::::::::::::::::::::::::::::::::
SET directory[0]=E:\Informatica\PIM\inbox\archive
SET directory[1]=E:\PIMServerScripts\TransferToRemoteServers\EcommerceExports\Magento\archives
SET directory[2]=E:\PIMServerScripts\TransferToRemoteServers\EcommerceExports\Epicor\archives
SET directory[3]=
SET directory[4]=
SET directory[5]=
SET directory[6]=
SET directory[7]=
SET directory[8]=
SET directory[9]=
SET directory[10]=




::::::::::::::::::
:: COUNT VARIABLES
::::::::::::::::::
:: How many variables are in the array. This allows the script to auto scale its lists via the "directoriesInArray" var.
SET "i=0"
:ArrayLength
IF DEFINED directory[%i%] (
	CALL echo %directory[%i%]%
	SET /A "i+=1"
	GOTO ArrayLength
)
SET /A directoriesInArray=%i%-1
echo %logStamp% This script has found %i% variable(s) declared for compression. >>%logFile%

:: Itemize all variables with content that will be parsed by the script
FOR /l %%h IN (0,1,%directoriesInArray%) DO ( 
	IF directory[%%h] NEQ "nul" (
		echo %logStamp% Variable directory[%%h] has content and will attempt to be compressed.  >>%logFile%
	)
)



:::::::::::
:: FAILSAFE
:::::::::::
:: Used to catch complications associated with undeclared variables
FOR /l %%k IN (0,1,%directoriesInArray%) DO ( 
	IF "!directory[%%k]!"=="" (
			echo %logStamp% Variable "Directory%%k" is undeclared. Setting value to "nul" >>%logFile%
			SET directory[%%k]=nul
	)
)

:: Don't overwrite existing file if there's a conflict. Yes, it will kill the script but it's unlikely that, the next time it runs, there will be a folder with the same ISO Date timestamp in it's name
FOR /l %%m IN (0,1,%directoriesInArray%) DO ( 
	IF EXIST !directory[%%m]!\%zipName%.zip (
			echo %logStamp% A file with the name of "%zipName%.zip" already exists in "!directory[%%m]!\". Aborting compression. >>%logFile%
			echo ******************************************************************************** >>%logFile%
			EXIT
	)
)



:::::::::::::::::::
:: CLEANUP OLD ZIPS
:::::::::::::::::::
:: Delete files over 4 years old (1460 days)
FOR /l %%p IN (0,1,%directoriesInArray%) DO ( 
	forfiles /p !directory[%%p]! /s /m _compressed_*.zip /D -1460 /C "cmd /c ECHO %logStamp% File deleted: @path" >>%logFile%
	forfiles /p !directory[%%p]! /s /m _compressed_*.zip /D -1460 /C "cmd /c DEL @path"
)



::::::::::::::::::::
:: BEGIN COMPRESSION
::::::::::::::::::::
:: Array parenthesis syntax: (# to start counting at, # to increment by, max # to count to)
:: Due to known bugs with 7zip CLI you cannot exclude compressing files by type (the -xr! command doesn't work in batch files, only when manually entered into a shell). To remedy this I copy all preexisting .zip files into an 'escrow' folder then copy them back into the target dir later. 
mkdir escrow >nul 2>nul
echo If you see a folder named "escrow" next to %~nx0, you may delete it...it's a scrap folder >>escrow\README.txt

FOR /l %%n IN (0,1,%directoriesInArray%) DO ( 
	move !directory[%%n]!\*.zip escrow
	IF directory[%%n] NEQ "nul" (
		echo %logStamp% Beginning compression of !directory[%%n]! at %time% >>%logFile%
		7z a -tzip %zipName%.zip !directory[%%n]!\* -sdel
		move /Y %~dp0\%zipName%.* !directory[%%n]!\ >nul 2>nul
	)
		IF EXIST !directory[%%n]!\%zipName%.* (
			echo %logStamp% Directory%%n compressed successfully as !directory[%%n]!\%zipName%.zip >>%logFile%
		) else echo %logStamp% Error compressing and/or moving Directory%%n to !directory[%%n]!\%zipName%. Check %~dp0%zipName%.zip for a potential location. >>%logFile%
	move escrow\*.zip !directory[%%n]!\
)



:::::::::::::::::
:: /END OF SCRIPT
:::::::::::::::::
RMDIR /S /Q escrow
DEL %~dp0\%zipName%.zip
echo %logStamp% %~nx0 completed at %time%! >>%logFile%
echo ******************************************************************************** >>%logFile%
ENDLOCAL
::pause
EXIT






:::::::::::::::::::
:: UNUSED RESOURCES
:::::::::::::::::::


:: 7zip COMMANDS:
::-sdel			Deletes all files once archived (compare this as 'move' instead of 'copy')
::-xr!*.zip		Exclude all files that end in ".zip" ...this command has a known bug per Google at time of writing/dev



:: Proof of concept:
::7z a -tzip %zipName%.zip %directory1%* -sdel
::move /Y %~dp0\%zipName%.* %directory1%\ >>%logFile%
::if exist %directory1%\%zipName%.* (
::echo %logStamp% Directory1 compressed successfully as %directory1%\%zipName% >>%logFile%
::) else echo %logStamp% Error compressing and/or moving Directory1 to %directory1%\%zipName% >>%logFile%



