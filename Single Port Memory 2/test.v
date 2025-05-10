/******************************************************************************************
 * Testbench: Single Port Memory Testbench
 * 
 * Description:
 * This is a testbench for verifying the functionality of the Single Port Memory module. 
 * The testbench stimulates the Single Port Memory with various write and read operations 
 * and checks that the expected data is written and read correctly.
 * 
 * The testbench instantiates the Single Port Memory module and generates clock signals, 
 * stimulus for the read/write operations, and checks the output for correctness.
 * 
 * Parameters:
 *   DATA_WIDTH   - Width of the data bus (in bits).
 *   ADDR_WIDTH   - Width of the address bus (in bits).
 *   MEM_DEPTH    - Depth of the memory (number of addressable locations).
 * 
 * Ports:
 *   None (Testbench does not have ports, as it is a self-contained simulation environment).
 ******************************************************************************************/



module Tb_Single_Port_Memory;

  // Parameters for Single_Port_Memory
  parameter DATA_WIDTH = 8;
  parameter ADDR_WIDTH = 8;

  // Testbench Signals
  reg clk;
  wire wr_en;
  wire rd_en;
  wire [ADDR_WIDTH-1:0] address;
  wire [DATA_WIDTH-1:0] wr_data;
  wire [DATA_WIDTH-1:0] rd_data;
  wire mc_to_mem_wr_en;
  wire mc_to_mem_rd_en;
  wire [ADDR_WIDTH-1:0] mc_to_mem_address;
  wire [DATA_WIDTH:0] mc_to_mem_wr_data;
  wire [DATA_WIDTH:0]mem_to_mc_rd_data;
  reg i_reset_n;
  
   wire [ADDR_WIDTH-1:0]reg_addr;
      wire reg_access_valid;
      wire reg_wr_rd;
      wire [7:0]reg_wr_data;
      wire [7:0]reg_rd_data;
      wire reg_rd_data_valid;
      
initial begin
  $dumpfile("dump.vcd");
  $dumpvars;
  #10000 
  $finish;
end
  
  // Instantiate the Single_Port_Memory
  Single_Port_Memory #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) mem (
    .i_clk(clk),
    .i_wr_en(mc_to_mem_wr_en),
    .i_rd_en(mc_to_mem_rd_en),
    .i_address(mc_to_mem_address),
    .i_wr_data(mc_to_mem_wr_data),
    .o_rd_data(mem_to_mc_rd_data)
  );

  Memory_Controller #(
    .DATA_WIDTH(DATA_WIDTH), 
    .ADDR_WIDTH(ADDR_WIDTH) 
  ) mc(
    // Clock and Reset
    .i_clk(clk),                          
    .i_reset_n(i_reset_n),                  
    
    // Primary interface signals
    .i_wr_en(wr_en),                        
    .i_rd_en(rd_en),                        
    .i_address(address),     
    .i_wr_data(wr_data),     
    .o_rd_data(rd_data),     

    // Secondary interface signals
    .o_wr_en(mc_to_mem_wr_en),     
    .o_rd_en(mc_to_mem_rd_en),     
    .o_address(mc_to_mem_address), 
    .o_wr_data(mc_to_mem_wr_data),
    .i_rd_data(mem_to_mc_rd_data),
    
    // Register Interface signals
    .i_reg_addr(reg_addr),
    .i_reg_access_valid(reg_access_valid),
    .i_reg_wr_rd(reg_wr_rd),
    .i_reg_wr_data(reg_wr_data),
    .o_reg_rd_data(reg_rd_data),
    .o_reg_rd_data_valid(reg_rd_data_valid)
);
  
  
  // Instantiate Driver
  Driver drv (
    .i_clk(clk),
    .o_wr_en(wr_en),
    .o_rd_en(rd_en),
    .o_address(address),
    .o_wr_data(wr_data),
    .i_rd_data(rd_data),
        
    // Register Interface signals
    .o_reg_addr(reg_addr),
    .o_reg_access_valid(reg_access_valid),
    .o_reg_wr_rd(reg_wr_rd),
    .o_reg_wr_data(reg_wr_data),
    .i_reg_rd_data(reg_rd_data),
    .i_reg_rd_data_valid(reg_rd_data_valid)
  );
  
  
    // Instantiate Monitor
  Monitor #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
  ) monitor (
    .i_clk(clk),
    .i_wr_en(wr_en),
    .i_rd_en(rd_en),
    .i_address(address),
    .i_wr_data(wr_data),
    .i_rd_data(rd_data)
  );

  // Clock Generation
  initial clk = 0;
  initial begin
    i_reset_n = 0;
    repeat ($urandom_range(1, 5)) @ (posedge clk);
    i_reset_n = 1;
  end
  
  
  always #5 clk = ~clk; // 10ns clock period
 
  integer no_of_transfers;
  reg [ADDR_WIDTH-1:0] start_address;
  reg [7:0] reg_data;

  // Testbench Logic
  initial begin
    #1;
    wait (i_reset_n);
    no_of_transfers = $urandom_range(50, 20);
    start_address = $urandom_range(100,2);
    
    // Write and Read Operations
    drv.write_transfer(start_address, no_of_transfers);  // Write 8 bytes starting at address 1
    drv.read_transfer(start_address, no_of_transfers);   // Read 8 bytes starting at address 1

    // compare the value returned by the task with no_of_transfers; Display error if the number does not match 
    drv.register_read(8'b01,reg_data); // Make this to print the number of write transfers performed
    if(reg_data == no_of_transfers)
    $display(" match: %d",reg_data);
    else
    $display("no match");
    drv.register_read(8'h00,reg_data); // Make this to print the number of read transfers performed
   
    drv.register_write(8'h04,8'h01); //Make this to clear the counters
  
    // 
    // compare the value returned by the task with 0; Display error if the number does not match 
    drv.register_read(8'b01,reg_data); // Print the Write transfers counter to print 0
    if(reg_data == 0)
    $display(" match: %d",reg_data);
    else
        $display("no match");
    drv.register_read(8'b00,reg_data); //Print the read transfers counter to print 0
   

    #20 $finish;
  end

endmodule