`ifndef SPI_AGENT_SV
`define SPI_AGENT_SV

typedef uvm_sequencer #(spi_seq_item) spi_sequencer;

class spi_agent extends uvm_agent;
  `uvm_component_utils(spi_agent)

  spi_sequencer m_sqr;
  spi_driver    m_drv;
  spi_monitor   m_mon;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    m_mon = spi_monitor::type_id::create("m_mon", this);

    if (get_is_active() == UVM_ACTIVE) begin
      m_sqr = spi_sequencer::type_id::create("m_sqr", this);
      m_drv = spi_driver::type_id::create("m_drv", this);
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    if (get_is_active() == UVM_ACTIVE) begin
      m_drv.seq_item_port.connect(m_sqr.seq_item_export);
    end
  endfunction

endclass

`endif