# UART RTL Design in Verilog

A complete UART (Universal Asynchronous Receiver/Transmitter) RTL design implemented in Verilog HDL, featuring a **counter-based transmitter**, **FSM-based receiver**, and an integrated top-level UART module.

The design is parameterized for clock frequency and baud rate and is verified using dedicated TX, RX, and top-level testbenches.

---

## Project Overview

This project implements a basic UART communication system supporting:

* 8-bit data transmission and reception
* 1 start bit
* 8 data bits
* 1 stop bit
* LSB-first data transmission
* Parameterized clock frequency
* Parameterized baud rate
* Counter-based UART transmitter
* FSM-based UART receiver
* Asynchronous RX input synchronization using two flip-flops
* TX/RX top-level integration
* Dedicated verification testbenches
* Simulation waveform analysis using GTKWave

---

## UART Frame Format

Each UART frame consists of 10 bits:

```text
| Start | Data Bit 0 | Data Bit 1 | Data Bit 2 | Data Bit 3 |
|   0   |     D0     |     D1     |     D2     |     D3     |

| Data Bit 4 | Data Bit 5 | Data Bit 6 | Data Bit 7 | Stop |
|     D4     |     D5     |     D6     |     D7     |  1   |
```

The UART line remains HIGH when idle.

The transmitter sends the data **LSB first**.

---

## Architecture

![UART Architecture](docs/architecture.png)

The design consists of three main RTL modules:

```text
                    ┌─────────────────────┐
                    │      UART TOP       │
                    │                     │
TX Data ───────────►│     UART TX         │
TX Start ──────────►│       │             │
                    │       ▼             │
                    │   UART Serial Line  │
                    │       │             │
                    │       ▼             │
                    │     UART RX         │
                    │       │             │
                    └───────┼─────────────┘
                            │
                         RX Data
```

---

## RTL Modules

### 1. UART Transmitter

**File:** `rtl/uart_tx.v`

The transmitter is implemented using **counter-based control logic** rather than an explicit FSM.

Main components:

* Baud-rate counter
* 10-bit shift register
* Bit counter
* Busy indicator
* Done pulse

The 10-bit shift register contains:

```text
{STOP, DATA[7:0], START}
```

For example:

```verilog
shift_reg <= {1'b1, data, 1'b0};
```

The transmitter then shifts the frame right to transmit the bits sequentially.

### TX sequence

```text
IDLE
  │
  │ start
  ▼
START BIT
  │
  ▼
DATA[0]
  │
  ▼
DATA[1]
  │
  ▼
 ...
  │
  ▼
DATA[7]
  │
  ▼
STOP BIT
  │
  ▼
IDLE
```

---

### 2. UART Receiver

**File:** `rtl/uart_rx.v`

The receiver uses a **finite state machine (FSM)** for UART frame reception.

States:

```text
IDLE
START
DATA
STOP
```

### RX operation

1. Wait for the serial line to go LOW.
2. Enter the START state.
3. Wait for half a baud period.
4. Verify that the start bit is still LOW.
5. Sample eight data bits at baud intervals.
6. Receive the data LSB first.
7. Check the stop bit.
8. Transfer the received byte to `data_out`.
9. Generate a `done` pulse.

---

## RX Input Synchronization

The asynchronous RX input is synchronized using two flip-flops:

```text
rx
 │
 ▼
┌─────────┐
│ rx_meta │
└────┬────┘
     │
     ▼
┌─────────┐
│ rx_sync │
└────┬────┘
     │
     ▼
   RX FSM
```

This reduces the risk of metastability propagating into the receiver logic.

---

## RX FSM

![RX FSM](docs/rx_fsm.png)

The receiver FSM consists of four states:

```text
       ┌──────────────┐
       │              │
       ▼              │
     IDLE ──LOW────► START
       ▲              │
       │              │ valid start
       │              ▼
       │             DATA
       │              │
       │           8 bits
       │              ▼
       │             STOP
       │              │
       └──────────────┘
```

If the start bit is invalid, the receiver returns to `IDLE`.

---

## TX Timing / Bit Sequence

![TX Sequence](docs/tx_fsm.png)

The transmitter uses a baud counter to determine when each UART bit period has completed.

For the default configuration:

```text
Clock Frequency = 50 MHz
Baud Rate       = 9600
```

The baud divider is calculated as:

```text
BAUD_DIV = CLK_FREQ / BAUD_RATE
         = 50,000,000 / 9,600
         ≈ 5208 clock cycles
```

---

## Top-Level Integration

**File:** `rtl/uart_top.v`

The top-level module connects the transmitter and receiver through an internal serial line:

```text
                uart_line
TX ─────────────────────────► RX
```

The top-level module provides:

### TX interface

```text
tx_data
tx_start
tx_busy
tx_done
```

### RX interface

```text
rx_data
rx_done
```

The transmitter output is directly connected to the receiver input internally for integrated simulation.

---

## Verification

The project contains three dedicated testbenches:

```text
tb/
├── uart_tx_tb.v
├── uart_rx_tb.v
└── uart_top_tb.v
```

### UART TX Testbench

Verifies:

* Reset behavior
* Transmission start
* Start bit
* Eight data bits
* Stop bit
* Busy signal
* Done signal
* Baud-rate timing

### UART RX Testbench

Verifies:

* Start-bit detection
* Start-bit validation
* Data reception
* LSB-first sampling
* Stop-bit validation
* Received data
* Done signal

### UART Top Testbench

Verifies the integrated communication path:

```text
TX Data
   │
   ▼
UART TX
   │
   ▼
Serial Line
   │
   ▼
UART RX
   │
   ▼
RX Data
```

---

## Simulation

The design was simulated using **Icarus Verilog** and waveforms were analyzed using **GTKWave**.

Example compilation:

```bash
iverilog -o uart_tx_sim rtl/uart_tx.v tb/uart_tx_tb.v
vvp uart_tx_sim
```

RX:

```bash
iverilog -o uart_rx_sim rtl/uart_rx.v tb/uart_rx_tb.v
vvp uart_rx_sim
```

Top-level integration:

```bash
iverilog -o uart_top_sim rtl/uart_tx.v rtl/uart_rx.v rtl/uart_top.v tb/uart_top_tb.v
vvp uart_top_sim
```

Waveform viewing:

```bash
gtkwave uart_top.vcd
```

---

## GTKWave

![Simulation Waveform](docs/waveform.png)

The waveform can be used to observe:

* Clock
* Reset
* TX start
* TX busy
* TX serial output
* RX serial input
* RX data
* RX done
* Baud-rate timing

---

## Project Structure

```text
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
```

---

## Tools Used

* **Verilog HDL**
* **Icarus Verilog**
* **GTKWave**
* **Visual Studio Code**
* **Git**
* **GitHub**

---

## Concepts Demonstrated

* RTL Design
* UART Serial Communication
* Baud-Rate Generation
* Counters
* Shift Registers
* Finite State Machines
* Sequential Logic
* Clocked Design
* Asynchronous Input Synchronization
* Data Serialization
* Data Deserialization
* RTL Testbench Development
* Simulation and Waveform Debugging

---

## Future Improvements

Possible extensions to the design include:

* Configurable parity support
* Parameterized data width
* Multiple stop-bit options
* Oversampling-based UART receiver
* Parity error detection
* Framing error detection
* RX error flags
* FIFO buffering
* SystemVerilog-based verification
* Functional coverage and assertions

---

## Author

**Sangamnath Mohan Patil**

Electronics & Telecommunication Engineering
VLSI / RTL Design & Verification
