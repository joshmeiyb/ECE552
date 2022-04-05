# ECE552

## First Step - Verilog Simulation

After completing the Verilog files, use Modelsim to verify them, the Command-Line Modelsim is recommended.

`wsrun.pl <name of your testbench module> <testbench file name> <list of verilog files>`

## Second Step - Verilog Rule Checking

1. Copy two class files `Vcheck.class` and `VerFile.class` into the directory folder

2. Run `vcheck-all.sh` command in the directory

## Third Step - Pack/Unpack files using tar command

* untar using tar -xvzf command

`tar -xvf filename.tgz`

* compress using tar -cvzf command

`tar -cvzf filename.tgz filename/`

## Fourth Step - Handin Verification

1. Script Checker

`/u/s/i/sinclair/public/html/courses/cs552/spring2022/handouts/scripts/project/phase1/verify_submission_format.sh filename.tgz`

2. Python Checker

`python3 /u/s/i/sinclair/public/html/courses/cs552/spring2022/handouts/scripts/hw1/verify_submission_format.py filename.tgz`


## Acknowledgement

Professor Matt Sinclair @ UW-Madison, Instrutor of ECE/CS 552 - Spring 2022
