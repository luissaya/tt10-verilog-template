`include "fifo_mem.v"
module tt_um_sync_fifo_luisaya( clk, rst_n, wr_ena, rd_ena, wr_data, rd_data, full, empty);

// Defining parameters
parameter FIFO_WIDTH = 4,
          FIFO_DEPTH = 8,
          ADDR_WIDTH = 3;

// Definig inputs ports
input                   clk, rst_n;
input [FIFO_WIDTH-1:0]  wr_data;
input                   wr_ena, rd_ena;

// Defining outputs ports 
output [FIFO_WIDTH-1:0] rd_data;
output reg              full;
output reg              empty;

// Defining internal signals
reg [ADDR_WIDTH:0]  wr_ptr;
reg [ADDR_WIDTH:0]  rd_ptr;
wire                wr_en_mem;
wire                rd_en_mem;

// Instantiating the memory
fifo_mem 
#(
  .FIFO_WIDTH(FIFO_WIDTH),
  .FIFO_DEPTH(FIFO_DEPTH),
  .ADDR_WIDTH(ADDR_WIDTH)
)
MEM_inst0 
(
  .wr_clk(clk),
  .rd_clk(clk),
  .wr_en(wr_en_mem),
  .rd_en(rd_en_mem),
  .wr_data(wr_data),
  .rd_data(rd_data),
  .wr_addr(wr_ptr[ADDR_WIDTH-1:0]),
  .rd_addr(rd_ptr[ADDR_WIDTH-1:0]),
  .full(full),
  .empty(empty)
);

// calculus of write/read enable for memory 
// assign wr_en_mem = !full & wr_ena;
// assign rd_en_mem = !empty & rd_ena;

// Generating read and write pointers
always @(posedge clk ) 
begin
  if (!rst_n) 
  begin
    wr_ptr <= 0;
    rd_ptr <= 0;
  end 
  else 
  begin
    if (wr_ena && !full) 
    begin
      wr_ptr <= wr_ptr + 1;
    end
    if (rd_ena && !empty) 
    begin
      rd_ptr <= rd_ptr + 1;
    end
  end
end

// Generating full flag
always @(*) 
begin
  if (!rst_n) 
  begin
    full = 1'b0;
  end 
  else 
  begin
    if (wr_ena && !rd_ena) 
    begin
      if ((wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]) && (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH])) 
      begin
        full = 1'b1;
      end 
      else 
      begin
        full = 1'b0;
      end
    end
  end
end

// Generating empty flag
always @(*) 
begin
  if (!rst_n) 
  begin
    empty = 1'b0;
  end 
  else 
  begin
    if ((rd_ptr == wr_ptr) && rd_ena && !wr_ena) 
    begin
      empty = 1'b1;
    end 
    else if ((wr_ptr != rd_ptr) && wr_ena && !rd_ena) 
    begin
      empty = 1'b0;
    end
  end
end

endmodule