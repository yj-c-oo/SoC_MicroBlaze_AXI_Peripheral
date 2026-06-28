`ifndef SPI_INTERFACE_SV
`define SPI_INTERFACE_SV

interface spi_if();
  logic sclk;
  logic mosi;
  logic miso;
  logic ss_n;

  // SPI는 클럭이 DUT에서 나오므로 별도의 clk 입력을 받지 않고 sclk를 기준으로 모니터링합니다.
  clocking cb @(posedge sclk);
    default input #1ns output #1ns;
    input  mosi, ss_n;
    output miso;
  endclocking

endinterface

`endif