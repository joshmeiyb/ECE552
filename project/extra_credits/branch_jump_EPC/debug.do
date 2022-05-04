onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /proc_hier_pbench/DUT/c0/cycle_count
add wave -noupdate -radix unsigned /proc_hier_pbench/inst_count
add wave -noupdate /proc_hier_pbench/DUT/c0/clk
add wave -noupdate /proc_hier_pbench/DUT/c0/rst
add wave -noupdate -divider Instr
add wave -noupdate /proc_hier_pbench/PC
add wave -noupdate /proc_hier_pbench/Inst
add wave -noupdate /proc_hier_pbench/DUT/p0/IFID/instruction_IFID
add wave -noupdate /proc_hier_pbench/DUT/p0/IDEX/instruction_IDEX
add wave -noupdate /proc_hier_pbench/DUT/p0/EXMEM/instruction_EXMEM
add wave -noupdate /proc_hier_pbench/DUT/p0/MEMWB/instruction_MEMWB
add wave -noupdate -divider Top-Level
add wave -noupdate /proc_hier_pbench/MemAddress
add wave -noupdate /proc_hier_pbench/MemDataIn
add wave -noupdate /proc_hier_pbench/MemDataOut
add wave -noupdate /proc_hier_pbench/MemRead
add wave -noupdate /proc_hier_pbench/MemWrite
add wave -noupdate /proc_hier_pbench/RegWrite
add wave -noupdate /proc_hier_pbench/WriteData
add wave -noupdate /proc_hier_pbench/WriteRegister
add wave -noupdate /proc_hier_pbench/Halt
add wave -noupdate -divider {Instr Mem}
add wave -noupdate /proc_hier_pbench/DUT/p0/fetch/Instruction_Memory/cache_controller/curr_state
add wave -noupdate /proc_hier_pbench/DUT/p0/fetch/Instruction_Memory/Done
add wave -noupdate /proc_hier_pbench/DUT/p0/fetch/Instruction_Memory/Stall
add wave -noupdate /proc_hier_pbench/DUT/p0/fetch/Instruction_Memory/Addr
add wave -noupdate /proc_hier_pbench/DUT/p0/fetch/Instruction_Memory/DataOut
add wave -noupdate -divider {Data Mem}
add wave -noupdate /proc_hier_pbench/DUT/p0/memory/Data_Memory/cache_controller/curr_state
add wave -noupdate /proc_hier_pbench/DUT/p0/memory/Data_Memory/Done
add wave -noupdate /proc_hier_pbench/DUT/p0/memory/Data_Memory/Stall
add wave -noupdate /proc_hier_pbench/DUT/p0/memory/Data_Memory/Addr
add wave -noupdate /proc_hier_pbench/DUT/p0/memory/Data_Memory/DataIn
add wave -noupdate /proc_hier_pbench/DUT/p0/memory/Data_Memory/Rd
add wave -noupdate /proc_hier_pbench/DUT/p0/memory/Data_Memory/Wr
add wave -noupdate /proc_hier_pbench/DUT/p0/memory/Data_Memory/DataOut
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 380
configure wave -valuecolwidth 54
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
WaveRestoreZoom {0 ns} {703 ns}
