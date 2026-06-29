// =========================================================================
// File Name   : axi5_mock_rtl.sv
// Description : Hardened parameter-driven AXI5 stub.
// =========================================================================

`timescale 1ns/1ps

module axi5_slave_mock_rtl #(
  parameter int ADDR_WIDTH = 64,
  parameter int DATA_WIDTH = 64, // Synchronized to 64
  parameter int ID_WIDTH   = 4
)(
  input  wire aclk,
  input  wire aresetn,

  // Write Address Channel
  input  wire [ID_WIDTH-1:0]    s_awid,
  input  wire [ADDR_WIDTH-1:0]  s_awaddr,
  input  wire [7:0]             s_awlen,
  input  wire [2:0]             s_awsize,
  input  wire [1:0]             s_awburst,
  input  wire [5:0]             s_awatop,
  input  wire                   s_awvalid,
  output wire                   s_awready,

  // Write Data Channel
  input  wire [DATA_WIDTH-1:0]      s_wdata,
  input  wire [(DATA_WIDTH/8)-1:0]  s_wstrb,
  input  wire                       s_wlast,
  input  wire                       s_wpoison,
  input  wire                       s_wvalid,
  output wire                       s_wready,

  // Write Response Channel
  output wire [ID_WIDTH-1:0]    s_bid,
  output wire [1:0]             s_bresp,
  output wire                   s_bvalid,
  input  wire                   s_bready,

  // Read Address Channel
  input  wire [ID_WIDTH-1:0]    s_arid,
  input  wire [ADDR_WIDTH-1:0]  s_araddr,
  input  wire [7:0]             s_arlen,
  input  wire [2:0]             s_arsize,
  input  wire [1:0]             s_arburst,
  input  wire                   s_arvalid,
  output wire                   s_arready,

  // Read Data Channel
  output wire [ID_WIDTH-1:0]    s_rid,
  output wire [DATA_WIDTH-1:0]  s_rdata,
  output wire [1:0]             s_rresp,
  output wire                   s_rlast,
  output wire                   s_rpoison,
  output wire                   s_rvalid,
  input  wire                   s_rready
);

  assign s_awready = 1'b1;
  assign s_wready  = 1'b1;
  assign s_bvalid  = (s_wvalid && s_wlast);
  assign s_bid     = s_awid;
  assign s_bresp   = 2'b00;

  assign s_arready = 1'b1;

  reg rvalid_reg;
  always @(posedge aclk or negedge aresetn) begin
    if (!aresetn)          rvalid_reg <= 1'b0;
    else if (s_arvalid)    rvalid_reg <= 1'b1;
    else if (s_rready)     rvalid_reg <= 1'b0;
  end

  assign s_rvalid  = rvalid_reg;
  assign s_rid     = s_arid;
  assign s_rdata   = {DATA_WIDTH{1'b0}};
  assign s_rresp   = 2'b00;
  assign s_rlast   = 1'b1;
  assign s_rpoison = 1'b0;

endmodule : axi5_slave_mock_rtl
