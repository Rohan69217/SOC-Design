module tb_Single_Port_Memory;

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

  // Instantiate the Single_Port_Memory
  Single_Port_Memory #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) dut (
    .i_clk(clk),
    .i_wr_en(wr_en),
    .i_rd_en(rd_en),
    .i_address(address),
    .i_wr_data(wr_data),
    .o_rd_data(rd_data)
  );

  // Instantiate Driver
  Driver driver (
    .i_clk(clk),
    .o_wr_en(wr_en),
    .o_rd_en(rd_en),
    .o_address(address),
    .o_wr_data(wr_data),
    .i_rd_data(rd_data)
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
  always #5 clk = ~clk; // 10ns clock period

  // Testbench Logic
  initial begin

    // Write and Read Operations
    #10 
    driver.write_transfer(8'h01, 8);  // Write 8 bytes starting at address 1
    driver.read_transfer(8'h01, 8);   // Read 8 bytes starting at address 1
    #20;
    driver.write_transfer(8'h08, 10);  
    driver.read_transfer(8'h04, 20);   

    #20 $finish;
  end

  initial begin
     $dumpfile("dump.vcd");
     $dumpvars;
     #10000 
     $finish;
  end
  
endmodule