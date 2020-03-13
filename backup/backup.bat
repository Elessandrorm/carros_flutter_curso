set year=%date:~-4,4%
set month=%date:~-10,2%
set day=%date:~-7,2%
set hour=%time:~-11,2%
set hour=%hour: =0%
set min=%time:~-8,2%

set zipfilename=Backup.%year%.%month%.%day%.%hour%%min%.z7

"c:\Program Files\7-Zip\7z.exe" a -t7z %zipfilename% @backupFileList.txt