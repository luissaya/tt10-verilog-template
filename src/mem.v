module mem (clk, w_data, w_ena, r_ena, r_data, w_addr, r_addr);

// Parameter declarations
parameter FIFO_WIDTH = 8;
parameter ADDR_WIDTH = 5;
parameter FIFO_DEPTH = 2**5;

// Input and output declarations
input clk;
input w_ena; // also known as a "Push" signal
input r_ena; // also known as a "Pop" signal
input [FIFO_WIDTH-1:0]  w_data;
input [ADDR_WIDTH-1:0]  w_addr, r_addr;
output [FIFO_WIDTH-1:0]  r_data;
reg    [FIFO_WIDTH-1:0]  r_data;

// The register memory
reg [FIFO_WIDTH-1:0]  MEM[0:FIFO_DEPTH-1];

// Main body: Write when write enable is true and read always
always @(r_addr) 
begin
    r_data = MEM[r_addr];  
end

// assign r_data = MEM[r_addr];

always @(posedge clk ) 
begin
  if (w_ena) begin
    MEM[w_addr] <= w_data;
  end
end

endmodule