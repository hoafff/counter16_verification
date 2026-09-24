@echo off
setlocal
cd /d "%~dp0\..\uvm"
if "%UVM_TESTNAME%"=="" set UVM_TESTNAME=counter_smoke_test
vsim -c -do run_questa.do
endlocal
