`ifndef AXI_INTERFACE_SV
`define AXI_INTERFACE_SV

interface axi_if(input logic clk, input logic reset_n);
  // Write Address Channel
  logic [31:0] awaddr;
  logic        awvalid;
  logic        awready;

  // Write Data Channel
  logic [31:0] wdata;
  logic        wvalid;
  logic        wready;

  // Write Response Channel
  logic [1:0]  bresp;
  logic        bvalid;
  logic        bready;

  // Read Address Channel
  logic [31:0] araddr;
  logic        arvalid;
  logic        arready;

  // Read Data Channel
  logic [31:0] rdata;
  logic [1:0]  rresp;
  logic        rvalid;
  logic        rready;

  // 드라이버와 모니터에서 사용할 Clocking Block (타이밍 보정용)
  clocking cb @(posedge clk);
    default input #1ns output #1ns;
    output awaddr, awvalid, wdata, wvalid, araddr, arvalid, bready, rready;
    input  awready, wready, bvalid, arready, rdata, rresp, rvalid;
  endclocking

endinterface

`endif