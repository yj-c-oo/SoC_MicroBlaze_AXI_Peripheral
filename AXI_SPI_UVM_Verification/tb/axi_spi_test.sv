`ifndef AXI_SPI_TEST_SV
`define AXI_SPI_TEST_SV

class axi_spi_test extends uvm_test;
  `uvm_component_utils(axi_spi_test)

  // 최상위 환경(Environment) 선언
  axi_spi_env m_env;

  function new(string name = "axi_spi_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // 1. Build Phase: 환경 객체 생성
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_env = axi_spi_env::type_id::create("m_env", this);
    
    // 필요시 여기서 시퀀서에 대한 설정이나 특정 컴포넌트 Override 가능
  endfunction

  // 2. End of Elaboration: 구조가 잘 잡혔는지 확인 (선택 사항)
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology(); // 시뮬레이션 로그에 UVM 계층 구조 출력
  endfunction

  // 3. Run Phase: 실제 시나리오 실행
  virtual task run_phase(uvm_phase phase);
    // 가상 시퀀스 선언 및 생성
    axi_spi_virtual_sequence vseq;
    vseq = axi_spi_virtual_sequence::type_id::create("vseq");

    // 시뮬레이션 종료 방지 (Raise Objection)
    phase.raise_objection(this);

    `uvm_info("TEST", "시뮬레이션 시작: AXI-SPI Virtual Sequence 실행", UVM_LOW)

    // 가상 시퀀스를 가상 시퀀서 위에서 실행
    if (!vseq.randomize()) `uvm_error("TEST", "VSEQ Randomization Failed")
    vseq.start(m_env.m_vsqr);

    // 시나리오 종료 후 약간의 여유 시간을 주고 시뮬레이션 끝내기
    #100ns;
    
    `uvm_info("TEST", "시뮬레이션 종료: 모든 시퀀스 완료", UVM_LOW)

    // 시뮬레이션 종료 허용 (Drop Objection)
    phase.drop_objection(this);
  endtask

endclass

`endif