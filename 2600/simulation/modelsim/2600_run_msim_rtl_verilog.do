transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+/home/mags/uiuc/ECE385/2600 {/home/mags/uiuc/ECE385/2600/a2600.sv}

