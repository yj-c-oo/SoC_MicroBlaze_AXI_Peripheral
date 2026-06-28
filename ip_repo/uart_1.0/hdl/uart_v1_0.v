
`timescale 1 ns / 1 ps

module uart_v1_0 #(
    // Users to add parameters here
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 115_200,

    // User parameters ends
    // Do not modify the parameters beyond this line


    // Parameters of Axi Slave Bus Interface S00_AXI
    parameter integer C_S00_AXI_DATA_WIDTH = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH = 4
) (
    // Users to add ports here
    output wire tx,
    input  wire rx,
    output wire rx_intr,
    // User ports ends
    // Do not modify the ports beyond this line


    // Ports of Axi Slave Bus Interface S00_AXI
    input  wire                                  s00_axi_aclk,
    input  wire                                  s00_axi_aresetn,
    input  wire [    C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
    input  wire [                         2 : 0] s00_axi_awprot,
    input  wire                                  s00_axi_awvalid,
    output wire                                  s00_axi_awready,
    input  wire [    C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
    input  wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
    input  wire                                  s00_axi_wvalid,
    output wire                                  s00_axi_wready,
    output wire [                         1 : 0] s00_axi_bresp,
    output wire                                  s00_axi_bvalid,
    input  wire                                  s00_axi_bready,
    input  wire [    C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
    input  wire [                         2 : 0] s00_axi_arprot,
    input  wire                                  s00_axi_arvalid,
    output wire                                  s00_axi_arready,
    output wire [    C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
    output wire [                         1 : 0] s00_axi_rresp,
    output wire                                  s00_axi_rvalid,
    input  wire                                  s00_axi_rready
);

    wire [7:0] tx_data;
    wire       tx_valid;
    wire       tx_ready;
    wire [7:0] rx_data;
    wire       rx_valid;
    wire       rx_ie;

    assign rx_intr = rx_valid & rx_ie;

    // Instantiation of Axi Bus Interface S00_AXI
    uart_v1_0_S00_AXI #(
        .C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
    ) uart_v1_0_S00_AXI_inst (
        .tx_data      (tx_data),
        .tx_valid     (tx_valid),
        .tx_ready     (tx_ready),
        .rx_data      (rx_data),
        .rx_valid     (rx_valid),
        .rx_ie        (rx_ie),
        .S_AXI_ACLK   (s00_axi_aclk),
        .S_AXI_ARESETN(s00_axi_aresetn),
        .S_AXI_AWADDR (s00_axi_awaddr),
        .S_AXI_AWPROT (s00_axi_awprot),
        .S_AXI_AWVALID(s00_axi_awvalid),
        .S_AXI_AWREADY(s00_axi_awready),
        .S_AXI_WDATA  (s00_axi_wdata),
        .S_AXI_WSTRB  (s00_axi_wstrb),
        .S_AXI_WVALID (s00_axi_wvalid),
        .S_AXI_WREADY (s00_axi_wready),
        .S_AXI_BRESP  (s00_axi_bresp),
        .S_AXI_BVALID (s00_axi_bvalid),
        .S_AXI_BREADY (s00_axi_bready),
        .S_AXI_ARADDR (s00_axi_araddr),
        .S_AXI_ARPROT (s00_axi_arprot),
        .S_AXI_ARVALID(s00_axi_arvalid),
        .S_AXI_ARREADY(s00_axi_arready),
        .S_AXI_RDATA  (s00_axi_rdata),
        .S_AXI_RRESP  (s00_axi_rresp),
        .S_AXI_RVALID (s00_axi_rvalid),
        .S_AXI_RREADY (s00_axi_rready)
    );

    // Add user logic here
    uart_top #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_uart (
        .clk     (s00_axi_aclk),
        .rst_n   (s00_axi_aresetn),
        .tx_data (tx_data),
        .tx_valid(tx_valid),
        .tx_ready(tx_ready),
        .tx      (tx),
        .rx      (rx),
        .rx_data (rx_data),
        .rx_valid(rx_valid)
    );

    // User logic ends

endmodule



// UART �ֻ��� ���: TX�� RX ����� ������ �ܼ� ����.
// �⺻ ����: 100 MHz Ŭ��, 115200 baud, 8N1 ����

module uart_top #(
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 115_200
) (
    input  wire       clk,
    input  wire       rst_n,
    // TX �������̽�
    input  wire [7:0] tx_data,
    input  wire       tx_valid,
    output wire       tx_ready,
    output wire       tx,
    // RX �������̽�
    input  wire       rx,
    output wire [7:0] rx_data,
    output wire       rx_valid
);

    uart_tx #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_tx (
        .clk    (clk),
        .rst_n  (rst_n),
        .data_in(tx_data),
        .valid  (tx_valid),
        .ready  (tx_ready),
        .tx     (tx)
    );

    uart_rx #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_rx (
        .clk     (clk),
        .rst_n   (rst_n),
        .rx      (rx),
        .data_out(rx_data),
        .valid   (rx_valid)
    );

endmodule



// UART ���ű� (8N1: ������ 8��Ʈ, �и�Ƽ ����, ������Ʈ 1��Ʈ)

module uart_rx #(
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 115_200
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rx,        // ���� �Է� ����
    output reg  [7:0] data_out,  // ���ŵ� ����Ʈ
    output reg        valid      // ���� �Ϸ� �޽� (1Ŭ�� high)
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam HALF_BIT = CLKS_PER_BIT / 2;

    // ���� FSM ����
    localparam S_IDLE = 2'd0;  // ��� (rx falling edge ����)
    localparam S_START = 2'd1;  // ���ۺ�Ʈ �߾ӱ��� ��� �� ��Ȯ��
    localparam S_DATA = 2'd2;  // ������ 8��Ʈ ���ø�
    localparam S_STOP = 2'd3;  // ������Ʈ ���

    reg [                   1:0] state;
    reg [$clog2(CLKS_PER_BIT):0] clk_cnt;
    reg [                   2:0] bit_idx;
    reg [                   7:0] shift_reg;

    // rx�� clk ���������� �������� 2�� ����ȭ�� (��Ÿ���º���Ƽ ����)
    reg rx_sync0, rx_sync;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_sync0 <= 1'b1;
            rx_sync  <= 1'b1;
        end else begin
            rx_sync0 <= rx;
            rx_sync  <= rx_sync0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= S_IDLE;
            clk_cnt   <= 0;
            bit_idx   <= 0;
            shift_reg <= 8'h00;
            data_out  <= 8'h00;
            valid     <= 1'b0;
        end else begin
            valid <= 1'b0;  // �⺻��: ��Ʈ

            case (state)
                S_IDLE: begin
                    clk_cnt <= 0;
                    bit_idx <= 0;
                    if (rx_sync == 1'b0)  // falling edge �� ���ۺ�Ʈ �ĺ�
                        state <= S_START;
                end

                // ���ۺ�Ʈ �߾� �������� ���
                S_START: begin
                    if (clk_cnt == HALF_BIT - 1) begin
                        clk_cnt <= 0;
                        if (rx_sync == 1'b0)  // ������ low �� ��ȿ�� ���ۺ�Ʈ
                            state <= S_DATA;
                        else state <= S_IDLE;  // ������� �Ǵ�, ���
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end

                // �� ��Ʈ ���̸��� ��Ʈ �߾ӿ��� ���ø�
                S_DATA: begin
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt            <= 0;
                        shift_reg[bit_idx] <= rx_sync;  // LSB���� ä��
                        if (bit_idx == 3'd7) begin
                            state <= S_STOP;
                        end else begin
                            bit_idx <= bit_idx + 1;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end

                // ������Ʈ �� ��Ʈ ���� ��� �� ������ ���
                S_STOP: begin
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt  <= 0;
                        data_out <= shift_reg;
                        valid    <= 1'b1; // 1Ŭ�� �޽�
                        state    <= S_IDLE;
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule


// UART �۽ű� (8N1: ������ 8��Ʈ, �и�Ƽ ����, ������Ʈ 1��Ʈ)

module uart_tx #(
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 115_200
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] data_in,  // �۽��� ����Ʈ
    input  wire       valid,    // ���� ���� �޽� (1Ŭ�� high)
    output reg        ready,    // idle ���� (���� ������ ���� ����)
    output reg        tx        // ���� ��� ����
);

    // �� ��Ʈ ���� ī��Ʈ�ؾ� �ϴ� Ŭ�� ��
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    // �۽� FSM ����
    localparam S_IDLE = 2'd0;  // ���
    localparam S_START = 2'd1;  // ���ۺ�Ʈ(0) ���
    localparam S_DATA = 2'd2;  // ������ 8��Ʈ ���
    localparam S_STOP = 2'd3;  // ������Ʈ(1) ���

    reg [                   1:0] state;
    reg [$clog2(CLKS_PER_BIT):0] clk_cnt;  // ��Ʈ ���� ī����
    reg [                   2:0] bit_idx;  // ���� �۽� ���� ��Ʈ �ε���
    reg [                   7:0] shift_reg;  // �۽� ������ ����

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= S_IDLE;
            clk_cnt   <= 0;
            bit_idx   <= 0;
            shift_reg <= 8'h00;
            tx        <= 1'b1;  // idle ���¿��� ������ high
            ready     <= 1'b1;
        end else begin
            case (state)
                S_IDLE: begin
                    tx    <= 1'b1;
                    ready <= 1'b1;
                    if (valid) begin
                        // ������ ĸó �� ���ۺ�Ʈ�� ����
                        shift_reg <= data_in;
                        clk_cnt   <= 0;
                        ready     <= 1'b0;
                        state     <= S_START;
                    end
                end

                S_START: begin
                    tx <= 1'b0;  // ���ۺ�Ʈ
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= 0;
                        bit_idx <= 0;
                        state   <= S_DATA;
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end

                S_DATA: begin
                    tx <= shift_reg[bit_idx];  // LSB���� ���ʷ� ����
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= 0;
                        if (bit_idx == 3'd7) begin
                            state <= S_STOP;
                        end else begin
                            bit_idx <= bit_idx + 1;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end

                S_STOP: begin
                    tx <= 1'b1;  // ������Ʈ
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= 0;
                        state   <= S_IDLE;
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
