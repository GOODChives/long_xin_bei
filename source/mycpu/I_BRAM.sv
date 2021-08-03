/**
 * In verilator, use the behavioral model.
 * Otherwise XPM_MEMORY_TDPRAM will be enabled.
 *
 * NOTE: the "reset" signal does not reset the entire memory,
 *       it just reset the output to `RESET_VALUE`.
 *       the behavioral model may be more strict on read/write
 *       collisions when "WRITE_MODE" is "read_first".
 *
 * Default configuration: 4KB / 32bit width / write-first
 */

// verilator lint_off VARHIDDEN
module I_BRAM #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 10,

    parameter `STRING RESET_VALUE = "00000000",
    parameter `STRING WRITE_MODE  = "write_first",

    localparam int MEM_NUM_WORDS  = 2**ADDR_WIDTH,
    localparam int BYTES_PER_WORD = DATA_WIDTH / 8,
    localparam int MEM_NUM_BYTES  = MEM_NUM_WORDS * BYTES_PER_WORD,
    localparam int MEM_NUM_BITS   = MEM_NUM_WORDS * DATA_WIDTH,

    localparam type addr_t  = logic [ADDR_WIDTH - 1:0],
    localparam type wrten_t = logic [BYTES_PER_WORD - 1:0],
    localparam type word_t  = logic [DATA_WIDTH - 1:0],
    localparam type view_t  = union packed {
        byte_t [BYTES_PER_WORD - 1:0] bytes;
        word_t word;
    }
) (
    input logic clk, reset,

    // port 1
    input  logic   en_1,
    input  logic   write_en_1,
    //input  wrten_t write_en_1,
    input  addr_t  addr_1,
    input  word_t  data_in_1,
    output word_t  data_out_1,

    // port 2
    input  logic   en_2,
    input  logic   write_en_2,
    //input  wrten_t write_en_2,
    input  addr_t  addr_2,
    input  word_t  data_in_2,
    output word_t  data_out_2
);

    // xpm_memory_tdpram: True Dual Port RAM
    // Xilinx Parameterized Macro, version 2019.2
    xpm_memory_tdpram #(
        .ADDR_WIDTH_A(ADDR_WIDTH),
        .ADDR_WIDTH_B(ADDR_WIDTH),
        .AUTO_SLEEP_TIME(0),
        .BYTE_WRITE_WIDTH_A(8),  // byte-write enable
        .BYTE_WRITE_WIDTH_B(8),
        .CASCADE_HEIGHT(0),
        .CLOCKING_MODE("common_clock"),
        .ECC_MODE("no_ecc"),
        .MEMORY_INIT_FILE("none"),
        .MEMORY_INIT_PARAM("0"),
        .MEMORY_OPTIMIZATION("true"),
        .MEMORY_PRIMITIVE("block"),  // expect BRAM
        .MEMORY_SIZE(MEM_NUM_BITS),  // in bits
        .MESSAGE_CONTROL(0),  // disable message reporting
        .READ_DATA_WIDTH_A(DATA_WIDTH),
        .READ_DATA_WIDTH_B(DATA_WIDTH),
        .READ_LATENCY_A(1),
        .READ_LATENCY_B(1),
        .READ_RESET_VALUE_A(RESET_VALUE),
        .READ_RESET_VALUE_B(RESET_VALUE),
        .RST_MODE_A("SYNC"),
        .RST_MODE_B("SYNC"),
        .SIM_ASSERT_CHK(1),
        .USE_EMBEDDED_CONSTRAINT(0),
        .USE_MEM_INIT(1),
        .WAKEUP_TIME("disable_sleep"),
        .WRITE_DATA_WIDTH_A(DATA_WIDTH),
        .WRITE_DATA_WIDTH_B(DATA_WIDTH),
        .WRITE_MODE_A(WRITE_MODE),
        .WRITE_MODE_B(WRITE_MODE)
    ) xpm_memory_tdpram_inst (
        .sleep(0),
        .clka(clk), .clkb(clk),
        .ena(en_1), .enb(en_2),
        .rsta(reset), .rstb(reset),
        .regcea(1), .regceb(1),
        .injectdbiterra(0),
        .injectdbiterrb(0),
        .injectsbiterra(0),
        .injectsbiterrb(0),

        // port 1/a
        .wea(write_en_1),
        .addra(addr_1),
        .dina(data_in_1),
        .douta(data_out_1),

        // port 2/b
        .web(write_en_2),
        .addrb(addr_2),
        .dinb(data_in_2),
        .doutb(data_out_2)
    );
    // End of xpm_memory_tdpram_inst instantiation

endmodule