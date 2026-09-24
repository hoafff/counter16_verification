if {[file exists work]} {
    vdel -lib work -all
}
vlib work

if {![info exists env(UVM_HOME)]} {
    puts "ERROR: UVM_HOME is not set. Point it to the UVM directory that contains src/uvm_pkg.sv."
    quit -code 2 -f
}

# Compile the simulator-independent UVM source with DPI disabled for this
# educational regression, then compile the project in the documented order.
vlog -sv +define+UVM_NO_DPI +incdir+$env(UVM_HOME)/src $env(UVM_HOME)/src/uvm_pkg.sv
vlog -sv +define+UVM_NO_DPI +incdir+$env(UVM_HOME)/src -f filelist.f

if {![info exists env(UVM_TESTNAME)]} {
    set env(UVM_TESTNAME) counter_smoke_test
}

vsim -c work.tb_top +UVM_TESTNAME=$env(UVM_TESTNAME)
run -all
quit -f
