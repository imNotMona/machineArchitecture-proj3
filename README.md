3rd project of machine architecure course
Python is used in the grading system for the written code
my written code is in the following files:
bits.s
input.txt

can be ran through the terminal after compiling with the make file
info for make is within file, but pasted here for convenience
->make                          # build all programs'
->make all                      # makes bitwise
->make test                     # makes test-bitwise test-puzzlebin // runs written code & compares to answers
->make bitwise                  # compiles my written assembly
->make bitwise test             # compare written codes result to answer, outputs differences
->make puzzlebin                # compiles the binary file for the input test
->make puzzlebin test           # input.txt ran by puzzle binary executable to see if it passes

The major part of puzzlebin is learning to use GDB to debug code on the assembly level. The puzzle binary 
file is ran using GDB to find the correct hashesto put in input.txt

bits.s has a list of TODO items. Each item is a simple operation to be written in assembly

REQUIRES to be ran on linux, or a linux container
