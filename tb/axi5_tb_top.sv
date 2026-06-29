// =========================================================================
// File Name   : axi5_tb_top.sv
// Description : Top-level Hardware Module for AMBA AXI5 Simulation.
// =========================================================================

`timescale 1ns/1ps

module axi5_tb_top;

  // =====================================================================
  // 1. PARAMETERS & GLOBAL WIRES
  // =====================================================================
  parameter int AW = 64; // Address Width
  parameter int DW = 64; // Data Width
  parameter int IW = 4;  // ID Tag Width

  logic ACLK;
  logic ARESETn;

  // =====================================================================
  // 2. CLOCK & RESET GENERATORS
  // =====================================================================

  // Generate a 100MHz system clock
  initial begin
    ACLK = 0;
    forever #5 ACLK = ~ACLK;
  end

  // Generate an asynchronous, active-low power-on reset
  initial begin
    ARESETn = 1'b0;
    #25;
    ARESETn = 1'b1;
  end

  // =====================================================================
  // 3. PHYSICAL INTERFACE INSTANTIATION
  // =====================================================================
  axi5_if #(
    .AW(AW),
    .DW(DW),
    .IW(IW)
)inf (
    .ACLK    (ACLK),
    .ARESETn (ARESETn)
  );

  // =====================================================================                              // In simple words if you have the design just plug and play remove the mock slave responder//
  // 4. FAKE RTL DUT INSTANTIATION
  // =====================================================================
  axi5_slave_mock_rtl #(
    .ADDR_WIDTH (AW),
    .DATA_WIDTH (DW),
    .ID_WIDTH   (IW)
  ) u_dut (
    .aclk         (inf.ACLK),
    .aresetn      (inf.ARESETn),

    // Write Address Channel
    .s_awid       (inf.AWID),
    .s_awaddr     (inf.AWADDR),
    .s_awlen      (inf.AWLEN),
    .s_awsize     (inf.AWSIZE),
    .s_awburst    (inf.AWBURST),
    .s_awatop     (inf.AWATOP),
    .s_awvalid    (inf.AWVALID),
    .s_awready    (inf.AWREADY),

    // Write Data Channel
    .s_wdata      (inf.WDATA),
    .s_wstrb      (inf.WSTRB),
    .s_wlast      (inf.WLAST),
    .s_wpoison    (inf.WPOISON),
    .s_wvalid     (inf.WVALID),
    .s_wready     (inf.WREADY),

    // Write Response Channel
    .s_bid        (inf.BID),
    .s_bresp      (inf.BRESP),
    .s_bvalid     (inf.BVALID),
    .s_bready     (inf.BREADY),

    // Read Address Channel
    .s_arid       (inf.ARID),
    .s_araddr     (inf.ARADDR),
    .s_arlen      (inf.ARLEN),
    .s_arsize     (inf.ARSIZE),
    .s_arburst    (inf.ARBURST),
    .s_arvalid    (inf.ARVALID),
    .s_arready    (inf.ARREADY),

    // Read Data Channel
    .s_rid        (inf.RID),
    .s_rdata      (inf.RDATA),
    .s_rresp      (inf.RRESP),
    .s_rlast      (inf.RLAST),
    .s_rpoison    (inf.RPOISON),
    .s_rvalid     (inf.RVALID),
    .s_rready     (inf.RREADY)
  );

/*
  // =====================================================================
  // 4. MOCK SLAVE RESPONDER (DUT LOOPBACK STUB)
  // =====================================================================
  // This lightweight hardware block listens to the master interface pins
  // and automatically processes protocol handshakes. This guarantees your
  // testbench driver doesn't hang waiting for hardware responses.

  // Write Channels Handshake Loopback
  always @(posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) begin
      inf.AWREADY <= 1'b0;
      inf.WREADY  <= 1'b0;
      inf.BVALID  <= 1'b0;
      inf.BID     <= '0;
      inf.BRESP   <= 2'b00; // OKAY
    end else begin
      // Acknowledge Write Addresses instantly
      if (inf.AWVALID && !inf.AWREADY) begin
        inf.AWREADY <= 1'b1;
      end else begin
        inf.AWREADY <= 1'b0;
      end

      // Acknowledge Write Data beats instantly
      if (inf.WVALID && !inf.WREADY) begin
        inf.WREADY <= 1'b1;
      end else begin
        inf.WREADY <= 1'b0;
      end

      // Handle Write Responses (B-channel) when a burst finishes (WLAST)
      if (inf.WVALID && inf.WREADY && inf.WLAST) begin
        inf.BVALID <= 1'b1;
        inf.BID    <= inf.AWID; // Return matching ID
        inf.BRESP  <= 2'b00;    // OKAY response status
      end else if (inf.BVALID && inf.BREADY) begin
        inf.BVALID <= 1'b0;
      end
    end
  end

  // Read Channels Handshake Loopback
  reg [IW-1:0] read_id_buffer;
  reg [7:0]    read_len_buffer;
  reg          read_in_progress = 0;
  reg [7:0]    read_beat_counter = 0;

  always @(posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) begin
      inf.ARREADY <= 1'b0;
      inf.RVALID  <= 1'b0;
      inf.RID     <= '0;
      inf.RDATA   <= '0;
      inf.RRESP   <= 2'b00;
      inf.RLAST   <= 1'b0;
      inf.RPOISON <= 1'b0;

      read_in_progress  <= 0;
      read_beat_counter <= 0;
    end else begin
      // Acknowledge incoming read addresses
      if (inf.ARVALID && !inf.ARREADY && !read_in_progress) begin
        inf.ARREADY       <= 1'b1;
        read_id_buffer    <= inf.ARID;
        read_len_buffer   <= inf.ARLEN;
        read_in_progress  <= 1'b1;
        read_beat_counter <= 0;
      end else begin
        inf.ARREADY <= 1'b0;
      end

      // Process read data returning beats
      if (read_in_progress && !inf.RVALID) begin
        inf.RVALID  <= 1'b1;
        inf.RID     <= read_id_buffer;
        // Generate mock test data (e.g., returning the current beat offset)
        inf.RDATA   <= 64'hC0DE_0000_0000_0000 | read_beat_counter;
        inf.RRESP   <= 2'b00; // OKAY status
        inf.RPOISON <= 1'b0;  // Clean read data
        inf.RLAST   <= (read_beat_counter == read_len_buffer) ? 1'b1 : 1'b0;
      end else if (inf.RVALID && inf.RREADY) begin
        inf.RVALID <= 1'b0;
        inf.RLAST  <= 1'b0;

        if (read_beat_counter == read_len_buffer) begin
          read_in_progress <= 1'b0;
        end else begin
          read_beat_counter++;
        end
      end
    end
  end
*/
  // =====================================================================
  // 5. UVM ENTRY POINT SETUP
  // =====================================================================
  initial begin
    // Standard Imports inside the run block scope
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import axi5_pkg::*;


    `uvm_info("TB_TOP", "Registering physical interface (vif) inside uvm_config_db...", UVM_LOW)

    // Set virtual interface in database targeting all components
    uvm_config_db#(virtual axi5_if #(AW, DW, IW))::set(null, "*", "vif", inf);

    // Turn on diagnostic wave logging (compatible with Verdi/VCS)
    if ($test$plusargs("WAVE_ON")) begin
      $dumpfile("axi5_simulation_waves.vcd");
      $dumpvars(0, axi5_tb_top);
    end

    // Boot the UVM verification phases
    // Will automatically resolve and launch the active command-line test (e.g. +UVM_TESTNAME=axi5_base_test)
    run_test();
  end

endmodule : axi5_tb_top
~
