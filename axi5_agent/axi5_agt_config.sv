// =========================================================================
// File Name   : axi5_agt_config.sv
// Description : Configuration class for the AXI5 Master Agent.
//               Enables control of Active/Passive status at runtime.
// =========================================================================

`ifndef AXI5_AGT_CONFIG_SV
`define AXI5_AGT_CONFIG_SV

class axi5_agt_config extends uvm_object;

  // Active/Passive Control (Defaults to ACTIVE)
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  // Constructor
  function new(string name = "axi5_agt_config");
    super.new(name);
  endfunction : new

  // Factory and Field Registration
  `uvm_object_utils_begin(axi5_agt_config)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
  `uvm_object_utils_end

endclass : axi5_agt_config

`endif // AXI5_AGT_CONFIG_SV
