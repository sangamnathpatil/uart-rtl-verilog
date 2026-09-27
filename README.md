# UART RTL Design in Verilog

A synthesizable UART design implemented in Verilog HDL, featuring a counter-based transmitter and FSM-based receiver.

## Project Overview

This project implements a UART communication system supporting:

- 8-bit data transmission
- Start and stop bits
- Parameterized clock frequency
- Parameterized baud rate
- Counter-based UART transmitter
- FSM-based UART receiver
- TX/RX integration
- Individual and integrated testbenches
- Simulation-based verification

## Architecture

[architecture image]

## UART Frame Format

[uart frame image]

## Design Modules

### UART Transmitter

The UART transmitter uses counter-based control logic to generate the baud timing and serialize an 8-bit parallel data word.

### UART Receiver

The UART receiver uses a finite state machine to detect the start bit, receive the 8 data bits, process the stop bit, and indicate completion.

### UART Top

The top-level module integrates the transmitter and receiver into a single UART design.

## Verification

Separate testbenches are provided for:

- UART TX
- UART RX
- UART Top-level integration

Simulation waveforms were analyzed using GTKWave.

## Tools Used

- Verilog HDL
- Icarus Verilog
- GTKWave
- VS Code
- Git / GitHub

## Repository Structure

...
