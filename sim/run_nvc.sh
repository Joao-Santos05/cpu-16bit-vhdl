#!/usr/bin/env bash
# Compiles with nvc using sim/memory_sim.vhd instead of the altsyncram wrapper and runs every testbench.
set -euo pipefail
cd "$(dirname "$0")"

NVC="nvc --std=2008 --work=work:build/work --ieee-warnings=off-at-0"
mkdir -p build

RTL=(
    ../rtl/cpu_pkg.vhd
    ../rtl/reg16.vhd
    ../rtl/mux2x1.vhd
    ../rtl/mux4x1.vhd
    ../rtl/sign_extend.vhd
    ../rtl/alu.vhd
    ../rtl/register_file.vhd
    ../rtl/control_unit.vhd
    ../rtl/datapath.vhd
    ../rtl/cpu.vhd
    ../rtl/debouncer.vhd
    ../rtl/hex_display.vhd
)

$NVC -a "${RTL[@]}" memory_sim.vhd alu_tb.vhd register_file_tb.vhd cpu_tb.vhd

$NVC -e alu_tb -r
$NVC -e register_file_tb -r
for t in 0 1 2 3 4 5 6; do
    $NVC -e -gTEST=$t cpu_tb -r
done
