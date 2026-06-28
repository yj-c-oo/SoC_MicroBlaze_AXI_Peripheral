`ifndef AXI_SPI_SCOREBOARD_SV
`define AXI_SPI_SCOREBOARD_SV

`uvm_analysis_imp_decl(_axi)
`uvm_analysis_imp_decl(_spi)

class axi_spi_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axi_spi_scoreboard)

  uvm_analysis_imp_axi #(axi_seq_item, axi_spi_scoreboard) axi_export;
  uvm_analysis_imp_spi #(spi_seq_item, axi_spi_scoreboard) spi_export;

  logic [7:0] expected_mosi_q[$];
  logic [7:0] expected_miso_q[$];

  int pass_cnt = 0;
  int fail_cnt = 0;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    axi_export = new("axi_export", this);
    spi_export = new("spi_export", this);
  endfunction

  // 1. AXI Monitor
  virtual function void write_axi(axi_seq_item tr);
    if (tr.we) begin
      if (tr.addr == 32'h0000_0004 && tr.wdata[8] == 1'b1) begin
        expected_mosi_q.push_back(tr.wdata[7:0]);
      end
    end
    else begin
      if (tr.addr == 32'h0000_0008) begin
        if (expected_miso_q.size() > 0) begin
          logic [7:0] exp_miso = expected_miso_q.pop_front();
          if (tr.rdata[7:0] === exp_miso) begin
            pass_cnt++;
            `uvm_info("SCB", $sformatf("PASS: MISO Match (AXI_RDATA=0x%0h, SPI_MISO=0x%0h)", tr.rdata[7:0], exp_miso), UVM_LOW)
          end else begin
            fail_cnt++;
            `uvm_error("SCB", $sformatf("FAIL: MISO Mismatch! EXP:0x%0h, ACT:0x%0h", exp_miso, tr.rdata[7:0]))
          end
        end else begin
          fail_cnt++;
          `uvm_error("SCB", "FAIL: MISO Queue Empty on AXI Read")
        end
      end
    end
  endfunction

  // 2. SPI Monitor
  virtual function void write_spi(spi_seq_item tr);
    if (expected_mosi_q.size() > 0) begin
      logic [7:0] exp_mosi = expected_mosi_q.pop_front();
      if (tr.mosi_data === exp_mosi) begin
        pass_cnt++;
        `uvm_info("SCB", $sformatf("PASS: MOSI Match (0x%0h)", tr.mosi_data), UVM_LOW)
      end else begin
        fail_cnt++;
        `uvm_error("SCB", $sformatf("FAIL: MOSI Mismatch! EXP:0x%0h, ACT:0x%0h", exp_mosi, tr.mosi_data))
      end
    end else begin
      fail_cnt++;
      `uvm_error("SCB", $sformatf("FAIL: Unexpected SPI Transaction (MOSI: 0x%0h)", tr.mosi_data))
    end
    
    expected_miso_q.push_back(tr.miso_data);
  endfunction

  // 3. Final Report
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SCB_RESULT", "\n==================================================", UVM_NONE)
    `uvm_info("SCB_RESULT", " [SCOREBOARD FINAL REPORT]", UVM_NONE)
    `uvm_info("SCB_RESULT", $sformatf("  - TOTAL PASS : %0d", pass_cnt), UVM_NONE)
    `uvm_info("SCB_RESULT", $sformatf("  - TOTAL FAIL : %0d", fail_cnt), UVM_NONE)
    
    if (fail_cnt == 0 && pass_cnt > 0) begin
      `uvm_info("SCB_RESULT", " [RESULT] SUCCESS! All transactions matched perfectly.", UVM_NONE)
    end else begin
      `uvm_error("SCB_RESULT", " [RESULT] FAILED! Please check the mismatched transactions.")
    end
    `uvm_info("SCB_RESULT", "==================================================\n", UVM_NONE)
  endfunction

endclass

`endif