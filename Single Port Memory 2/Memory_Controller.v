module Memory_Controller #(
    parameter DATA_WIDTH = 8,        // Width of the data bus
    parameter ADDR_WIDTH = 8         // Width of the address bus
) (
    // Clock and Reset
    input i_clk,                          // Clock input
    input i_reset_n,                      // Active-low reset signal
    
    // Primary interface signals
    input i_wr_en,                        // Write enable signal for primary interface
    input i_rd_en,                        // Read enable signal for primary interface
    input [ADDR_WIDTH-1:0] i_address,     // Address for memory operation
    input [DATA_WIDTH-1:0] i_wr_data,     // Data to be written to memory
    output reg [DATA_WIDTH-1:0] o_rd_data, // Data read from memory

    // Secondary interface signals
    output reg o_wr_en,                  // Write enable signal for secondary interface
    output reg o_rd_en,                  // Read enable signal for secondary interface
    output reg [ADDR_WIDTH-1:0] o_address, // Address for secondary interface
    output reg [DATA_WIDTH:0] o_wr_data,  // Data to memory including parity bit
    input [DATA_WIDTH:0] i_rd_data,       // Data from memory including parity bit
    
    // Register Interface signals
    input [ADDR_WIDTH-1:0] i_reg_addr,    // Address for register access
    input                  i_reg_access_valid,
    input i_reg_wr_rd,                    // Write or read control signal for registers (1: write, 0: read)
    input [7:0] i_reg_wr_data,            // Data to write into registers
    output reg             o_reg_rd_data_valid,
    output reg [7:0] o_reg_rd_data        // Register read data output
);

    // Local parameters for register addresses (with access types)
    localparam READ_COUNT_ADDR = 8'h00;           // Register address for read_count (Read-Only)
    localparam WRITE_COUNT_ADDR = 8'h01;          // Register address for write_count (Read-Only)
    localparam PARITY_ENABLE_ADDR = 8'h02;        // Register address for parity_enable (Read-Write)
    localparam PARITY_ERR_STATUS_ADDR = 8'h03;    // Register address for parity_err_status (Read-Only)
    localparam CLEAR_REGISTERS_ADDR = 8'h04;      // Register address for clear_registers (Write-Only)

    // Internal registers
    reg [7:0] read_count;               // Read count register (read-only)
    reg [7:0] write_count;              // Write count register (read-only)
    reg [7:0] parity_enable;            // Parity enable register (read-write)
    reg [7:0] parity_err_status;        // Parity error status register (read-only)
    reg [7:0] clear_registers;          // Clear registers control (write-only)

    // Parity logic
    wire [DATA_WIDTH-1:0] i_rd_data_no_parity;
    wire parity_check_pass;
    wire parity_bit_in_error;

    always @(posedge i_clk or negedge i_reset_n)
    begin
      if(!i_reset_n) begin
        o_wr_data[DATA_WIDTH:0]   <= {DATA_WIDTH{1'b0}}; 
        o_rd_data[DATA_WIDTH-1:0] <= {(DATA_WIDTH-1){1'b0}};
        o_address                 <= {ADDR_WIDTH {1'b0}};
        o_wr_en                   <= 1'b0;
        o_rd_en                   <= 1'b0;
        
      end
      else begin
        o_address                 <= i_address;
        o_wr_en                   <= i_wr_en;
        o_rd_en                   <= i_rd_en;
        o_wr_data[DATA_WIDTH-1:0] <= i_wr_data; // Write data excluding parity bit
        o_wr_data[DATA_WIDTH]     <= (parity_enable[0]) ? ^i_wr_data : 1'b0; // Compute parity bit (XOR of data)
        o_rd_data                 <= i_rd_data[DATA_WIDTH-1:0]; 
      end
         
    end

    // Parity check: Add parity for incoming write data
    
    // Parity check for incoming read data
    assign i_rd_data_no_parity = i_rd_data[DATA_WIDTH-1:0];
    assign parity_bit_in_error = (parity_enable[0]) ? (i_rd_data[DATA_WIDTH] != ^i_rd_data_no_parity) : 1'b0;
    assign parity_check_pass = !parity_bit_in_error;

    // Write count logic (saturates at 0xFF)
    always @(posedge i_clk or negedge i_reset_n) begin
        if (~i_reset_n) begin
            write_count <= 8'h00; // Clear write_count on reset
        end else if (i_wr_en) begin
            if (write_count != 8'hFF)
                write_count <= write_count + 1;
            else
                write_count <= write_count; // Saturate at 0xFF
        end
    end

    // Read count logic (saturates at 0xFF)
    always @(posedge i_clk or negedge i_reset_n) begin
        if (~i_reset_n) begin
            read_count <= 8'h00; // Clear read_count on reset
        end else if (i_rd_en) begin
            if (read_count != 8'hFF)
                read_count <= read_count + 1;
            else
                read_count <= read_count; // Saturate at 0xFF
        end
    end

    // Parity error status update
    always @(posedge i_clk or negedge i_reset_n) begin
        if (~i_reset_n) begin
            parity_err_status <= 8'h00; // Clear parity error status on reset
        end else if (parity_check_pass == 0) begin
            parity_err_status <= 8'h01; // Set error flag if parity check fails
        end else begin
            parity_err_status <= 8'h00; // Clear error flag if parity check passes
        end
    end

    // Clear registers logic (Write-only register)
    always @(posedge i_clk or negedge i_reset_n) begin
        if (~i_reset_n) begin
            read_count <= 8'h00;
            write_count <= 8'h00;
            parity_enable <= 8'h00;
            parity_err_status <= 8'h00;
        end else if (clear_registers[0]) begin
            read_count <= 8'h00;
            write_count <= 8'h00;
            parity_enable <= 8'h00;
            parity_err_status <= 8'h00;
        end
    end

    // Address Decoding for Register Interface
    always @(posedge i_clk or negedge i_reset_n) begin
        if (~i_reset_n) begin
            o_reg_rd_data <= 8'h00;
            o_reg_rd_data_valid <= 1'b0;
        end else if (i_reg_wr_rd && i_reg_access_valid) begin
            o_reg_rd_data_valid <= 1'b1;
            case (i_reg_addr)
                READ_COUNT_ADDR:        o_reg_rd_data <= read_count; // Read-only register
                WRITE_COUNT_ADDR:       o_reg_rd_data <= write_count; // Read-only register
                PARITY_ERR_STATUS_ADDR: o_reg_rd_data <= parity_err_status; // Read-only register
                PARITY_ENABLE_ADDR:     o_reg_rd_data <= parity_enable; // Read-write register
                default:                o_reg_rd_data <= 8'h00;
            endcase
        end
        else o_reg_rd_data_valid <= 1'b0;
    end

    // Write logic for read-write registers
    always @(posedge i_clk) begin
        if (~i_reset_n)
            parity_enable <= 8'h01;
        else if (!i_reg_wr_rd) begin
            if (i_reg_addr == PARITY_ENABLE_ADDR)
                parity_enable <= i_reg_wr_data;
        end 
    end

    // Reset Logic for Write-only Registers
    always @(posedge i_clk) begin
        if (i_reg_addr == CLEAR_REGISTERS_ADDR && !i_reg_wr_rd) begin
            clear_registers <= i_reg_wr_data;
        end
    end

endmodule