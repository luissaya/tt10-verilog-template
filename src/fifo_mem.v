module fifo_mem 
#(
// Defining parameters
parameter FIFO_WIDTH = 4,
          FIFO_DEPTH = 8,//2^3 = 8 entries
          ADDR_WIDTH = 3
) 
(
  // inputs
  input wr_clk, wr_en, rd_clk, rd_en,
  input [ADDR_WIDTH-1:0] wr_addr, rd_addr,
  input [FIFO_WIDTH-1:0] wr_data,
  input full,empty,
  // output
  output reg [FIFO_WIDTH-1:0] rd_data
);
// matrix for memory
reg [FIFO_WIDTH-1:0] MEM[0:FIFO_DEPTH-1];

// procedure for writing
always @(posedge wr_clk) 
begin
  if(wr_en && !full) begin
    MEM[wr_addr] <= wr_data;
  end
end
// procedure for reading
always @(posedge rd_clk) 
begin
  if(rd_en && !empty) begin
    rd_data <= MEM[rd_addr];
  end
end
endmodule