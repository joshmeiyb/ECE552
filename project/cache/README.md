# Cache Testing


To begin testing you will use address traces that you will create to target the different possible aspects of cache behavior. Once you have that fully working you can use a fully random test set.

## Perfbench
The perfbench testbench uses address trace files that describe a sequence of reads and writes. You will need to write several (at least 5) address traces to test your cache and the various behavior cases that might occur. You should try to make it so that your traces highlight the various use cases that your cache might experience to be sure that they are working. For simplicity, the verification script assumes these tests are named mem1.addr, mem2.addr, mem3.addr, mem4.addr, and mem5.addr

An example address trace file (mem.addr) is provided. The format of the file is the following:

Each line represents a new request
Each line has 4 numbers separated by a space
The numbers are: Wr Rd Addr Value
Once you have created your address traces this testbench can be run using:

`wsrun.pl -addr mem.addr mem_system_perfbench *.v`

If it correctly runs you will get output that looks like the following:

`# Using trace file   mem.addr`
`# LOG: ReQNum    1 Cycle       12 ReqCycle        3 Wr Addr 0x015c Value 0x0018 ValueRef 0x0018 HIT 0`
`#`
`# LOG: ReqNum    2 Cycle       14 ReqCycle       12 Rd Addr 0x015c Value 0x0018 ValueRef 0x0018 HIT 1`
`#`
`# LOG: Done all Requests:          2 Replies:          2 Cycles:         14 Hits:          1`
`# Test status: SUCCESS`
`# Break at mem_system_perfbench.v line 200`
`# Stopped at mem_system_perfbench.v line 200`

WARNING: just because a SUCCESS message prints, it does not guarantee your cache is working correctly. It merely states that your design ran to completion successfully (i.e., it says nothing about if you got the right number of hits or misses). You should use the cache simulator to verify the correct behavior is happening. The cache simulator can be run as follows:

`cachesim <associativity> <size_bytes> <block_size_bytes> <trace_file>`
        
So for this problem you would use:

`cachesim 1 2048 8 mem.addr`
        
This will generate output like the following:

`Store Miss for Address 348`
`Load Hit for Address 348`
        
You should then compare this to the perfbench output to make sure they both exhibit the same behavior.

The address traces you created should be put in the 'cache_direct/verification' directory and have the '.addr' extention.

## Randbench
Once you are confident that your design is working you should test it using the random testbench. The random bench does the following:

full random: 1000 memory requests completely random
small random: 1000 memory requests restricted to addresses 0 to 2046
sequential addresss: 1000 memory requests restricted to address 0x08, 0x10, 0x18, 0x20, 0x28, 0x30, 0x38, 0x40
two sets address: 5000 memory requests to test a two-way set associative cache. You should get predominantly hits to to the cache.
At the end of each section you will see a message showing the performance like the following:

`LOG: Done two_sets_addr Requests: 4001, Cycles: 79688 Hits: 562`
        
You can run the random testbench like this:

`wsrun.pl mem_system_randbench *.v`
        
This will ultimately print a message saying either:

`# Test status: SUCCESS`
        
or

`# Test status: FAIL`
        
Keep in mind that it's considered a success if the correct data is returned every time but that doesn't mean your cache is necessarily working. If you have no hits or a very small number of them something is still wrong. If you are seeing failures try to isolate the case that is causing the issues and create a trace that generates the same behavior to make debugging easier.


## Additional information for 2 way assoc cache TESTING
Your testing for the set-associative cache should be done in much the same way. You can either create more address traces or update your previous ones to reflect the differences in behavior the new design would have. Remember to get your perfbench tests working before attempting to debug the randbench.

The cache simulator would now be run with slightly different arguments to reflect your changes:

`cachesim 2 4096 8 mem.addr pseudoRandom`
        
If you do not specify the pseudoRandom argument it will use an LRU replacement policy instead of the pseudo-random policy you have implemented.

The address traces you used should be put in the 'cache_assoc/verification' directory and have the '.addr' extention. For simplicity, the verification script assumes these files are called mem1-tw.addr, mem2-tw.addr, mem3-tw.addr, mem4-tw.addr, and mem5-tw.addr.