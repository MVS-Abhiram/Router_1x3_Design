`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.01.2024 15:47:02
// Design Name: 
// Module Name: Register_Project_tb
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


module Register_Project_tb();
reg clock,resetn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state;
reg [7:0] data_in;
wire parity_done,low_pkt_valid,err;
wire [7:0] data_out;
integer i,j;
reg [7:0] parity;
// Instantiatione of RTL
Register_Project uut(clock,resetn,pkt_valid,data_in,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,parity_done,low_pkt_valid,err,data_out);
// Clock generation
initial begin
    clock = 1'b0;
    while (1)
    #5 clock = ~clock;
end
// Initialization Task
task initialize();
begin
    {resetn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state} = 9'd0;
    data_in = 8'd0;
end
endtask
// reset Task
task reset();
begin
    @(negedge clock)
    resetn = 1'b0;
    @(negedge clock)
    resetn = 1'b1;
end
endtask
// Good Packet Task
task good_packet();
    reg [7:0] payload_data,header;
    reg [5:0] payload_length;
    reg [1:0] addr;
begin
    // Driving the header byte
    @(negedge clock)
    payload_length = 6'd4;
    addr = 2'b10;
    pkt_valid = 1'b1;
    detect_add = 1'b1;
    header = {payload_length,addr};
    // Bit wise parity encoding
    parity = 8'd0 ^ header;
    data_in = header;
    @(negedge clock)
    detect_add = 1'b0;
    lfd_state = 1'b1;
    full_state = 1'b0;
    fifo_full = 1'b0;
    laf_state = 1'b0;
    // Driving the payload data
    for(i=0;i<payload_length; i=i+1)
    begin
        @(negedge clock)
        lfd_state = 1'b0;
        ld_state = 1'b1;
        payload_data = {$random}% 256;
        data_in = payload_data;
        parity = parity^data_in;
    end
    // Driving the parity
    @(negedge clock)
    pkt_valid = 1'b0;
    data_in = parity;
    @(negedge clock)
    ld_state = 1'b0;
end
endtask

// Bad Packet Task
task bad_packet();
    reg [7:0] payload_data,header;
    reg [5:0] payload_length;
    reg [1:0] addr;
begin
    // Driving the header byte
    @(negedge clock)
    payload_length = 6'd4;
    addr = 2'b10;
    pkt_valid = 1'b1;
    detect_add = 1'b1;
    header = {payload_length,addr};
    // Bit wise parity encoding
    parity = 8'd0 ^ header;
    data_in = header;
    @(negedge clock)
    detect_add = 1'b0;
    lfd_state = 1'b1;
    full_state = 1'b0;
    fifo_full = 1'b0;
    laf_state = 1'b0;
    // Driving the payload data
    for(j=0;j<payload_length; j=j+1)
    begin
        @(negedge clock)
        lfd_state = 1'b0;
        ld_state = 1'b1;
        payload_data = {$random}% 256;
        data_in = payload_data;
        parity = parity^data_in;
    end
    // Driving the parity
    @(negedge clock)
    pkt_valid = 1'b0;
    data_in = 8'd3;
    @(negedge clock)
    ld_state = 1'b0;
end
endtask
// Calling the tasks
initial begin
    initialize();
    reset();
    good_packet();
    reset();
    bad_packet();

end
endmodule
