`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.01.2024 13:08:57
// Design Name: 
// Module Name: Router_Top_Level_1x3_tb
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


module Router_Top_Level_1x3_tb();
reg clock,resetn,read_enb_0,read_enb_1,read_enb_2,pkt_valid;
reg [7:0] data_in;
wire valid_out_0,valid_out_1,valid_out_2,error,busy;
wire [7:0] data_out_0,data_out_1,data_out_2;
integer i;

Router_Top_Level_1x3 uut(clock,resetn,read_enb_0,read_enb_1,read_enb_2,data_in,pkt_valid,data_out_0,data_out_1,data_out_2,valid_out_0,valid_out_1,valid_out_2,error,busy);
// Clock Defination
initial begin
    clock = 1'b0;
    while(1)
    #5 clock = ~clock;
end
//Initialize task
task initialize();
begin
    {resetn,read_enb_0,read_enb_1,read_enb_2,pkt_valid} = 5'd0;
    data_in = 8'd0;
end
endtask

// Resetn task
task reset();
begin
    @(negedge clock)
    resetn = 1'b0;
    @(negedge clock)
    resetn = 1'b1;
end
endtask

// packet generation  < 14
task packet_generation_less_14();
reg [7:0]payload_data,parity,header;
reg [5:0] payload_length;
reg [1:0] addr;
begin
    @(negedge clock)
    wait(~busy)
    @(negedge clock)
    pkt_valid = 1'b1;
    payload_length = 6'd5;
    addr = 2'b10;
    header = {payload_length,addr};
    parity = 1'b0;
    data_in = header;
    // Input parity generation
    parity = parity^header;
    @(negedge clock)
    wait(~busy)
    // Driving payload data
    for(i=0;i<payload_length;i=i+1)
    begin
        @(negedge clock)
        wait(~busy)
        payload_data = {$random}%256;
        data_in = payload_data;
        parity = parity ^ payload_data;
    end
    @(negedge clock)
    wait(~busy)
    pkt_valid = 1'b0;
    data_in = parity;
end
endtask

// packet generation  = 14
task packet_generation_equal_14();
reg [7:0]payload_data,parity,header;
reg [5:0] payload_length;
reg [1:0] addr;
begin
    @(negedge clock)
    wait(~busy)
    @(negedge clock)
    pkt_valid = 1'b1;
    payload_length = 6'd14;
    addr = 2'b10;
    header = {payload_length,addr};
    parity = 1'b0;
    data_in = header;
    
    // Input parity generation
    parity = parity^header;
    @(negedge clock)
    wait(~busy)
    // Driving payload data
    for(i=0;i<payload_length;i=i+1)
    begin
        @(negedge clock)
        wait(~busy)
        payload_data = {$random}%256;
        data_in = payload_data;
        parity = parity ^ payload_data;
    end
    @(negedge clock)
    wait(~busy)
    pkt_valid = 1'b0;
    data_in = parity;
end
endtask


// packet generation  > 14
task packet_generation_greater_14();
reg [7:0]payload_data,parity,header;
reg [5:0] payload_length;
reg [1:0] addr;
begin
    @(negedge clock)
    wait(~busy)
    @(negedge clock)
    pkt_valid = 1'b1;
    payload_length = 6'd16;
    addr = 2'b10;
    header = {payload_length,addr};
    parity = 1'b0;
    data_in = header;

    // Input parity generation
    parity = parity^header;
    @(negedge clock)
    wait(~busy)
    // Driving payload data
    for(i=0;i<payload_length;i=i+1)
    begin
        @(negedge clock)
        wait(~busy)
        payload_data = {$random}%256;
        data_in = payload_data;
        parity = parity ^ payload_data;
    end
    @(negedge clock)
    wait(~busy)
    pkt_valid = 1'b0;
    data_in = parity;
end
endtask

initial begin
    initialize();
    reset();
    
   /* // Driving packet < 14
    packet_generation_less_14();
    repeat (4) @(negedge clock) // Wait for 3 clock cycles
    // Performing read operation  (packet = 14)
    @(negedge clock)
    read_enb_2 = 1'b1;
    wait(~valid_out_2)
    @(negedge clock)
    read_enb_2 = 1'b0;*/
    
    /* // Driving packet == 14
    packet_generation_equal_14();
    repeat (3) @(negedge clock) // Wait for 3 clock cycles
    // Performing read operation  (packet = 14)
    @(negedge clock)
    read_enb_2 = 1'b1;
    wait(~valid_out_2)
    @(negedge clock)
    read_enb_2 = 1'b0; */
    
    // Driving packet = 16
    packet_generation_greater_14();
    repeat (3) @(negedge clock) // Wait for 3 clock cycles
    // Performing read operation  (packet = 16)
    @(negedge clock)
    read_enb_2 = 1'b1;
    wait(~valid_out_2)
    @(negedge clock)
    read_enb_2 = 1'b0;
end
endmodule
