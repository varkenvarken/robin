# robin
SoC design targeted at the iCEbreaker board

![Python files](https://github.com/varkenvarken/robin/workflows/Python%20files/badge.svg) ![Simulations](https://github.com/varkenvarken/robin/workflows/Simulations/badge.svg) ![Libraries](https://github.com/varkenvarken/robin/workflows/Libraries/badge.svg) ![Verilog testbenches](https://github.com/varkenvarken/robin/workflows/Verilog%20testbenches/badge.svg)

## Components

The Robin SoC consists of several components, each documented on their own wiki page.

* The SoC/CPU itself ([Hardware definition files](https://github.com/varkenvarken/robin/tree/master/SoC) in Verilog)
* A [monitor program](https://github.com/varkenvarken/robin/wiki/Monitor), to interact with the hardware
* An [assembler](https://github.com/varkenvarken/robin/wiki/Assembler), to compile assembly to binary files
* A [compiler](https://github.com/varkenvarken/robin/wiki/Compiler), to convert a C-like language to assembly
* A [simulator](https://github.com/varkenvarken/robin/wiki/Simulator), to simulate running binary programs

Additionally, the CPU design is being documented on [a separate website](https://varkenvarken.github.io/robin/index.html) and progess is reported on a [blog](https://fpga.michelanders.nl/)

## About test results

The badges indicate whether the main python files pass pep8, all instructions can be simulated correctly in the simulator, libc examples can be compiled, assembled and simulated with correct results and lastly whether the verilog testbenches work. Nothing of this does imply that de hardware works, there are separate testcases for that but I cannot run them on GitHub.

## Dependencies

* python3
* yosys
* nextpnr-ice40
* icestorm

## Installation

    git clone https://github.com/varkenvarken/robin.git
    cd robin
    git submodule update --init
    cd SoC
    make

You can then flash the iCEbreaker (if connected to a USB port) with

    make flash

It might be a good thing to run the hardware test at that point

    cd Test
    make
    make testhard

