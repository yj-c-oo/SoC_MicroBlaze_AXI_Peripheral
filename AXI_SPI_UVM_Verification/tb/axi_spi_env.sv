`ifndef AXI_SPI_ENV_SV
`define AXI_SPI_ENV_SV

// Virtual Sequencer 정의 (파일을 따로 만들지 않고 Env 상단에 정의)
class axi_spi_virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(axi_spi_virtual_sequencer)

    // 각 에이전트의 시퀀서를 가리킬 핸들 (주소록 역할)
    axi_sequencer p_axi_sqr;
    spi_sequencer p_spi_sqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass


class axi_spi_env extends uvm_env;
    `uvm_component_utils(axi_spi_env)

    // 구성 요소 선언
    axi_agent                 m_axi_agt;
    spi_agent                 m_spi_agt;
    axi_spi_scoreboard        m_scb;
    axi_spi_coverage          m_cov;

    // 가상 시퀀서 선언
    axi_spi_virtual_sequencer m_vsqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // 1. Build Phase: 객체 생성
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        m_axi_agt = axi_agent::type_id::create("m_axi_agt", this);
        m_spi_agt = spi_agent::type_id::create("m_spi_agt", this);
        m_scb     = axi_spi_scoreboard::type_id::create("m_scb", this);
        m_cov     = axi_spi_coverage::type_id::create("m_cov", this);
        m_vsqr    = axi_spi_virtual_sequencer::type_id::create("m_vsqr", this);
    endfunction

    // 2. Connect Phase: 포트 및 시퀀서 연결
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // 모니터(Analysis Port) -> 스코어보드(Export) 연결
        m_axi_agt.m_mon.ap.connect(m_scb.axi_export);
        m_spi_agt.m_mon.ap.connect(m_scb.spi_export);

        // 모니터 -> 커버리지 연결
        m_axi_agt.m_mon.ap.connect(m_cov.axi_export);
        m_spi_agt.m_mon.ap.connect(m_cov.spi_export);

        // 가상 시퀀서가 실제 에이전트의 시퀀서를 가리키도록 연결
        m_vsqr.p_axi_sqr = m_axi_agt.m_sqr;
        m_vsqr.p_spi_sqr = m_spi_agt.m_sqr;
    endfunction

endclass

`endif
