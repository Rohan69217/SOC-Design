module Single_Port_Memory #(parameter DATA_WIDTH = 8, ADDR_WIDTH = 8) (
    input wire                  i_clk,
    input wire                  i_wr_en,
    input wire                  i_rd_en,
    input wire [ADDR_WIDTH-1:0] i_address,
    input wire [DATA_WIDTH:0] i_wr_data,
    output reg [DATA_WIDTH:0] o_rd_data
);

    // Memory array
    reg [DATA_WIDTH-1:0] mem [0:(2**ADDR_WIDTH)-1];

    // Handle read and write operations
    always @(posedge i_clk) begin
        if (i_wr_en) begin
            mem[i_address] <= i_wr_data;  // Write data to memory
            // Display the write operation with MEM string prepended
            //$display("MEM: WRITE - Address: %h, Data: %h", i_address, i_wr_data);
        end
        if (i_rd_en) begin
            o_rd_data <= mem[i_address];  // Read data from memory
            // Display the read operation with MEM string prepended
          //$display("MEM: READ  - Address: %h, Data: %h", i_address, mem[i_address]);
        end
        else begin
            o_rd_data <= {DATA_WIDTH{1'bx}};  // Output 'X' when read is not enabled
        end
    end

endmodule