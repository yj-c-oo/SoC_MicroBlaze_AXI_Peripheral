`ifndef AXI_SEQUENCE_SV
`define AXI_SEQUENCE_SV

class axi_sequence extends uvm_sequence #(axi_seq_item);
  `uvm_object_utils(axi_sequence)

  // 외부(Virtual Sequence)에서 값을 세팅할 수 있도록 변수 선언
  rand bit [31:0] addr;
  rand bit [31:0] wdata;
  rand bit        we;

  function new(string name = "axi_sequence"); 
    super.new(name);
  endfunction

  virtual task body();
    req = axi_seq_item::type_id::create("req");
    start_item(req);
    
    // 할당받은 값을 실제 Item에 전달
    req.addr  = addr;
    req.wdata = wdata;
    req.we    = we;
    
    finish_item(req);
  endtask
endclass

`endif