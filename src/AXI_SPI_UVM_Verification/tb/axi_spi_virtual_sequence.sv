`ifndef AXI_SPI_VIRTUAL_SEQ_SV
`define AXI_SPI_VIRTUAL_SEQ_SV

class axi_spi_virtual_sequence extends uvm_sequence;
  `uvm_object_utils(axi_spi_virtual_sequence)
  `uvm_declare_p_sequencer(axi_spi_virtual_sequencer)

  int num_trans = 100;
  
  // 클래스 레벨에서 변수를 선언하여 VCS 문법 에러 원천 차단
  axi_sequence m_axi_seq;
  spi_sequence m_spi_seq;

  function new(string name = "axi_spi_virtual_sequence");
    super.new(name);
  endfunction

  virtual task body();
    // 태스크 최상단에서 사용할 변수 선언
    logic [7:0] rand_data;

    // [1] IP 초기 설정 (clk_div=2)
    m_axi_seq = axi_sequence::type_id::create("m_axi_seq");
    m_axi_seq.addr = 32'h0;
    m_axi_seq.wdata = 32'h0200;
    m_axi_seq.we = 1;
    m_axi_seq.start(p_sequencer.p_axi_sqr);

    repeat(num_trans) begin
      rand_data = $urandom_range(0, 255);

      fork
        // [2] SPI Slave 응답 준비
        begin
          m_spi_seq = spi_sequence::type_id::create("m_spi_seq");
          if(!m_spi_seq.randomize()) `uvm_error("VSEQ", "SPI Rand Fail")
          m_spi_seq.start(p_sequencer.p_spi_sqr);
        end
        
        // [3] Master 전송 (Start ON -> 즉시 OFF)
        begin
          #10ns;
          // Start 비트(8번)를 1로 하여 전송 시작
          m_axi_seq = axi_sequence::type_id::create("m_axi_seq");
          m_axi_seq.addr = 32'h4; 
          m_axi_seq.wdata = {23'd0, 1'b1, rand_data}; 
          m_axi_seq.we = 1;
          m_axi_seq.start(p_sequencer.p_axi_sqr);
          
          // 전송 시작 직후 Start 비트를 0으로 클리어 (무한 루프 방지)
          m_axi_seq = axi_sequence::type_id::create("m_axi_seq");
          m_axi_seq.addr = 32'h4; 
          m_axi_seq.wdata = 32'h0;                    
          m_axi_seq.we = 1;
          m_axi_seq.start(p_sequencer.p_axi_sqr);
        end
      join

      // [4] 하드웨어 SPI 전송 완료 넉넉히 대기
      #2us;

      //  [5] 읽기 동작 수행 (스코어보드 MISO 채점 트리거!)
      m_axi_seq = axi_sequence::type_id::create("m_axi_seq");
      m_axi_seq.addr = 32'hC; 
      m_axi_seq.we = 0; 
      m_axi_seq.start(p_sequencer.p_axi_sqr); // Status 읽기

      m_axi_seq = axi_sequence::type_id::create("m_axi_seq");
      m_axi_seq.addr = 32'h8; 
      m_axi_seq.we = 0; 
      m_axi_seq.start(p_sequencer.p_axi_sqr); // RX Data 읽기

      // [6] CTRL / TX Read-back (cross_addr_we 100% + 읽기 mux 경로 검증)
      m_axi_seq = axi_sequence::type_id::create("m_axi_seq");
      m_axi_seq.addr = 32'h0;
      m_axi_seq.we = 0;
      m_axi_seq.start(p_sequencer.p_axi_sqr); // CTRL 읽기

      m_axi_seq = axi_sequence::type_id::create("m_axi_seq");
      m_axi_seq.addr = 32'h4;
      m_axi_seq.we = 0;
      m_axi_seq.start(p_sequencer.p_axi_sqr); // TX 읽기
    end
  endtask
endclass

`endif