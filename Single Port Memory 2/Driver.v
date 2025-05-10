// Driver Module (BFM)
module Driver #(
  parameter DATA_WIDTH = 8,    // Data width in bits
  parameter ADDR_WIDTH = 8     // Address width in bits
)
 (
  input wire i_clk,
  
  //memory access interface
  output reg o_wr_en,
  output reg o_rd_en,
  output reg [ADDR_WIDTH-1:0] o_address,
  output reg [DATA_WIDTH-1:0] o_wr_data,
  input wire [DATA_WIDTH-1:0] i_rd_data,
   
  // Register access interface
   
    
  output reg [ADDR_WIDTH-1:0]o_reg_addr,    // Address for register access
  output reg                 o_reg_access_valid,
  output reg                 o_reg_wr_rd,   // Write or read control signal for registers (1: write, 0: read)
  output reg [7:0]           o_reg_wr_data, // Data to write into registers
  input                      i_reg_rd_data_valid,
  input  [7:0]               i_reg_rd_data  // Register read data output
);

  initial begin
    o_address = 'b0;
    o_wr_data = 'b0;
    o_wr_en   = 'b0;
    o_rd_en   = 'b0;
  end

  // Write Transfer Task
    task write_transfer(input [ADDR_WIDTH-1:0] start_addr, input integer num_bytes);
      integer i;
      reg [DATA_WIDTH-1 :0] temp_data ;
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
  
    // Register Write Task (to be implemented by student)
  task register_write(input [ADDR_WIDTH-1:0] reg_addr, input [7:0] reg_data);
    begin
    @(posedge i_clk);
      o_reg_access_valid = 1;
      o_reg_wr_rd = 0;
      o_reg_addr = reg_addr;
      o_reg_wr_data = reg_data;
    @(posedge i_clk);
      o_reg_access_valid = 0;
      
    end
  endtask

  // Register Read Task (to be implemented by student)
  task register_read(input [ADDR_WIDTH-1:0] reg_addr, output reg [7:0] reg_data);
    begin
    @(posedge i_clk);
          o_reg_access_valid = 1;
          o_reg_wr_rd = 1;
          o_reg_addr = reg_addr;
         @(posedge i_clk);
         o_reg_access_valid = 0;
         wait(i_reg_rd_data_valid); 
          reg_data = i_reg_rd_data;
         
    end
  endtask
  
endmodule