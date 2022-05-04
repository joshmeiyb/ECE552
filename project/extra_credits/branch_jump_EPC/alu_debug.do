onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /proc_hier_pbench/DUT/c0/clk
add wave -noupdate /proc_hier_pbench/DUT/c0/cycle_count
add wave -noupdate /proc_hier_pbench/DUT/c0/err
add wave -noupdate /proc_hier_pbench/DUT/c0/rst
add wave -noupdate /proc_hier_pbench/DUT/p0/decode/alu_branch_jump/c_out
add wave -noupdate /proc_hier_pbench/DUT/p0/decode/alu_branch_jump/Cin
add wave -noupdate /proc_hier_pbench/DUT/p0/decode/alu_branch_jump/cla_16b_out
add wave -noupdate /proc_hier_pbench/DUT/p0/decode/alu_branch_jump/InA
add wave -noupdate /proc_hier_pbench/DUT/p0/decode/alu_branch_jump/InAA
add wave -noupdate /proc_hier_pbench/DUT/p0/decode/alu_branch_jump/InAA_reversed
add wave -noupdate /proc_hier_pbench/DUT/p0/decode/alu_branch_jump/InB
add wave -noupdate /proc_hier_pbench/DUT/p0/decode/alu_branch_jump/InBB
add wave -noupdate /proc_hier_pbench/DUT/p0/decode/alu_branch_jump/invA
add wave -noupdate /proc_hier_pbench/DUT/p0/decode/alu_branch_jump/invB
add wave -noupdate /proc_hier_pbench/DUT/p0/decode/alu_branch_jump/Ofl
add wave -noupdate /proc_hier_pbench/DUT/p0/decode/alu_branch_jump/Ofl_signed
add wave -noupdate /proc_hier_pbench/DUT/p0/decode/alu_branch_jump/Ofl_SLT
add wave -noupdate /proc_hier_pbench/DUT/p0/decode/alu_branch_jump/Ofl_unsigned
add wave -noupdate /proc_hier_pbench/DUT/p0/decode/alu_branch_jump/Oper
add wave -noupdate /proc_hier_pbench/DUT/p0/decode/alu_branch_jump/Out
add wave -noupdate /proc_hier_pbench/DUT/p0/decode/alu_branch_jump/SCO
add wave -noupdate /proc_hier_pbench/DUT/p0/decode/alu_branch_jump/SEQ
add wave -noupdate /proc_hier_pbench/DUT/p0/decode/alu_branch_jump/shifter_out
add wave -noupdate /proc_hier_pbench/DUT/p0/decode/alu_branch_jump/sign
add wave -noupdate /proc_hier_pbench/DUT/p0/decode/alu_branch_jump/SLE
add wave -noupdate /proc_hier_pbench/DUT/p0/decode/alu_branch_jump/SLT
add wave -noupdate /proc_hier_pbench/DUT/p0/decode/alu_branch_jump/Zero
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1312 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 329
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {4100 ns}
