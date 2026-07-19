class spi_monitor extends uvm_monitor;
  `uvm_component_utils(spi_monitor)

  virtual spi_if vif;
  uvm_analysis_port #(spi_seq_item) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual spi_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF", "SPI 모니터에 인터페이스가 설정되지 않았습니다.")
  endfunction

  virtual task run_phase(uvm_phase phase);
    spi_seq_item tr;

    forever begin
      // SS_N이 0이 될 때까지 대기 (통신 시작 지점)
      wait(vif.ss_n == 0);
      tr = spi_seq_item::type_id::create("tr");

      for (int i = 7; i >= 0; i--) begin
        // SPI Mode 0 기준: Rising Edge에서 데이터 샘플링
        @(posedge vif.sclk);
        tr.mosi_data[i] = vif.mosi;
        tr.miso_data[i] = vif.miso;
      end

      // 8비트가 다 모이면 스코어보드로 전송
      ap.write(tr);
      `uvm_info("SPI_MON", $sformatf("SPI 통신 포착: MOSI=0x%0h, MISO=0x%0h", tr.mosi_data, tr.miso_data), UVM_LOW)

      // SS_N이 다시 1이 될 때까지 대기 (통신 종료 지점)
      wait(vif.ss_n == 1);
    end
  endtask
endclass