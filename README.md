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

<img width="2760" height="1920" alt="uart_architecture_diagram" src="https://github.com/user-attachments/assets/6f9845b2-70f7-4482-8105-b2af875b9bb3" />


## UART Frame Format

<img width="2720" height="2043" alt="uart_frame_structure" src="https://github.com/user-attachments/assets/dd514685-cadb-4f3c-925b-9f91a6f4f6b6" />


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

uart-rtl-verilog/
│
├── README.md
│
├── rtl/
│   ├── uart_tx.v
│   ├── uart_rx.v
│   └── uart_top.v
│
├── tb/
│   ├── uart_tx_tb.v
│   ├── uart_rx_tb.v
│   └── uart_top_tb.v
│
├── docs/
│   ├── architecture.png
│   ├── uart_frame.png
│   ├── tx_fsm.png
│   ├── rx_fsm.png
│   └── waveform.png
│
└── simulation/
    └── simulation_output.txt
