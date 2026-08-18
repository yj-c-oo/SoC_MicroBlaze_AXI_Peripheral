class axi_monitor extends uvm_monitor;
  `uvm_component_utils(axi_monitor)

  virtual axi_if vif;
  // 스코어보드로 데이터를 보내기 위한 분석 포트 (Analysis Port)
  uvm_analysis_port #(axi_seq_item) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF", "AXI 모니터에 인터페이스가 설정되지 않았습니다.")
  endfunction

  virtual task run_phase(uvm_phase phase);
    axi_seq_item tr;

    forever begin
      tr = axi_seq_item::type_id::create("tr");

      @(posedge vif.clk);
      if (vif.reset_n) begin
        // Case 1: Write Address & Data 감시
        if (vif.awvalid && vif.awready) begin
          tr.addr = vif.awaddr;
          tr.we = 1;
          wait(vif.wvalid && vif.wready);
          tr.wdata = vif.wdata;
          ap.write(tr); // 스코어보드로 전송
          `uvm_info("AXI_MON", $sformatf("Write 감지: Addr=0x%0h, Data=0x%0h", tr.addr, tr.wdata), UVM_LOW)
        end
        
        // Case 2: Read Address & Data 감시
        else if (vif.arvalid && vif.arready) begin
          tr.addr = vif.araddr;
          tr.we = 0;
          wait(vif.rvalid && vif.rready);
          tr.rdata = vif.rdata;
          ap.write(tr); // 스코어보드로 전송
          `uvm_info("AXI_MON", $sformatf("Read 감지: Addr=0x%0h, Data=0x%0h", tr.addr, tr.rdata), UVM_LOW)
        end
      end
    end
  endtask
endclass