// Driver Module (BFM)
module Driver #(
  parameter DATA_WIDTH = 8,    // Data width in bits
  parameter ADDR_WIDTH = 8     // Address width in bits
)
 (
  input wire i_clk,
  output reg o_wr_en,
  output reg o_rd_en,
  output reg [ADDR_WIDTH-1:0] o_address,
  output reg [DATA_WIDTH-1:0] o_wr_data,
  input wire [DATA_WIDTH-1:0] i_rd_data
);


  // Write Transfer Task
  task write_transfer(input [ADDR_WIDTH-1:0] start_addr, input integer num_bytes);
    integer i;
    reg [DATA_WIDTH-1 :0] temp_data;
    begin
    temp_data = $urandom();
      for (i = 0; i < num_bytes; i = i + 1) begin
        @(posedge i_clk);
        o_wr_en = 1;
        o_rd_en = 0;
        o_address = start_addr + i;
        o_wr_data = temp_data+'d1; // Example data
        temp_data = o_wr_data;
      end
      @(posedge i_clk);
      o_wr_en = 0;
    end
  endtask

  // Read Transfer Task
  task read_transfer(input [ADDR_WIDTH-1:0] start_addr, input integer num_bytes);
    integer i;
    begin
      for (i = 0; i < num_bytes; i = i + 1) begin
        @(posedge i_clk);
        o_wr_en = 0;
        o_rd_en = 1;
        o_address = start_addr + i;
      end
      @(posedge i_clk);
      o_rd_en = 0;
    end
  endtask
endmodule
