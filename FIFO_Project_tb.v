`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.12.2023 13:36:46
// Design Name: 
// Module Name: FIFO_Project_tb
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


module FIFO_Project_tb();
reg clk,resetn,soft_reset,read_enb,write_enb,lfd_state;
reg [7:0] data_in;
wire [7:0]data_out;
wire empty, full;
FIFO_Project uut (clk,resetn,soft_reset,read_enb,write_enb,data_in,lfd_state,data_out,empty,full);
initial begin
    clk = 1'b0;
    while (1)
    #5 clk = ~clk;
end
// TASK initialization
task initialize();
begin
    {resetn,soft_reset} = 2'b00;
    {write_enb,read_enb,data_in,lfd_state} = 11'd0;
end
endtask

// Task for resetn
task rst();
begin
    @(negedge clk)
    resetn = 1'b0;
    @(negedge clk)
    resetn = 1'b1;
end
endtask

// Task for soft_reset
task softreset();
begin
    @(negedge clk)
    soft_reset = 1'b1;
    @(negedge clk)
    soft_reset = 1'b0;
end
endtask

// Task for reading data
task reading(input a);
begin
    @(negedge clk)
    read_enb = a;
end
endtask

// Task for writing data
task writing();
reg [7:0]payload_data,parity,header;
reg [5:0]payload_length;
reg [1:0]addr;
integer k;
begin
    // Driving the header byte
    @(negedge clk);
    payload_length = 6'd10;
    addr = 2'b00;
    header = {payload_length,addr};
    data_in = header;
    lfd_state = 1'b1;
    write_enb = 1'b1;
    // Driving the payload data
    for(k=0;k<payload_length;k=k+1) 
    begin
        @(negedge clk);
        lfd_state = 0;
        payload_data = {$random} % 256;
        data_in = payload_data;
    end
    // Driving the parity bit
    @(negedge clk);
    parity = 8'd3;
    data_in = parity;
end
endtask

// Calling the tasks
initial begin
     initialize();
     rst();
     writing();
     #10 write_enb = 0;
     reading(1'b1);
     #200;
     softreset();
     #300 $finish;
end
endmodule
