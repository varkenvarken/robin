# robin
SoC design targeted at the iCEbreaker board

![Python files](https://github.com/varkenvarken/robin/workflows/Python%20files/badge.svg) ![Simulations](https://github.com/varkenvarken/robin/workflows/Simulations/badge.svg) ![Libraries](https://github.com/varkenvarken/robin/workflows/Libraries/badge.svg)

## Components

The Robin SoC consists of several components, each documented on their own wiki page.

* The SoC/CPU itself ([Hardware definition files](https://github.com/varkenvarken/robin/tree/master/SoC) in Verilog)
* A [monitor program](https://github.com/varkenvarken/robin/wiki/Monitor), to interact with the hardware
* An [assembler](https://github.com/varkenvarken/robin/wiki/Assembler), to compile assembly to binary files
* A [compiler](https://github.com/varkenvarken/robin/wiki/Compiler), to convert a C-like language to assembly
* A [simulator](https://github.com/varkenvarken/robin/wiki/Simulator), to simulate running binary programs

Additionallt, the CPU design is being documented on [a separate website](https://varkenvarken.github.io/robin/index.html)

## About test results

The badges indicate if main python files pass pep8, all instructions can be simulated correctly in the simulator and libc examples can be compiled, assembled and simulated with correct results. That does not imply that de hardware works, there are separate testcases for that but I cannot run them on GitHub.
