`ifndef AXI_SEQ_ITEM_SV
`define AXI_SEQ_ITEM_SV

class axi_seq_item extends uvm_sequence_item;
  // UVM 팩토리 등록
  `uvm_object_utils(axi_seq_item)

  // 랜덤 변수 정의 (시퀀스에서 결정됨)
  rand bit [31:0] addr;   // 레지스터 주소
  rand bit [31:0] wdata;  // 쓸 데이터
  rand bit        we;     // 1: Write, 0: Read

  // 수신 변수 (드라이버가 읽기 동작 후 채워줌)
  bit [31:0] rdata;       

  // 생성자
  function new(string name = "axi_seq_item");
    super.new(name);
  endfunction

  // 디버깅을 위한 데이터 출력 함수
  virtual function string convert2string();
    return $sformatf("AXI TR - Addr: 0x%0h, Data: 0x%0h, WE: %s", 
                     addr, (we ? wdata : rdata), (we ? "WR" : "RD"));
  endfunction

endclass

`endif