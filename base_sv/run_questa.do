if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vlog -sv -f filelist.f

set plusargs ""
if {[info exists env(TEST_PLUSARGS)]} {
    set plusargs $env(TEST_PLUSARGS)
}

vsim -c work.tb_top $plusargs
run -all
quit -f
