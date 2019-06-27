REM Chocolatey installed on base image

REM vcredist packages
choco install -y vcredist2010
if %errorlevel% neq 0 exit /b %errorlevel%
choco install -y vcredist2008
if %errorlevel% neq 0 exit /b %errorlevel%

REM nginx proxy as a service
choco install -y nginx-service --version 1.16.0
if %errorlevel% neq 0 exit /b %errorlevel%

REM Firefox browser
choco install -y firefox --version 67.0.3
if %errorlevel% neq 0 exit /b %errorlevel%

REM 7Zip archive util
choco install -y 7zip.install --version 19.0
if %errorlevel% neq 0 exit /b %errorlevel%