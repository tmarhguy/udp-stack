@echo off
call C:\Tools\oss-cad-suite\environment.bat 2>nul
cd /d "%~dp0"
python run_tests.py %*
