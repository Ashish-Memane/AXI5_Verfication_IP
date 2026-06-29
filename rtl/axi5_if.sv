// =========================================================================
// File Name   : axi5_if.sv
// Description : Parameterized AMBA AXI5 Interface with Protocol Assertions
// =========================================================================

`timescale 1ns / 1ps

interface axi5_if #(
  parameter AW = 64,      // Address Width
  parameter DW = 64,      // Data Width (Synchronized to 64)
  parameter IW = 4        // ID Tag Width
)(
  input wire ACLK,
  input wire ARESETn
);

  // =====================================================================
  // 1. SIGNAL DECLARATION (Changed to 'wire' to connect to RTL outputs)
  // =====================================================================

  // Write Address Channel (AW)
  wire [IW-1:0]     AWID;
  wire [AW-1:0]     AWADDR;
  wire [7:0]        AWLEN;
  wire [2:0]        AWSIZE;
  wire [1:0]        AWBURST;
  wire              AWVALID;
  wire              AWREADY;
  wire [5:0]        AWATOP;

  // Write Data Channel (W)
  wire [DW-1:0]     WDATA;
  wire [(DW/8)-1:0] WSTRB;
  wire              WLAST;
  wire              WVALID;
  wire              WREADY;
  wire              WPOISON;

  // Write Response Channel (B)
  wire [IW-1:0]     BID;
  wire [1:0]        BRESP;
  wire              BVALID;
  wire              BREADY;

  // Read Address Channel (AR)
  wire [IW-1:0]     ARID;
  wire [AW-1:0]     ARADDR;
  wire [7:0]        ARLEN;
  wire [2:0]        ARSIZE;
  wire [1:0]        ARBURST;
  wire              ARVALID;
  wire              ARREADY;

  // Read Data Channel (R)
  wire [IW-1:0]     RID;
  wire [DW-1:0]     RDATA;
  wire [1:0]        RRESP;
  wire              RLAST;
  wire              RVALID;
  wire              RREADY;
  wire              RPOISON;

  // =====================================================================
  // 2. CLOCKING BLOCKS
  // =====================================================================

  clocking driver_cb @(posedge ACLK);
    default input #1ns output #1ns;

    output AWID, AWADDR, AWLEN, AWSIZE, AWBURST, AWVALID, AWATOP;
    input  AWREADY;

    output WDATA, WSTRB, WLAST, WVALID, WPOISON;
    input  WREADY;

    output BREADY;
    input  BID, BRESP, BVALID;

    output ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARVALID;
    input  ARREADY;

    input  RID, RDATA, RRESP, RLAST, RVALID, RPOISON;
    output RREADY;
  endclocking : driver_cb

  clocking monitor_cb @(posedge ACLK);
    default input #1ns output #1ns;

    input AWID, AWADDR, AWLEN, AWSIZE, AWBURST, AWVALID, AWREADY, AWATOP;
    input WDATA, WSTRB, WLAST, WVALID, WREADY, WPOISON;
    input BID, BRESP, BVALID, BREADY;
    input ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARVALID, ARREADY;
    input RID, RDATA, RRESP, RLAST, RVALID, RREADY, RPOISON;
  endclocking : monitor_cb

  // =====================================================================
  // 3. MODPORTS
  // =====================================================================
  modport driver_mp  (clocking driver_cb,  input ARESETn);
  modport monitor_mp (clocking monitor_cb, input ARESETn);

  // =====================================================================
  // 4. PROTOCOL CHECKERS (SVA)
  // =====================================================================

  property p_reset_valid_low;
    @(posedge ACLK) !ARESETn |-> (!AWVALID && !WVALID && !BVALID && !ARVALID && !RVALID);
  endproperty : p_reset_valid_low

  assert_reset_valid_low : assert property(p_reset_valid_low)
    else $error("[AXI5_IF_ERR] A channel Valid signal was active during reset!");

  property p_awvalid_stability;
    @(posedge ACLK) disable iff(!ARESETn)
    (AWVALID && !AWREADY) |=> (AWVALID && $stable(AWADDR) && $stable(AWID) && $stable(AWLEN) && $stable(AWATOP));
  endproperty : p_awvalid_stability

  assert_awvalid_stability : assert property (p_awvalid_stability)
    else $error("[AXI5_IF_ERR] AWVALID handshake or payload stability failed!");

  property p_wvalid_stability;
    @(posedge ACLK) disable iff(!ARESETn)
    (WVALID && !WREADY) |=> (WVALID && $stable(WDATA) && $stable(WSTRB) && $stable(WLAST) && $stable(WPOISON));
  endproperty : p_wvalid_stability

  assert_wvalid_stability : assert property (p_wvalid_stability)
    else $error("[AXI5_IF_ERR] WVALID handshake or payload stability failed!");

  property p_arvalid_stability;
    @(posedge ACLK) disable iff(!ARESETn)
    (ARVALID && !ARREADY) |=> (ARVALID && $stable(ARADDR) && $stable(ARID) && $stable(ARLEN));
  endproperty : p_arvalid_stability

  assert_arvalid_handshake : assert property (p_arvalid_stability)
    else $error("[AXI5_IF_ERR] ARVALID handshake or payload stability failed!");

  property p_rvalid_stability;
    @(posedge ACLK) disable iff (!ARESETn)
    (RVALID && !RREADY) |=> (RVALID && $stable(RDATA) && $stable(RID) && $stable(RLAST) && $stable(RPOISON));
  endproperty : p_rvalid_stability

  assert_rvalid_handshake : assert property (p_rvalid_stability)
    else $error("[AXI5_IF_ERR] RVALID handshake or payload stability failed!");

endinterface : axi5_if
