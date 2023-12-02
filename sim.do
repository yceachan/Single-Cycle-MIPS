quit -sim
.main   clear
vlib    ./sim
vlib    ./sim/work
vmap    work    ./sim/work
vlog    -work   work    ./rtl/*.v
vlog    -work   work    ./tb/*.v
vsim    -novopt     work.mips_tb
