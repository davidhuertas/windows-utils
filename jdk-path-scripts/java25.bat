@echo off
set JAVA_HOME=C:\Program Files\Java\jdk-25.0.3
setx JAVA_HOME "%JAVA_HOME%" /M
set Path=%JAVA_HOME%\bin;%Path%
echo Java 25 activated as system-wide default
ping localhost -n 3 >nul