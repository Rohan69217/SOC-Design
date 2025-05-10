/*
module Monitor #(
  parameter DATA_WIDTH = 8, 
  parameter ADDR_WIDTH = 8
)(
  input wire i_clk,
  input wire i_wr_en,
  input wire i_rd_en,
  input wire [ADDR_WIDTH-1:0] i_address,
  input wire [DATA_WIDTH-1:0] i_wr_data,
  input wire [DATA_WIDTH-1:0] i_rd_data
);

  // Monitor the interface and print the operation being performed
  always @(posedge i_clk) begin
    if (i_wr_en) begin
      // Write Operation
      $display("%t : WRITE - Address: %h, Data: %h", $time, i_address, i_wr_data);
    end
    else if (i_rd_en) begin
      // Read Operation
      $display("%t : READ  - Address: %h, Data: %h", $time, i_address, i_rd_data);
    end
    else begin
      // IDLE Operation
      $display("%t : IDLE", $time);
    end
  end

endmodule
*/
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
      $fdisplay(file, "IDLE - No operation at time %0t", $time);
    end else if (i_wr_en) begin
      // Print write operation details
      $fdisplay(file, "WRITE - Address: %h, Data: %h, Time: %0t", i_address, i_wr_data, $time);
    end else if (i_rd_en) begin
      // Print read operation details
      $fdisplay(file, "READ  - Address: %h, Data: %h, Time: %0t", i_address, i_rd_data, $time);
    end

  end

  // Close the file when the simulation ends
  final begin
    if (file != 0) begin
      $fclose(file);
    end
  end
  

endmodule