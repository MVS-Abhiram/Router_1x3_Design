`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.12.2023 11:47:27
// Design Name: 
// Module Name: FIFO_Project
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


/* module FIFO_Project(clk,resetnfi,soft_reset,read_enb,write_enb,data_infi,lfd_statefi,data_out,empty,full);
input clk,resetnfi,soft_reset,read_enb,write_enb,lfd_statefi;
input [7:0] data_infi;
output reg [7:0]data_out;
output empty, full;
integer i;
// Temporary Variable for checking payload and parity 
reg [7:0] temp; 
// write & read pointer declaration 
reg [3:0]write_ptr; 
reg [3:0]read_ptr; 
// Internal counter for empty and full 
reg [4:0]counter; 
// 16 x 9 Memory Declaration 
reg [8:0] mem [15:0]; 
// Internal Variable to store the input data
reg [8:0]x; 
// Assigning empty and full outputs 
assign empty = (counter==1'b0) ? 1'b1 : 1'b0; 
assign full = (counter >=5'b01111) ? 1'b1 : 1'b0; 
 
// Incrementing logic for counter // 
always@(posedge clk) 
begin 
    if (!resetnfi || soft_reset) 
        counter <= 5'd0; 
    // When writing 
    else if (!full && write_enb) 
        counter <= counter + 1; 
    // When reading 
    else if (!empty && read_enb) 
        counter <=counter - 1; 
end 
 
// Write Operation // 
always@(posedge clk) 
begin 
   if (!resetnfi) begin 
   for(i=0;i<16;i=i+1) begin 
       // Initialize all to 0 
       mem[i] <= 9'd0; 
       write_ptr <= 1'b0; 
       data_out <= 8'd0; 
       end 
   end 
   else if (soft_reset) begin 
   for(i=0;i<16;i=i+1) begin 
       mem[i] <= 9'd0; 
       write_ptr <= 1'b0; 
       // Initialize dout to z 
       data_out <= 8'bzz; 
       end 
   end 
   else if (write_enb == 1'b1 && full == 1'b0) 
    begin 
        // Memory width is 9 bits (lfd 1 + din 8)  
        mem[write_ptr] <= {lfd_statefi,data_infi}; 
        write_ptr <= write_ptr + 1; 
    end 
end 
 
// Read Operation // 
always@(posedge clk) 
begin 
   if (!resetnfi) begin 
   for(i=0;i<16;i=i+1) begin 
       // Initialize all to 0 
       mem[i] <= 9'd0; 
       read_ptr <= 4'b0; 
       data_out <= 8'd0; 
       temp <= 7'd1; 
       end 
   end 
   else if (soft_reset) begin 
   for(i=0;i<16;i=i+1) begin 
       mem[i] <= 9'd0; 
       read_ptr <= 4'd0; 
       // Initialize dout to z 
       data_out <= 8'bzz; 
       temp <= 7'd1; 
       end 
   end
   /* 1. Check for MSB bit in mem 
      2. Load the payload length + parity in temp 
      3. Perform read operation and decrement temp 
      4. If temp = 0 data_out = z  
   else if (read_enb == 1'b1 && empty == 1'b0) begin
      x = mem[read_ptr]; 
      if(x[8] == 1'b1) begin 
          //----- Parity will not be displayed if +1 is not added---- 
          // Storing payload length and parity (+1 to display Header also) 
          temp = x[7:2] + 1 + 1; 
          // neglet the msb bit (lfd_state) 
          data_out = x[7:0]; 
          read_ptr = read_ptr + 1; 
          temp = temp - 1; 
      end
      else 
      begin 
          data_out = x[7:0]; 
          read_ptr = read_ptr + 1; 
          temp = temp - 1; 
      end  
   end
   else if (temp == 8'd0)
   begin
       data_out <= 8'bz;
   end
end 
endmodule */

/*module FIFO_Project(clk,resetn,soft_reset,lfd_state,write_enb,read_enb,data_in,empty,full,data_out);
input clk,resetn,soft_reset,write_enb,read_enb,lfd_state;
input [7:0]data_in;
output full,empty;
output reg [7:0]data_out;
integer i,j;

parameter width=9, depth=16;

// memory declaration
reg [width-1:0]memory[depth-1:0];

//temprory varialble

reg[3:0] rd_pt,wr_pt;
reg[4:0]counter_pt;
reg[6:0]temp;
reg[7:0]header_byte;

// assignment of flag register 
assign empty = (counter_pt ==0);
assign full = (counter_pt == depth);

// counter logic
always@(posedge clk)
begin
if(!resetn)
counter_pt <= 5'b0;

else if (soft_reset)
counter_pt <= 5'b0;

else if (!full && write_enb)
counter_pt <= counter_pt+1;

else if (!empty && read_enb)
counter_pt <= counter_pt-1;

else
counter_pt <= counter_pt;
end

// write operation

always@(posedge clk)
begin
if (!resetn)
  begin
  for(i=0;i<depth;i=i+1)
  begin
  memory[i] <= 9'b0;
  wr_pt <= 4'b0;
  end
  end

else if (soft_reset)
  begin
  for(j=0;j<depth;j=j+1)
  begin
  memory[j] <= 9'bz;
  wr_pt <= 4'b0;
  end
  end
  

else if (write_enb == 1'b1 && full == 1'b0)
  begin
  if(lfd_state)
  begin
  header_byte <= data_in;
  end
  else 
  begin
  memory[wr_pt] <= {lfd_state,data_in};
  wr_pt <= wr_pt+1;
  end
  end

end

// read operation

always@(posedge clk)
begin
  
  if(!resetn)
  begin
  data_out <= 8'b0;
  rd_pt <= 4'b0;
  end
 
   else if (soft_reset)
   begin
   rd_pt <= 4'b0;
   data_out <= 8'bz;
   end
 
   else if(read_enb == 1'b1 && empty ==1'b0)
   begin
  
      if(lfd_state)
      begin
      data_out <= header_byte;
      temp <= header_byte[7:2] + 1'b1;
      end
   
      else if (temp > 0)
      begin
      data_out <= memory[temp];
      temp <= temp - 1;
      end

      else if(temp == 0)
      begin
      data_out <= 8'bz;
      end 
   end
 
   else
   begin
   data_out <= memory[rd_pt];
   rd_pt <= rd_pt+1;
   end
end

endmodule*/

/*module FIFO_Project (
    input clk,
    input resetn,
    input soft_reset,
    input [7:0] data_in,
    input lfd_state,
    input read_enb,
    input write_enb,

    output reg[7:0] data_out,
    output empty,
    output full
);

parameter DEPTH = 16;
parameter WIDTH = 9;

reg [WIDTH-1:0] memory [DEPTH-1:0]; // memoey declaration

// temprarory registor 
reg [3:0] wr_ptr, rd_ptr;
reg [4:0] count_ptr;
reg lfd_state_reg; 
reg [7:0] header_byte;
reg [6:0]temp;

// concurrent assignment for flag register
assign empty = (count_ptr == 0);
assign full = (count_ptr == DEPTH);

//reset operation 
 
always @(posedge clk)
 begin

if (~resetn)
begin
data_out <= 8'b0;
wr_ptr <= 4'b0;
rd_ptr <= 4'b0;
count_ptr <= 5'b0;
lfd_state_reg <= 1'b0;
temp <= 7'b0;
end 

else 
begin

if (soft_reset) 
begin
data_out <= 8'bzzzz_zzzz;
wr_ptr <= 4'b0;
rd_ptr <= 4'b0;
count_ptr <= 5'b0;
lfd_state_reg <= 1'b0;
temp <= 7'b0;
end 

else 
begin
// write operation
  
if (write_enb && ~full)
begin
// Store header byte and set lfd_state_reg accordingly
        
if (lfd_state)
begin
header_byte <= data_in;
lfd_state_reg <= 1'b1;
end 

else 
begin
// Store payload byte and parity byte
memory[wr_ptr] <= {lfd_state_reg, data_in};
wr_ptr <= wr_ptr + 1;
count_ptr <= count_ptr + 1;
lfd_state_reg <= 1'b0;
end
end

//read operation 

if (read_enb && ~empty)
begin

if (lfd_state)
begin
data_out <= header_byte;
temp <= header_byte[7:2] + 1'b1;
end

else if (temp >0)
begin
data_out <= memory[temp];
temp <= temp-1;
end

      
else if (temp == 0)
begin
data_out <= 8'bzzzz_zzzz;
end

      
else 
begin
data_out <= memory[rd_ptr];
rd_ptr <= rd_ptr+1;
count_ptr <= count_ptr-1;
end


end
      
      
end 
end
end


endmodule*/




// Code by MAVEN SILICON
module FIFO_Project(clk,resetnfi,soft_reset,read_enb,write_enb,data_infi,lfd_statefi,data_out,empty,full);
input clk,resetnfi,soft_reset,read_enb,write_enb,lfd_statefi;
input [7:0] data_infi;
output reg [7:0]data_out;
output empty, full;
integer i;
reg [4:0]write_ptr; 
reg [4:0]read_ptr; 
reg [5:0] counter;
reg [8:0] fifo [15:0];

// Logic for writing data into memory
always@(posedge clk)
begin
    if (!resetnfi)
    begin
       write_ptr <= 0;
       for(i=0;i<16;i=i+1) 
       begin 
           fifo[i] <= 9'd0;
       end
    end
    else if (soft_reset)
    begin
        for(i=0;i<16;i=i+1) 
        begin 
           fifo[i] <= 9'd0;
       end   
    end
    else if (write_enb == 1'b1 && full == 1'b0)
    begin
        fifo[write_ptr] <= {lfd_statefi,data_infi};
        write_ptr <= write_ptr + 1;
    end   
end

// Logic for reading data into memory 
always@(posedge clk)
begin
    if (!resetnfi)
    begin
       data_out <= 0;
       read_ptr <= 0;
    end
    else if (soft_reset)
    begin
        data_out <= 0;
        read_ptr <= 0;
    end
    else if(read_enb == 1'b1 && empty == 0)
    begin
        data_out <= fifo[read_ptr[3:0]];
        read_ptr <= read_ptr + 1;
    end
end

// Loading the payload length and parity
always@(posedge clk)
begin
    if (!resetnfi)
    begin
       counter <= 0;
    end
    else if (soft_reset)
    begin
        counter <= 0;
    end
    else if (read_enb && !empty)
    begin
        if (fifo[read_ptr[3:0]][8] == 1'b1)
        begin
            counter <= fifo[read_ptr[3:0]][7:2] + 1'b1;
        end
        else if (counter != 0)
        begin
            counter <= counter -1;
        end
    end
end
assign full = (write_ptr == 5'b10000 && read_ptr == 5'b00000) ? 1'b1 : 1'b0;
assign empty = (write_ptr == read_ptr ) ? 1'b1 : 1'b0;
endmodule
