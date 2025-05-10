module Monitor #( 
  parameter DATA_WIDTH = 8,    // Data width in bits
  parameter ADDR_WIDTH = 8,    // Address width in bits
  parameter FILE_NAME = "operation_log.txt"  // File name as a parameter
)
(
  input wire                  i_clk,
  input wire                  i_wr_en,
  input wire                  i_rd_en,
  input wire [ADDR_WIDTH-1:0] i_address,
  input wire [DATA_WIDTH-1:0] i_wr_data,
  input wire [DATA_WIDTH-1:0] i_rd_data
);

  integer file;  // File handle for writing to the file
  
  // Memory array
  reg [DATA_WIDTH-1:0] mem [0:(2**ADDR_WIDTH)-1];

  // Open the file for writing
  initial begin
    file = $fopen(FILE_NAME, "w");
    if (file == 0) begin
      $display("Error opening file: %s", FILE_NAME);
    end
  end

  // Monitor the interface and print the operations into the file
  always @(posedge i_clk) begin
    if ( ~ (i_wr_en || i_rd_en)) begin
      // Print IDLE operation if no read/write is happening
      $fdisplay(file, "%4t ns: IDLE - No operation  ", $time);
    end else if (i_wr_en) begin
      // Print write operation details
      $fdisplay(file, "%4t ns: WRITE - Address: %h, Data: %h", $time, i_address, i_wr_data);
    end else if (i_rd_en) begin
      // Print read operation details
      $fdisplay(file, "%4t ns: READ  - Address: %h, Data: %h", $time, i_address, i_rd_data);
    end

  end

  reg wr_en, rd_en;
  reg [DATA_WIDTH-1:0] wr_data;
  reg [ADDR_WIDTH-1:0] address;
  // Monitor the interface and print the operations into the file
  always @(posedge i_clk) 
  begin
    wr_en <= repeat (2)@ (posedge i_clk) i_wr_en;
    rd_en <= repeat (2)@ (posedge i_clk) i_rd_en;
    address <= repeat (2)@ (posedge i_clk) i_address;
    wr_data <= repeat (2)@ (posedge i_clk) i_wr_data;
    if (wr_en) 
    begin
      mem[address+1] <= wr_data;  
    end else if (rd_en) 
    begin
      #0;
      if(i_rd_data !== mem[address]) $display("ERROR: Data Mismatch seen; Address = %d, Expected_data= %b Actual Data =%b", address, mem[address], i_rd_data);
      else $display("Data Match: Address = %d, Expected_data= %b Actual Data =%b", address, mem[address], i_rd_data);
    end
  end
  
  
  // Close the file when the simulation ends
  final begin
    if (file != 0) begin
      $fclose(file);
    end
  end

endmodule