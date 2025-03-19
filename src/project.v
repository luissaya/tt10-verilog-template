`default_nettype none
module tt_um_sync_fifo_luisaya( 
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // Defining parameters
  parameter FIFO_WIDTH = 4,
            FIFO_DEPTH = 8,
            ADDR_WIDTH = 3;

  wire [FIFO_WIDTH-1:0]  wr_data;
  wire wr_ena, rd_ena;
  wire [FIFO_WIDTH-1:0] rd_data;
  reg  full;
  reg  empty;

  // Definig inputs ports
  assign ui_in[3:0] = wr_data;
  assign ui_in[5:4] = {wr_ena, rd_ena};

  // Defining outputs ports 
  assign uo_out[3:0] = rd_data;
  assign uo_out[5:4] = {full, empty};

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out[7:6]  = 0;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in[7:6], uio_in, 1'b0};

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