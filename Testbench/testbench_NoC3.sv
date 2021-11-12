`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench for Timing Analysis
//////////////////////////////////////////////////////////////////////////////////
`include "l15.tmp.h"
`include "lsu.tmp.h"
`include "define.tmp.h"

`ifdef DEFAULT_NETTYPE_NONE
`default_nettype none
`endif

`define L15_PADDR_HI 39
`define L15_THREADID_MASK 0:0



module testbench();

    //Instantiations
    reg clk;
    reg rst_n;
     
    reg [`NOC_CHIPID_WIDTH-1:0] chipid;
    reg [`NOC_X_WIDTH-1:0] coreid_x;
    reg [`NOC_Y_WIDTH-1:0] coreid_y;
    
    
    reg noc3encoder_noc3buffer_req_ack;
    reg noc3_out_rdy;

    reg l15_noc3encoder_req_val;
    reg noc3buffer_noc3encoder_req_val;
    reg [`L15_NOC3_REQTYPE_WIDTH-1:0] l15_noc3encoder_req_type;
    reg [63:0] l15_noc3encoder_req_data_0;
    reg [63:0] l15_noc3encoder_req_data_1;
    reg [`L15_MSHR_ID_WIDTH-1:0] l15_noc3encoder_req_mshrid;
    reg [1:0] l15_noc3encoder_req_sequenceid;
    reg [`L15_THREADID_MASK] l15_noc3encoder_req_threadid;
    reg [`L15_PADDR_HI:0] l15_noc3encoder_req_address;
    reg l15_noc3encoder_req_with_data;
    reg l15_noc3encoder_req_was_inval;
    reg [3:0] l15_noc3encoder_req_fwdack_vector;
    reg [`PACKET_HOME_ID_WIDTH-1:0] l15_noc3encoder_req_homeid;
    
    reg noc3_out_val;
    reg [`NOC_DATA_WIDTH-1:0] noc3_out_data;


    wire [`L15_NOC3_REQTYPE_WIDTH-1:0] noc3buffer_noc3encoder_req_type;
    wire [63:0] noc3buffer_noc3encoder_req_data_0;
    wire [63:0] noc3buffer_noc3encoder_req_data_1;
    wire [`L15_MSHR_ID_WIDTH-1:0] noc3buffer_noc3encoder_req_mshrid;
    wire [1:0] noc3buffer_noc3encoder_req_sequenceid;
    wire [`L15_THREADID_MASK] noc3buffer_noc3encoder_req_threadid;
    wire [`L15_PADDR_HI:0] noc3buffer_noc3encoder_req_address;
    wire noc3buffer_noc3encoder_req_with_data;
    wire noc3buffer_noc3encoder_req_was_inval;
    wire [3:0] noc3buffer_noc3encoder_req_fwdack_vector;
    wire [`PACKET_HOME_ID_WIDTH-1:0] noc3buffer_noc3encoder_req_homeid;
    reg noc3encoder_l15_req_ack;
    reg noc3buffer_l15_req_ack;    
    
    noc3buffer noc3buffer(
        .clk(clk),
        .rst_n(rst_n),
        .l15_noc3encoder_req_val(l15_noc3encoder_req_val),
        .l15_noc3encoder_req_type(l15_noc3encoder_req_type),
        .l15_noc3encoder_req_data_0(l15_noc3encoder_req_data_0),
        .l15_noc3encoder_req_data_1(l15_noc3encoder_req_data_1),
        .l15_noc3encoder_req_mshrid(l15_noc3encoder_req_mshrid),
        .l15_noc3encoder_req_sequenceid(l15_noc3encoder_req_sequenceid),
        .l15_noc3encoder_req_threadid(l15_noc3encoder_req_threadid),
        .l15_noc3encoder_req_address(l15_noc3encoder_req_address),
        .l15_noc3encoder_req_with_data(l15_noc3encoder_req_with_data),
        .l15_noc3encoder_req_was_inval(l15_noc3encoder_req_was_inval),
        .l15_noc3encoder_req_fwdack_vector(l15_noc3encoder_req_fwdack_vector),
        .l15_noc3encoder_req_homeid(l15_noc3encoder_req_homeid),
        .noc3buffer_l15_req_ack(noc3buffer_l15_req_ack),
        
        // from buffer to encoder
        .noc3buffer_noc3encoder_req_val(noc3buffer_noc3encoder_req_val),
        .noc3buffer_noc3encoder_req_type(noc3buffer_noc3encoder_req_type),
        .noc3buffer_noc3encoder_req_data_0(noc3buffer_noc3encoder_req_data_0),
        .noc3buffer_noc3encoder_req_data_1(noc3buffer_noc3encoder_req_data_1),
        .noc3buffer_noc3encoder_req_mshrid(noc3buffer_noc3encoder_req_mshrid),
        .noc3buffer_noc3encoder_req_sequenceid(noc3buffer_noc3encoder_req_sequenceid),
        .noc3buffer_noc3encoder_req_threadid(noc3buffer_noc3encoder_req_threadid),
        .noc3buffer_noc3encoder_req_address(noc3buffer_noc3encoder_req_address),
        .noc3buffer_noc3encoder_req_with_data(noc3buffer_noc3encoder_req_with_data),
        .noc3buffer_noc3encoder_req_was_inval(noc3buffer_noc3encoder_req_was_inval),
        .noc3buffer_noc3encoder_req_fwdack_vector(noc3buffer_noc3encoder_req_fwdack_vector),
        .noc3buffer_noc3encoder_req_homeid(noc3buffer_noc3encoder_req_homeid),
        .noc3encoder_noc3buffer_req_ack(noc3encoder_noc3buffer_req_ack)
    );

    noc3encoder noc3encoder(
        .clk(clk),
        .rst_n(rst_n),
        .l15_noc3encoder_req_val(noc3buffer_noc3encoder_req_val),
        .l15_noc3encoder_req_type(noc3buffer_noc3encoder_req_type),
        .l15_noc3encoder_req_data_0(noc3buffer_noc3encoder_req_data_0),
        .l15_noc3encoder_req_data_1(noc3buffer_noc3encoder_req_data_1),
        .l15_noc3encoder_req_mshrid(noc3buffer_noc3encoder_req_mshrid),
        .l15_noc3encoder_req_sequenceid(noc3buffer_noc3encoder_req_sequenceid),
        .l15_noc3encoder_req_threadid(noc3buffer_noc3encoder_req_threadid),
        .l15_noc3encoder_req_address(noc3buffer_noc3encoder_req_address),
        .l15_noc3encoder_req_with_data(noc3buffer_noc3encoder_req_with_data),
        .l15_noc3encoder_req_was_inval(noc3buffer_noc3encoder_req_was_inval),
        .l15_noc3encoder_req_fwdack_vector(noc3buffer_noc3encoder_req_fwdack_vector),
        .l15_noc3encoder_req_homeid(noc3buffer_noc3encoder_req_homeid),
        .chipid(chipid),
        .coreid_x(coreid_x),
        .coreid_y(coreid_y),
        .noc3out_ready(noc3_out_rdy),
        .noc3encoder_l15_req_ack(noc3encoder_l15_req_ack),
        .noc3encoder_noc3out_val(noc3_out_val),
        .noc3encoder_noc3out_data(noc3_out_data)
    );
    
    
    //Clock
    always #10 clk=~clk;
    
    //always #40 rst_n=~rst_n;
    
    initial begin 
        clk = 1'b0; //clock starts from a zero
        rst_n = 1'b0; //reset always zero
        
        l15_noc3encoder_req_val = 1'b1;
        noc3encoder_noc3buffer_req_ack = 1'b1;
        noc3_out_rdy = 1'b1;
        l15_noc3encoder_req_type = `L15_NOC3_REQTYPE_WRITEBACK;
        //noc3encoder_noc3buffer_req_ack = 1'd0;
        l15_noc3encoder_req_homeid = 20'd1;
        
        chipid = 1;
        coreid_x = 1;
        coreid_y = 1;
    end
    
    always @ (posedge clk) begin
        if(noc3encoder_l15_req_ack) begin
            rst_n = 1'b0;    
        end
        
        else begin
            rst_n = 1'b1;
        end    
    end
    
    //Testbench Implementation
    always @ (posedge clk) begin
        //l15_noc3encoder_req_type <= 3'd1; //Type of message
        
        l15_noc3encoder_req_data_0 <= 64'b1;
        l15_noc3encoder_req_data_1 <= 64'b1;
        l15_noc3encoder_req_mshrid <= `L15_MSHR_ID_WIDTH'b1; //Miss-Hit Register Id
        l15_noc3encoder_req_sequenceid <= 2'b11;
        l15_noc3encoder_req_threadid <= 1'b1;
        l15_noc3encoder_req_address <= `L15_PADDR_HI'b1; //sending a random addess value. Will not be accessed.
        l15_noc3encoder_req_with_data <= 1'b0; //request with data; Sending random data.
        l15_noc3encoder_req_was_inval <= 1'b0;
        l15_noc3encoder_req_fwdack_vector <= 4'b1000;   
        
    end
    
endmodule
