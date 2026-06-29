// =========================================================================
// File Name   : axi5_pkg.sv
// Description : Unified Package wrapping all compilation assets for the AXI5 VIP.
//               Compiles all transaction models, transactors, checking structures,
//               testbench environments, and testcases in strict chronological
//               dependency order.
// =========================================================================

`ifndef AXI5_PKG_SV
`define AXI5_PKG_SV

package axi5_pkg;

  // 1. Import standard UVM Package library and include its global macros
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // 2. Include core agent class definitions in strict dependency order
  `include "axi5_xtn.sv"         // Transaction descriptor compiled first
  `include "axi5_agt_config.sv"  // Agent configuration object
  `include "axi5_sequencer.sv"   // Sequencer parameterized by transaction item
  `include "axi5_drv.sv"         // Master driver referencing interface and transactions
  `include "axi5_mon.sv"         // Passive out-of-order reconstructing monitor
  `include "axi5_agent.sv"       // Agent container coordinating driver, monitor, and sequencer

  // 3. Include high-level verification and check environments
  `include "axi5_scoreboard.sv"  // Memory-reference validation scoreboard
  `include "axi5_env.sv"         // Top-level environment wrapping agent and scoreboard
  `include "axi5_seq_lib.sv"     // Sequence library containing base and sanity loops
  `include "axi5_test_lib.sv"   // Base testcase coordinating environment and stimulus execution

endpackage : axi5_pkg

`endif // AXI5_PKG_SV
