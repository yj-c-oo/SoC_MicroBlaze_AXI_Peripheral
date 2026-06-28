`ifndef AXI_SPI_COVERAGE_SV
`define AXI_SPI_COVERAGE_SV

class axi_spi_coverage extends uvm_component;
  `uvm_component_utils(axi_spi_coverage)

  uvm_analysis_imp_axi #(axi_seq_item, axi_spi_coverage) axi_export;
  uvm_analysis_imp_spi #(spi_seq_item, axi_spi_coverage) spi_export;

  axi_seq_item m_axi_item;
  spi_seq_item m_spi_item;

  covergroup axi_cg;
    option.per_instance = 1;
    option.name = "AXI_Access_Coverage";

    // 주소 커버리지: 주요 레지스터 확인
    cp_addr: coverpoint m_axi_item.addr {
      bins tx_reg     = {32'h0000_0004};
      bins rx_reg     = {32'h0000_0008};
      bins ctrl_reg   = {32'h0000_0000};
      bins status_reg = {32'h0000_000C};
    }

    // 읽기/쓰기 커버리지
    cp_we: coverpoint m_axi_item.we {
      bins write = {1};
      bins read  = {0};
    }

    // AXI 쓰기 데이터: 전체 범위(0x00~0xFF)를 4구간으로 균등 분할
    cp_wdata: coverpoint m_axi_item.wdata[7:0] iff (m_axi_item.we && m_axi_item.addr == 32'h0000_0004 && m_axi_item.wdata[8] == 1'b1) {
      bins data_range[4] = {[8'h00:8'hFF]};
    }

    // 크로스 커버리지
    cross_addr_we: cross cp_addr, cp_we {
      ignore_bins ro_write = binsof(cp_addr) intersect {32'h0000_0008, 32'h0000_000C} && binsof(cp_we) intersect {1};
    }
  endgroup

  covergroup spi_cg;
    option.per_instance = 1;
    option.name = "SPI_Data_Coverage";

    // SPI 데이터: 전체 범위(0x00~0xFF)를 4구간으로 균등 분할
    cp_mosi: coverpoint m_spi_item.mosi_data {
      bins data_range[4] = {[8'h00:8'hFF]};
    }
    cp_miso: coverpoint m_spi_item.miso_data {
      bins data_range[4] = {[8'h00:8'hFF]};
    }
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    axi_export = new("axi_export", this);
    spi_export = new("spi_export", this);
    axi_cg = new();
    spi_cg = new();
  endfunction

  virtual function void write_axi(axi_seq_item tr);
    m_axi_item = tr;
    axi_cg.sample();
  endfunction

  virtual function void write_spi(spi_seq_item tr);
    m_spi_item = tr;
    spi_cg.sample();
  endfunction

endclass

`endif