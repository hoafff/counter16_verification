@echo off
setlocal
cd /d "%~dp0\..\uvm"
set UVM_TESTNAME=counter_wrap_test
vsim -c -do run_questa.do
endlocal
