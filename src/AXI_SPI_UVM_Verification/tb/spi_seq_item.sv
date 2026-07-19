`ifndef SPI_SEQ_ITEM_SV
`define SPI_SEQ_ITEM_SV

class spi_seq_item extends uvm_sequence_item;
  `uvm_object_utils(spi_seq_item)

  // 마스터가 보낸 데이터 (모니터가 수집)
  bit [7:0] mosi_data;

  // 슬레이브가 대답할 데이터 (시퀀스에서 랜덤하게 생성하여 드라이버가 MISO에 실어줌)
  rand bit [7:0] miso_data;

  function new(string name = "spi_seq_item");
    super.new(name);
  endfunction

  virtual function string convert2string();
    return $sformatf("SPI TR - MOSI: 0x%0h, MISO: 0x%0h", mosi_data, miso_data);
  endfunction

endclass

`endif