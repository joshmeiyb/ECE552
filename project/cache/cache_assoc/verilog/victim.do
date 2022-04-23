onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mem_system_randbench/n_cache_hits
add wave -noupdate /mem_system_randbench/n_cache_hits_total
add wave -noupdate /mem_system_randbench/n_replies
add wave -noupdate /mem_system_randbench/n_requests
add wave -noupdate /mem_system_randbench/n_iter
add wave -noupdate /mem_system_randbench/req_cycle
add wave -noupdate /mem_system_randbench/clk
add wave -noupdate /mem_system_randbench/rst
add wave -noupdate /mem_system_randbench/Rd
add wave -noupdate /mem_system_randbench/Wr
add wave -noupdate /mem_system_randbench/Addr
add wave -noupdate /mem_system_randbench/DataIn
add wave -noupdate /mem_system_randbench/tag
add wave -noupdate /mem_system_randbench/CacheHit
add wave -noupdate /mem_system_randbench/CacheHit_ref
add wave -noupdate /mem_system_randbench/DataOut
add wave -noupdate /mem_system_randbench/DataOut_ref
add wave -noupdate /mem_system_randbench/Done
add wave -noupdate /mem_system_randbench/Done_ref
add wave -noupdate /mem_system_randbench/Stall
add wave -noupdate /mem_system_randbench/Stall_ref
add wave -noupdate /mem_system_randbench/DUT/m0/victimway_in
add wave -noupdate /mem_system_randbench/DUT/m0/victimway_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1262 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 278
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
WaveRestoreZoom {0 ns} {5899 ns}
