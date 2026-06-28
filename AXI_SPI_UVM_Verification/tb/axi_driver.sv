class axi_driver extends uvm_driver #(axi_seq_item);
  `uvm_component_utils(axi_driver)

  // 가상 인터페이스 연결 (Virtual Interface)
  virtual axi_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // 연결 단계에서 인터페이스 받아오기
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF", "AXI 드라이버에 인터페이스가 설정되지 않았습니다.")
  endfunction

  virtual task run_phase(uvm_phase phase);
    // 초기화
    vif.awvalid <= 0;
    vif.wvalid  <= 0;
    vif.arvalid <= 0;
    wait(vif.reset_n); // 리셋 해제 대기

    forever begin
      seq_item_port.get_next_item(req); // 시퀀스에서 아이템 받기
      drive_transfer(req);             // 물리 신호로 주입
      seq_item_port.item_done();       // 완료 보고
    end
  endtask

  // AXI4-Lite 프로토콜 주입 로직
  task drive_transfer(axi_seq_item tr);
    @(posedge vif.clk);
    if (tr.we) begin // Write 동작
      vif.awaddr  <= tr.addr;
      vif.wdata   <= tr.wdata;
      vif.awvalid <= 1;
      vif.wvalid  <= 1;
      vif.bready  <= 1; // [추가] 응답 준비 완료 상태 유지
      
      // AWREADY와 WREADY가 모두 올 때까지 대기 (Handshake)
      wait(vif.awready && vif.wready);
      @(posedge vif.clk);
      vif.awvalid <= 0;
      vif.wvalid  <= 0;

      wait(vif.bvalid); 
    @(posedge vif.clk);
    vif.bready  <= 0;
    end 
    else begin // Read 동작
      vif.araddr  <= tr.addr;
      vif.arvalid <= 1;
      vif.rready  <= 1; // [추가] 읽기 데이터 받을 준비
      
      wait(vif.arready);
      @(posedge vif.clk);
      vif.arvalid <= 0;
      
      wait(vif.rvalid); // DUT가 데이터를 줄 때까지 대기
      tr.rdata = vif.rdata; // 읽은 데이터 보관
    end
  endtask
endclass