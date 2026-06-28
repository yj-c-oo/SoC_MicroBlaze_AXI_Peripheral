`timescale 1ns / 1ps

// 모든 UVM 라이브러리와 우리가 만든 파일들을 포함
import uvm_pkg::*;
`include "uvm_macros.svh"

// 앞서 만든 파일들을 모두 include
`include "axi_interface.sv"
`include "spi_interface.sv"
`include "axi_seq_item.sv"
`include "spi_seq_item.sv"
`include "axi_sequence.sv"
`include "spi_sequence.sv"
`include "axi_driver.sv"
`include "spi_driver.sv"
`include "axi_monitor.sv"
`include "spi_monitor.sv"
`include "axi_agent.sv"
`include "spi_agent.sv"
`include "axi_spi_scoreboard.sv"
`include "axi_spi_coverage.sv"
`include "axi_spi_env.sv"
`include "axi_spi_virtual_sequence.sv"
`include "axi_spi_test.sv"

module tb_axi_spi;

    // 1. 클럭 및 리셋 신호 생성
    logic clk;
    logic reset_n;

    initial begin
        clk = 0;
        forever #5ns clk = ~clk;
    end

    initial begin
        reset_n = 0;
        #100ns reset_n = 1;
    end

    // 2. 인터페이스 인스턴스 생성
    axi_if a_if (clk, reset_n);
    spi_if s_if ();

    //  SPI 신호 초기화
    // 초기값이 'X'(Unknown)이면 드라이버가 신호 변화를 감지하지 못하고 멈출 수 있습니다.
    initial begin
        s_if.miso = 1'b0; 
    end

    // 3. DUT(설계한 IP) 인스턴스화 및 핀 연결
    SPI_v1_0 dut (
        .s00_axi_aclk(clk),
        .s00_axi_aresetn(reset_n),
        .s00_axi_awaddr(a_if.awaddr),
        .s00_axi_awprot(3'b000),    // [추가] 보호 신호 (기본값 0)
        .s00_axi_awvalid(a_if.awvalid),
        .s00_axi_awready(a_if.awready),
        .s00_axi_wdata(a_if.wdata),
        .s00_axi_wvalid(a_if.wvalid),
        .s00_axi_wready(a_if.wready),
        .s00_axi_araddr(a_if.araddr),
        .s00_axi_arprot(3'b000),    // [추가] 보호 신호 (기본값 0)
        .s00_axi_arvalid(a_if.arvalid),
        .s00_axi_arready(a_if.arready),
        .s00_axi_rdata(a_if.rdata),
        .s00_axi_rvalid(a_if.rvalid),
        .s00_axi_rready(a_if.rready),
        .s00_axi_wstrb(4'hf),
        .s00_axi_bresp(a_if.bresp),
        .s00_axi_bvalid(a_if.bvalid),
        .s00_axi_bready(a_if.bready),
        .s00_axi_rresp(a_if.rresp),
        
        .sclk(s_if.sclk),
        .mosi(s_if.mosi),
        .miso(s_if.miso),
        .cs_n(s_if.ss_n) // RTL의 cs_n과 인터페이스의 ss_n 연결
    );

    // 4. UVM 설정 및 테스트 시작
    initial begin
        uvm_config_db#(virtual axi_if)::set(null, "*", "vif", a_if);
        uvm_config_db#(virtual spi_if)::set(null, "*", "vif", s_if);

        uvm_top.set_report_verbosity_level(UVM_LOW);
        run_test("axi_spi_test");
    end

    // 5. 파형 저장 (VCS/Verdi용 fsdb 추가)
    initial begin
        // 일반 VCD 파일
        $dumpfile("simulation.vcd");
        $dumpvars(0, tb_axi_spi);
        
        // [추가] Verdi 사용 시 fsdb를 뽑아야 '멈춤' 현상을 디버깅하기 훨씬 편합니다.
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpvars(0, tb_axi_spi);
    end

endmodule