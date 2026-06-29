// =========================================================================
// File Name   : axi5_seq_lib.sv
// Description : Comprehensive Parameterized Stimulus Sequence Library
// =========================================================================

`ifndef AXI5_SEQ_LIB_SV
`define AXI5_SEQ_LIB_SV

// =====================================================================
// 1. AXI5 BASE SEQUENCE
// =====================================================================
class axi5_base_seq #(
  parameter int AW = 64,
  parameter int DW = 64,
  parameter int IW = 4
) extends uvm_sequence #(axi5_xtn #(AW, DW, IW));

  `uvm_object_param_utils(axi5_base_seq #(AW, DW, IW))

  function new(string name = "axi5_base_seq");
    super.new(name);
  endfunction : new

  // Common utility task to handle pre-run objections inside sequences
  virtual task pre_body();
    if (starting_phase != null) begin
      starting_phase.raise_objection(this, $sformatf("%s started", get_name()));
    end
  endtask : pre_body

  virtual task post_body();
    if (starting_phase != null) begin
      starting_phase.drop_objection(this, $sformatf("%s finished", get_name()));
    end
  endtask : post_body

endclass : axi5_base_seq


// =====================================================================
// 2. CONCRETE SANITY SEQUENCE (Write-after-Read Verification Loop)
// =====================================================================
class axi5_sanity_seq #(
  parameter int AW = 64,
  parameter int DW = 64,
  parameter int IW = 4
) extends axi5_base_seq #(AW, DW, IW);

  `uvm_object_param_utils(axi5_sanity_seq #(AW, DW, IW))

  function new(string name = "axi5_sanity_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    axi5_xtn #(AW, DW, IW) write_tx;
    axi5_xtn #(AW, DW, IW) read_tx;

    `uvm_info(get_type_name(), "Starting back-to-back AXI5 transaction verification sweeps...", UVM_LOW)

    for (int i = 0; i < 10; i++) begin
      // Step A: Generate and randomize a Write Transaction
      write_tx = axi5_xtn #(AW, DW, IW)::type_id::create("write_tx");
      start_item(write_tx);
      if (!write_tx.randomize() with {
        xact_type  == WRITE;
        addr       == (64'h1000 + (i * 64)); // Ensure unique, aligned address offsets
        burst_type == INCR;
        len        == 3;                     // 4 beats burst
        size       == 3;                     // 8 Bytes (64-bit wide beat)
        atop       == 6'b000000;             // Non-atomic standard transaction
      }) begin
        `uvm_fatal("RAND_FAIL", "Write transaction randomization failed!")
      end
      finish_item(write_tx);
      `uvm_info(get_type_name(), $sformatf("Dispatched Write ID=0x%0h to Addr=0x%0h", write_tx.id, write_tx.addr), UVM_HIGH)

      // Step B: Generate a matching Read Transaction to verify data integrity
      read_tx = axi5_xtn #(AW, DW, IW)::type_id::create("read_tx");
      start_item(read_tx);
      if (!read_tx.randomize() with {
        xact_type  == READ;
        id         == write_tx.id;           // Match the ID for verification grouping
        addr       == write_tx.addr;         // Target the exact same address
        burst_type == write_tx.burst_type;
        len        == write_tx.len;
        size       == write_tx.size;
      }) begin
        `uvm_fatal("RAND_FAIL", "Read transaction randomization failed!")
      end
      finish_item(read_tx);
      `uvm_info(get_type_name(), $sformatf("Dispatched matching Read ID=0x%0h to Addr=0x%0h", read_tx.id, read_tx.addr), UVM_HIGH)
    end
  endtask : body

endclass : axi5_sanity_seq


// =====================================================================
// 3. FULLY RANDOMIZED BURST SEQUENCE
// =====================================================================
class axi5_rand_burst_seq #(
  parameter int AW = 64,
  parameter int DW = 64,
  parameter int IW = 4
) extends axi5_base_seq #(AW, DW, IW);

  `uvm_object_param_utils(axi5_rand_burst_seq #(AW, DW, IW))

  rand int num_transactions;
  constraint c_num_tx { soft num_transactions inside {[15:30]}; }

  function new(string name = "axi5_rand_burst_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    axi5_xtn #(AW, DW, IW) tx;
    `uvm_info(get_type_name(), $sformatf("Executing %0d fully randomized AXI5 bursts...", num_transactions), UVM_LOW)

    repeat(num_transactions) begin
      tx = axi5_xtn #(AW, DW, IW)::type_id::create("tx");
      start_item(tx);
      if (!tx.randomize()) begin
        `uvm_fatal("RAND_FAIL", "Random burst transaction randomization failed!")
      end
      finish_item(tx);
      `uvm_info(get_type_name(), $sformatf("Fired Rand Burst: %s, ID=0x%0h, Addr=0x%0h, Len=%0d, Size=%0d, BurstType=%s",
                tx.xact_type.name(), tx.id, tx.addr, tx.len, tx.size, tx.burst_type.name()), UVM_HIGH)
    end
  endtask : body

endclass : axi5_rand_burst_seq


// =====================================================================
// 4. NARROW TRANSFERS STRESS SEQUENCE (Size < Bus Width)
// =====================================================================
class axi5_narrow_transfer_seq #(
  parameter int AW = 64,
  parameter int DW = 64,
  parameter int IW = 4
) extends axi5_base_seq #(AW, DW, IW);

  `uvm_object_param_utils(axi5_narrow_transfer_seq #(AW, DW, IW))

  function new(string name = "axi5_narrow_transfer_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    axi5_xtn #(AW, DW, IW) tx;
    `uvm_info(get_type_name(), "Initiating narrow transfer sweeps (strobe alignment checks)...", UVM_LOW)

    // Sweep sizes from 1 Byte (0) up to less than maximum bus width to stress sparse strobes
    for (int size_val = 0; (1 << size_val) < (DW / 8); size_val++) begin
      tx = axi5_xtn #(AW, DW, IW)::type_id::create("tx");
      start_item(tx);
      if (!tx.randomize() with {
        xact_type  == WRITE;
        size       == size_val;
        burst_type == INCR;
        len        inside {[1:7]};
      }) begin
        `uvm_fatal("RAND_FAIL", "Narrow transfer randomization failed!")
      end
      finish_item(tx);
      `uvm_info(get_type_name(), $sformatf("Narrow Write: Size=%0d Bytes, Addr=0x%0h, Strobes[0]=16'b%0b",
                (1 << tx.size), tx.addr, tx.strb[0]), UVM_MEDIUM)
    end
  endtask : body

endclass : axi5_narrow_transfer_seq


// =====================================================================
// 5. UNALIGNED ADDRESS SEQUENCE
// =====================================================================
class axi5_unaligned_addr_seq #(
  parameter int AW = 64,
  parameter int DW = 64,
  parameter int IW = 4
) extends axi5_base_seq #(AW, DW, IW);

  `uvm_object_param_utils(axi5_unaligned_addr_seq #(AW, DW, IW))

  function new(string name = "axi5_unaligned_addr_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    axi5_xtn #(AW, DW, IW) tx;
    `uvm_info(get_type_name(), "Generating unaligned address boundaries offsets...", UVM_LOW)

    repeat (10) begin
      tx = axi5_xtn #(AW, DW, IW)::type_id::create("tx");
      start_item(tx);
      if (!tx.randomize() with {
        xact_type  == WRITE;
        size       == 3; // 8 Bytes per transfer
        // Force the lower 3 bits of address to be non-zero to create unaligned boundary offsets
        addr[2:0]  != 3'b000;
        burst_type == INCR;
        len        == 3;
      }) begin
        `uvm_fatal("RAND_FAIL", "Unaligned transaction randomization failed!")
      end
      finish_item(tx);
      `uvm_info(get_type_name(), $sformatf("Unaligned Write dispatched to Addr=0x%0h (Strobes alignment skewed)", tx.addr), UVM_HIGH)
    end
  endtask : body

endclass : axi5_unaligned_addr_seq


// =====================================================================
// 6. SPECIALIZED WRAP BURST CORNER-CASE SEQUENCE
// =====================================================================
class axi5_wrap_burst_seq #(
  parameter int AW = 64,
  parameter int DW = 64,
  parameter int IW = 4
) extends axi5_base_seq #(AW, DW, IW);

  `uvm_object_param_utils(axi5_wrap_burst_seq #(AW, DW, IW))

  function new(string name = "axi5_wrap_burst_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    axi5_xtn #(AW, DW, IW) tx;
    `uvm_info(get_type_name(), "Generating Wrapping bursts targeting Cache Line boundaries...", UVM_LOW)

    repeat (5) begin
      tx = axi5_xtn #(AW, DW, IW)::type_id::create("tx");
      start_item(tx);
      // WRAP rules: Must be aligned, length must be 1, 3, 7, 15 (2, 4, 8, 16 beats)
      if (!tx.randomize() with {
        burst_type == WRAP;
        size       == 3;             // 8-byte transfers (64-bit beats)
        len        inside {3, 7};    // 4 or 8 beat wraps
        xact_type  == WRITE;
      }) begin
        `uvm_fatal("RAND_FAIL", "Wrap burst transaction randomization failed!")
      end
      finish_item(tx);
      `uvm_info(get_type_name(), $sformatf("Dispatched WRAP: Addr=0x%0h, Len=%0d Beats, wrap-around tracking enabled.", tx.addr, tx.len+1), UVM_MEDIUM)
    end
  endtask : body

endclass : axi5_wrap_burst_seq


// =====================================================================
// 7. AXI5 ATOMIC OPERATIONS STRESS SEQUENCE (AWATOP)
// =====================================================================
class axi5_atomic_seq #(
  parameter int AW = 64,
  parameter int DW = 64,
  parameter int IW = 4
) extends axi5_base_seq #(AW, DW, IW);

  `uvm_object_param_utils(axi5_atomic_seq #(AW, DW, IW))

  function new(string name = "axi5_atomic_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    axi5_xtn #(AW, DW, IW) tx;
    `uvm_info(get_type_name(), "Executing modern AMBA AXI5 Atomic Transactions...", UVM_LOW)

    // AXI5 AWATOP encoding categories:
    // 6'b010000 - AtomicStore (ADD)
    // 6'b100000 - AtomicLoad (ADD)
    // 6'b110001 - AtomicCompare & Swap / AtomicSwap
    repeat (5) begin
      tx = axi5_xtn #(AW, DW, IW)::type_id::create("tx");
      start_item(tx);
      if (!tx.randomize() with {
        xact_type  == WRITE; // Atomics are initiated on the write channels
        burst_type == INCR;
        len        == 0;     // Typically single beat operations
        atop       inside {6'b010000, 6'b100000, 6'b110001}; // Custom Atomic Operations Opcode Set
      }) begin
        `uvm_fatal("RAND_FAIL", "Atomic transaction randomization failed!")
      end
      finish_item(tx);
      `uvm_info(get_type_name(), $sformatf("Atomic operation fired. Opcode AWATOP=6'b%6b sent to Addr=0x%0h", tx.atop, tx.addr), UVM_MEDIUM)
    end
  endtask : body

endclass : axi5_atomic_seq


// =====================================================================
// 8. DATA POISONING INJECTION SEQUENCE (WPOISON & RPOISON)
// =====================================================================
class axi5_poison_seq #(
  parameter int AW = 64,
  parameter int DW = 64,
  parameter int IW = 4
) extends axi5_base_seq #(AW, DW, IW);

  `uvm_object_param_utils(axi5_poison_seq #(AW, DW, IW))

  function new(string name = "axi5_poison_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    axi5_xtn #(AW, DW, IW) write_tx;
    axi5_xtn #(AW, DW, IW) read_tx;
    `uvm_info(get_type_name(), "Running transaction poisoning verification sweeps...", UVM_LOW)

    // Step A: Inject a poisoned write payload to memory location
    write_tx = axi5_xtn #(AW, DW, IW)::type_id::create("write_tx");
    start_item(write_tx);
    if (!write_tx.randomize() with {
      xact_type  == WRITE;
      addr       == 64'h2000;
      burst_type == INCR;
      len        == 3;
    }) begin
       `uvm_fatal("RAND_FAIL", "Poison write randomization failed!")
    end

    // Explicitly corrupt the third data beat inside this transaction
    write_tx.poison[2] = 1'b1;
    finish_item(write_tx);
    `uvm_info(get_type_name(), "Dispatched Write Burst with Poison injection on Beat index 2.", UVM_MEDIUM)

    // Step B: Issue a read on the exact same address to evaluate downstream logic safety
    read_tx = axi5_xtn #(AW, DW, IW)::type_id::create("read_tx");
    start_item(read_tx);
    if (!read_tx.randomize() with {
      xact_type  == READ;
      addr       == write_tx.addr;
      burst_type == write_tx.burst_type;
      len        == write_tx.len;
      size       == write_tx.size;
    }) begin
      `uvm_fatal("RAND_FAIL", "Read transaction matching poison target failed!")
    end
    finish_item(read_tx);
    `uvm_info(get_type_name(), "Read completed on poisoned address. Monitor and scoreboard will log safety flags.", UVM_MEDIUM)
  endtask : body

endclass : axi5_poison_seq


// =====================================================================
// 9. HIGH-STRESS INTERLEAVED OUT-OF-ORDER SEQUENCE
// =====================================================================
class axi5_out_of_order_seq #(
  parameter int AW = 64,
  parameter int DW = 64,
  parameter int IW = 4
) extends axi5_base_seq #(AW, DW, IW);

  `uvm_object_param_utils(axi5_out_of_order_seq #(AW, DW, IW))

  function new(string name = "axi5_out_of_order_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(), "Forking parallel out-of-order write/read streams over varying ID tags...", UVM_LOW)

    // We fork 4 independent transactional streams working on parallel IDs to stress-test
    // the out-of-order execution reassembly buffers in both the VIP monitor and the DUT.
    fork
      // Stream 1: Uses ID = 0x1
      begin
        axi5_xtn #(AW, DW, IW) tx = axi5_xtn #(AW, DW, IW)::type_id::create("tx_s1");
        start_item(tx);
        if (!tx.randomize() with { id == 4'h1; xact_type == WRITE; addr == 64'h5000; }) begin
          `uvm_fatal("RAND_FAIL", "Stream 1 randomization failed")
        end
        finish_item(tx);
      end

      // Stream 2: Uses ID = 0x2
      begin
        axi5_xtn #(AW, DW, IW) tx = axi5_xtn #(AW, DW, IW)::type_id::create("tx_s2");
        start_item(tx);
        if (!tx.randomize() with { id == 4'h2; xact_type == WRITE; addr == 64'h6000; }) begin
          `uvm_fatal("RAND_FAIL", "Stream 2 randomization failed")
        end
        finish_item(tx);
      end

      // Stream 3: Uses ID = 0x3
      begin
        axi5_xtn #(AW, DW, IW) tx = axi5_xtn #(AW, DW, IW)::type_id::create("tx_s3");
        start_item(tx);
        if (!tx.randomize() with { id == 4'h3; xact_type == READ; addr == 64'h7000; }) begin
          `uvm_fatal("RAND_FAIL", "Stream 3 randomization failed")
        end
        finish_item(tx);
      end

      // Stream 4: Uses ID = 0x1 (Matches ID from Stream 1, forcing sequential checks on identical tags)
      begin
        axi5_xtn #(AW, DW, IW) tx = axi5_xtn #(AW, DW, IW)::type_id::create("tx_s4");
        start_item(tx);
        if (!tx.randomize() with { id == 4'h1; xact_type == READ; addr == 64'h8000; }) begin
          `uvm_fatal("RAND_FAIL", "Stream 4 randomization failed")
        end
        finish_item(tx);
      end
    join

    `uvm_info(get_type_name(), "Interleaved Out-of-Order stress transactions completed successfully.", UVM_MEDIUM)
  endtask : body

endclass : axi5_out_of_order_seq

`endif // AXI5_SEQ_LIB_SV
