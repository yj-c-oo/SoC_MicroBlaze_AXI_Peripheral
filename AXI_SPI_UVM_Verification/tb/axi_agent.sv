`ifndef AXI_AGENT_SV
`define AXI_AGENT_SV

// 시퀀서 파일을 따로 만들지 않고 여기서 정의 (typedef 방식)
typedef uvm_sequencer #(axi_seq_item) axi_sequencer;

class axi_agent extends uvm_agent;
  `uvm_component_utils(axi_agent)

  // 구성 요소 선언
  axi_sequencer m_sqr;
  axi_driver    m_drv;
  axi_monitor   m_mon;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // 1. Build Phase: 각 구성 요소 생성
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // 모니터는 항상 생성
    m_mon = axi_monitor::type_id::create("m_mon", this);

    // Active 에이전트일 때만 드라이버와 시퀀서 생성
    if (get_is_active() == UVM_ACTIVE) begin
      m_sqr = axi_sequencer::type_id::create("m_sqr", this);
      m_drv = axi_driver::type_id::create("m_drv", this);
    end
  endfunction

  // 2. Connect Phase: 드라이버와 시퀀서 연결
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    if (get_is_active() == UVM_ACTIVE) begin
      // 드라이버의 포트를 시퀀서의 엑스포트에 연결 
      m_drv.seq_item_port.connect(m_sqr.seq_item_export);
    end
  endfunction

endclass

`endif