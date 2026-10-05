@echo off
setlocal
cd /d "%~dp0\..\gpio_demo"

set UVM_TESTNAME=gpio_counter_smoke_test
if not "%~1"=="" set UVM_TESTNAME=%~1

echo Running GPIO UVC demo test: %UVM_TESTNAME%
vsim -c -do run_questa.do

endlocal
