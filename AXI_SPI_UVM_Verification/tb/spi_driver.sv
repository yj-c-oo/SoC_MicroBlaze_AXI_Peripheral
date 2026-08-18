class spi_driver extends uvm_driver #(spi_seq_item);
  `uvm_component_utils(spi_driver)

  virtual spi_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual spi_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF", "SPI 드라이버에 인터페이스가 설정되지 않았습니다.")
  endfunction

  virtual task run_phase(uvm_phase phase);
    vif.miso <= 0;

    forever begin
      seq_item_port.get_next_item(req);
      drive_spi(req);
      seq_item_port.item_done();
    end
  endtask

  task drive_spi(spi_seq_item tr);
    // SS_N(Chip Select)이 0이 될 때까지 대기 (통신 시작)
    wait(vif.ss_n == 0);

    for (int i = 7; i >= 0; i--) begin
      // SPI Mode 0 기준: Falling Edge에서 데이터 드라이브
      @(negedge vif.sclk);
      vif.miso <= tr.miso_data[i]; 
    end

    // 통신 종료 대기
    wait(vif.ss_n == 1);
  endtask
endclass