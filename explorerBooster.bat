@echo off


:: Remove shortcuts that no one uses...
del "C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\SendTo\Mail Recipient.MAPIMail"
del "C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\SendTo\Fax Recipient.lnk"
del "C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Libraries"

:: Accidentally pressing F1 will no longer bring up the useless microsoft "help" box
:: You might have to visit the file and *Right Click > Properties > Security* and add user rights to delete/edit
del /F C:\Windows\HelpPane.exe


::pause
exit
