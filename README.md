# AXI5 Verification IP (VIP)

A reusable **UVM-based AXI5 Verification IP** developed in SystemVerilog for verifying AXI5-compliant designs. The VIP is parameterized to support different address, data, and ID widths and provides a modular verification environment with configurable agents, protocol-aware sequences, and a scalable testbench architecture.

## Features

* UVM-based reusable verification environment
* Parameterized Address, Data, and ID widths
* Configurable AXI5 Agent
* Driver, Monitor, Sequencer, and Transaction classes
* Scoreboard-based checking
* Virtual Interface support through `uvm_config_db`
* Makefile-based simulation flow
* Modular and scalable testbench architecture

## Supported Test Scenarios

The current test library includes:

* Sanity Test
* Random Burst Transactions
* Narrow Transfers
* Unaligned Address Access
* Wrap Burst Transactions
* AXI5 Atomic Operations
* Data Poisoning
* Out-of-Order Transaction Stress Test

These tests are implemented as reusable UVM sequences and executed through dedicated UVM test classes.

## Repository Structure

```text
AXI5_Verification_IP/
│
├── axi5_agent/
│   ├── axi5_agent.sv
│   ├── axi5_agt_config.sv
│   ├── axi5_drv.sv
│   ├── axi5_mon.sv
│   ├── axi5_seq_lib.sv
│   ├── axi5_sequencer.sv
│   └── axi5_xtn.sv
│
├── rtl/
│   ├── axi5_if.sv
│   └── axi5_mock_rtl.sv
│
├── tb/
│   ├── axi5_env.sv
│   ├── axi5_scoreboard.sv
│   └── axi5_tb_top.sv
│
├── test/
│   ├── axi5_pkg.sv
│   └── axi5_test_lib.sv
│
└── sim/
    └── Makefile
```

## Testbench Architecture

```text
                  +----------------------+
                  |      UVM Test        |
                  +----------+-----------+
                             |
                             v
                  +----------------------+
                  |      AXI5 Env        |
                  +----------+-----------+
                             |
         +-------------------+-------------------+
         |                                       |
         v                                       v
+---------------------+                +-------------------+
|     AXI5 Agent      |                |    Scoreboard     |
+----------+----------+                +-------------------+
           |
   +-------+-------+
   |       |       |
   v       v       v
Driver  Sequencer Monitor
   |
   v
AXI5 Interface
   |
   v
Mock RTL / DUT
```

## Parameterization

The verification environment is parameterized using:

| Parameter | Description   | Default |
| --------- | ------------- | ------- |
| AW        | Address Width | 64      |
| DW        | Data Width    | 64      |
| IW        | ID Width      | 4       |

This enables easy adaptation of the VIP for different AXI5 configurations.

## Running the Simulation

The repository contains a Makefile under the `sim/` directory.

Typical usage:

```bash
cd sim
make
```

Refer to the Makefile for simulator-specific compile and run targets.

## Future Enhancements

* Functional Coverage
* Protocol Checker
* Multi-Agent Support
* Read/Write Interleaving
* Outstanding Transaction Tracking
* Coverage Reports
* Regression Automation
* Performance Metrics

## Author

**Ashish Memane**

## License

This project is intended for educational and verification research purposes. Add an appropriate open-source license if the repository is intended for public use.
