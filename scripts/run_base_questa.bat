@echo off
setlocal
cd /d "%~dp0\..\base_sv"
set TEST_PLUSARGS=
vsim -c -do run_questa.do
endlocal
