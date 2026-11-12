# ModelSim/Questa (Intel FPGA edition, altera_mf precompiled). Run from sim/: do cpu_tb.do
onbreak {resume}

if {[file exists work]} { vdel -lib work -all }
vlib work

vcom -2008 -quiet \
    ../rtl/cpu_pkg.vhd \
    ../rtl/reg16.vhd \
    ../rtl/mux2x1.vhd \
    ../rtl/mux4x1.vhd \
    ../rtl/sign_extend.vhd \
    ../rtl/alu.vhd \
    ../rtl/register_file.vhd \
    ../rtl/control_unit.vhd \
    ../rtl/datapath.vhd \
    ../rtl/cpu.vhd \
    ../rtl/memory.vhd \
    alu_tb.vhd \
    register_file_tb.vhd \
    cpu_tb.vhd

foreach tb {alu_tb register_file_tb} {
    vsim -quiet work.$tb
    run -all
    quit -sim
}

foreach t {0 1 2 3 4 5 6} {
    vsim -quiet -L altera_mf -gTEST=$t work.cpu_tb
    run -all
    quit -sim
}

