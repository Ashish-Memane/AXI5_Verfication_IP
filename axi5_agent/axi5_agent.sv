// =========================================================================
// File Name   : axi5_agent.sv
// Description : Parameterized UVM Agent wrapping Sequencer, Driver, and Monitor.
// =========================================================================

`ifndef AXI5_AGENT_SV
`define AXI5_AGENT_SV

class axi5_agent #(
  parameter int AW = 64, // Address Width
  parameter int DW = 64, // Data Width
  parameter int IW = 4   // ID Tag Width
) extends uvm_agent;

  // =====================================================================
  // 1. CLASS PROPERTIES & UTILITIES
  // =====================================================================
  `uvm_component_param_utils(axi5_agent #(AW, DW, IW))

  // Verification Component Handles
  axi5_sequencer #(AW, DW, IW) sqr;
  axi5_drv       #(AW, DW, IW) drv;
  axi5_mon       #(AW, DW, IW) mon;

  // Configuration Object Handle
  axi5_agt_config m_cfg;

  // Virtual Interface Handle
  virtual axi5_if #(AW, DW, IW) vif;

  // =====================================================================
  // 2. CONSTRUCTOR
  // =====================================================================
  function new(string name = "axi5_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // =====================================================================
  // 3. UVM PHASES
  // =====================================================================
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // 1. Extract the physical virtual interface wrapper from the config database
    if (!uvm_config_db#(virtual axi5_if #(AW, DW, IW))::get(this, "", "vif", vif)) begin
      `uvm_fatal("AGT_VIF_ERR", "Could not locate virtual interface (vif) inside the agent's configuration DB!")
    end

    // 2. Get the configuration object (CORRECTED: Removed 'virtual' keyword from the class type parameter)
    if (!uvm_config_db#(axi5_agt_config)::get(this, "", "axi5_agt_config", m_cfg)) begin
      `uvm_fatal("AGT_CONF_ERR", "Cannot get the configuration object from uvm_config_db!")
    end

    // 3. Always build the passive monitor (regardless of ACTIVE/PASSIVE configuration)
    mon = axi5_mon #(AW, DW, IW)::type_id::create("mon", this);

    // Propagate virtual interface handle directly down to the child monitor
    uvm_config_db#(virtual axi5_if #(AW, DW, IW))::set(this, "mon", "vif", vif);

    // 4. Build Sequencer and Driver only if the agent is configured as active
    if (m_cfg.is_active == UVM_ACTIVE) begin
      sqr = axi5_sequencer #(AW, DW, IW)::type_id::create("sqr", this);
      drv = axi5_drv       #(AW, DW, IW)::type_id::create("drv", this);

      // Propagate virtual interface handle directly down to the driver
      uvm_config_db#(virtual axi5_if #(AW, DW, IW))::set(this, "drv", "vif", vif);
    end else begin
      `uvm_info("AXI5_AGT", "Agent configured as PASSIVE. Sequencer and Driver instances omitted.", UVM_MEDIUM)
    end
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect driver's TLM port to sequencer's TLM export if agent is active
    if (m_cfg.is_active == UVM_ACTIVE) begin
      drv.seq_item_port.connect(sqr.seq_item_export);
      `uvm_info("AXI5_AGT", "Driver seq_item_port connected to Sequencer seq_item_export successfully.", UVM_MEDIUM)
    end
  endfunction : connect_phase

endclass : axi5_agent

`endif // AXI5_AGENT_SV
