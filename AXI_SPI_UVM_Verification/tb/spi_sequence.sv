`ifndef SPI_SEQUENCE_SV
`define SPI_SEQUENCE_SV

class spi_sequence extends uvm_sequence #(spi_seq_item);
  `uvm_object_utils(spi_sequence)

  // 슬레이브가 마스터에게 보낼 응답 데이터
  rand bit [7:0] miso_data;

  function new(string name = "spi_sequence");
    super.new(name);
  endfunction

  virtual task body();
    req = spi_seq_item::type_id::create("req");

    start_item(req);

    // 시퀀스에서 설정한 miso_data 값을 아이템에 할당
    if (!req.randomize() with { 
        miso_data == local::miso_data; 
    }) begin
        `uvm_error("SPI_SEQ", "Randomization failed")
    end

    finish_item(req);
  endtask

endclass

`endif