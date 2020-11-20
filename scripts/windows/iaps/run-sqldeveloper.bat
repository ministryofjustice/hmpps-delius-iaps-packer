# SQLDeveloper connections stored in 
# C:\Users\Administrator\AppData\Roaming\SQL Developer\system4.1.3.20.78\o.jdeveloper.db.connection.12.2.1.0.42.151001.541\connections.xml

set sourcefile='C:\Setup\connections.xml'
set targetfile='C:\Users\Administrator\AppData\Roaming\SQL Developer\system4.1.3.20.78\o.jdeveloper.db.connection.12.2.1.0.42.151001.541\connections.xml'

Copy-Item $sourcefile $targetfile

if exist %targetfile% (
    echo 'File exists, skipping copy..'
) else (
    echo 'File does not exist, copying..'
    copy %sourcefile% %targetfile%
)
