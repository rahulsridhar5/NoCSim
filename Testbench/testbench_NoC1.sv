`timescale 1ns / 1ps

// NOC1 Testbench

`include "l15.tmp.h"
`include "lsu.tmp.h"
`include "define.tmp.h"

`define L15_THREADID_MASK 0:0

`ifdef DEFAULT_NETTYPE_NONE
`default_nettype none
`endif

module testbench();
    //Inputs copied from L15.v 
    reg clk;
    reg rst_n;
    
    reg [`NOC_CHIPID_WIDTH-1:0] chipid;
    reg [`NOC_X_WIDTH-1:0] coreid_x;
    reg [`NOC_Y_WIDTH-1:0] coreid_y;
    
    reg [63:0] l15_noc1buffer_req_data_0;
    reg [63:0] l15_noc1buffer_req_data_1;
    reg l15_noc1buffer_req_val;
    reg [`L15_NOC1_REQTYPE_WIDTH-1:0] l15_noc1buffer_req_type;
    reg [`L15_MSHR_ID_WIDTH-1:0] l15_noc1buffer_req_mshrid;
    reg [`L15_THREADID_MASK] l15_noc1buffer_req_threadid;
    reg [39:0] l15_noc1buffer_req_address;
    reg l15_noc1buffer_req_non_cacheable;
    reg [`PCX_SIZE_WIDTH-1:0] l15_noc1buffer_req_size;
    reg l15_noc1buffer_req_prefetch;
    // reg l15_noc1buffer_req_blkstore;
    // reg l15_noc1buffer_req_blkinitstore;
    reg [`L15_CSM_NUM_TICKETS_LOG2-1:0] l15_noc1buffer_req_csm_ticket;
    reg [`PACKET_HOME_ID_WIDTH-1:0] l15_noc1buffer_req_homeid;
    reg l15_noc1buffer_req_homeid_val;
    reg [`TLB_CSM_WIDTH-1:0] l15_noc1buffer_req_csm_data;
    reg dmbr_l15_stall;
    

    
    reg noc1_out_rdy;


    reg noc1encoder_noc1buffer_req_ack;

    // csm interface
    reg [`PACKET_HOME_ID_WIDTH-1:0] csm_l15_read_res_data;
    reg csm_l15_read_res_val;
    wire noc1encoder_csm_req_ack;

    
    //Output
   wire [63:0] noc1buffer_noc1encoder_req_data_0;
   wire [63:0] noc1buffer_noc1encoder_req_data_1;
   wire [`PACKET_HOME_ID_WIDTH-1:0] noc1buffer_noc1encoder_req_homeid;
   wire [`MSG_SDID_WIDTH-1:0] noc1buffer_noc1encoder_req_csm_sdid;
   wire [`MSG_LSID_WIDTH-1:0] noc1buffer_noc1encoder_req_csm_lsid;
   wire [63:0] noc1_out_data;

   
   wire [`NOC1_BUFFER_ACK_DATA_WIDTH-1:0] noc1encoder_l15_req_data_sent;
   
   reg [`L15_NOC1_REQTYPE_WIDTH-1:0] noc1buffer_noc1encoder_req_type;
   reg [`L15_MSHR_ID_WIDTH-1:0] noc1buffer_noc1encoder_req_mshrid;
   reg [`L15_THREADID_MASK] noc1buffer_noc1encoder_req_threadid;
   reg [39:0] noc1buffer_noc1encoder_req_address;
   reg noc1buffer_noc1encoder_req_non_cacheable;
   reg [`PCX_SIZE_WIDTH-1:0] noc1buffer_noc1encoder_req_size;
   reg noc1buffer_noc1encoder_req_val;

   // csm interface
   wire [`L15_CSM_NUM_TICKETS_LOG2-1:0] l15_csm_read_ticket;
   wire [`L15_CSM_NUM_TICKETS_LOG2-1:0] l15_csm_clear_ticket;
   wire l15_csm_clear_ticket_val;
   reg csm_noc1encoder_req_val;
   reg [`L15_NOC1_REQTYPE_WIDTH-1:0] csm_noc1encoder_req_type;
   reg [`L15_CSM_NUM_TICKETS_LOG2-1:0] csm_noc1encoder_req_mshrid;
   reg [`PHY_ADDR_WIDTH-1:0] csm_noc1encoder_req_address;
   reg csm_noc1encoder_req_non_cacheable;
   reg  [`PCX_SIZE_WIDTH-1:0] csm_noc1encoder_req_size;

   // output to mshrid when we have the csm
   wire noc1buffer_mshr_homeid_write_val_s4;
   wire [`L15_MSHR_ID_WIDTH-1:0] noc1buffer_mshr_homeid_write_mshrid_s4;
   wire [`L15_THREADID_MASK] noc1buffer_mshr_homeid_write_threadid_s4;
   wire [`PACKET_HOME_ID_WIDTH-1:0] noc1buffer_mshr_homeid_write_data_s4;
   
   wire                       l15_dmbr_l1missIn;
   wire [`DMBR_TAG_WIDTH-1:0] l15_dmbr_l1missTag;
   

   // output reg noc1buffer_l15_req_ack,
   reg noc1encoder_l15_req_sent;
    
        /*
            NoC1 buffers data before send out to NoC1, unlike NoC3 which doesn't have to buffer
            The buffer scheme will probably work as follow:
                We will have 4 queues: writeback guard queue, CAS queue, 8B data inst queue, and ld/st queue
                - Combined WBG/ldst queue: 6 entries (1l/1s/1if each thread). No data
                - Dataqueue of 16B
                    Supporting CAS/LDSTUB/SWAP and write-through. 1 CAS or 2 LDSTUB/SWAP or 2 write-through.
                All need to have the address + request metadata
            Priorities for the queues:
                1. writeback guard
                2. CAS
                3. data queue
                4. ld/st queue
                Note: TSO will not be violated regardless of how the NoC1 priority is chosen.
                        This is due to the fact that only 1 load per thread can be outstanding, and no ordering between different threads enforced
                        Actually, WBG might need to be ordered with respect to LD/ST req
        */
        
    
    //Module connection copied from L15.v
    noc1buffer noc1buffer(
        .clk(clk),
        .rst_n(rst_n),
        .l15_noc1buffer_req_data_0(l15_noc1buffer_req_data_0),
        .l15_noc1buffer_req_data_1(l15_noc1buffer_req_data_1),
        .l15_noc1buffer_req_val(l15_noc1buffer_req_val),
        .l15_noc1buffer_req_type(l15_noc1buffer_req_type),
        .l15_noc1buffer_req_threadid(l15_noc1buffer_req_threadid),
        .l15_noc1buffer_req_mshrid(l15_noc1buffer_req_mshrid),
        .l15_noc1buffer_req_address(l15_noc1buffer_req_address),
        .l15_noc1buffer_req_non_cacheable(l15_noc1buffer_req_non_cacheable),
        .l15_noc1buffer_req_size(l15_noc1buffer_req_size),
        .l15_noc1buffer_req_prefetch(l15_noc1buffer_req_prefetch),
        // .l15_noc1buffer_req_blkstore(l15_noc1buffer_req_blkstore),
        // .l15_noc1buffer_req_blkinitstore(l15_noc1buffer_req_blkinitstore),
        .l15_noc1buffer_req_csm_data(l15_noc1buffer_req_csm_data),
        
        .l15_noc1buffer_req_csm_ticket(l15_noc1buffer_req_csm_ticket),
        .l15_noc1buffer_req_homeid(l15_noc1buffer_req_homeid),
        .l15_noc1buffer_req_homeid_val(l15_noc1buffer_req_homeid_val),
        .noc1buffer_noc1encoder_req_csm_sdid(noc1buffer_noc1encoder_req_csm_sdid),
        .noc1buffer_noc1encoder_req_csm_lsid(noc1buffer_noc1encoder_req_csm_lsid),
        
        .noc1encoder_noc1buffer_req_ack(noc1encoder_noc1buffer_req_ack),
        
        .noc1buffer_noc1encoder_req_data_0(noc1buffer_noc1encoder_req_data_0),
        .noc1buffer_noc1encoder_req_data_1(noc1buffer_noc1encoder_req_data_1),
        .noc1buffer_noc1encoder_req_val(noc1buffer_noc1encoder_req_val),
        .noc1buffer_noc1encoder_req_type(noc1buffer_noc1encoder_req_type),
        .noc1buffer_noc1encoder_req_mshrid(noc1buffer_noc1encoder_req_mshrid),
        .noc1buffer_noc1encoder_req_threadid(noc1buffer_noc1encoder_req_threadid),
        .noc1buffer_noc1encoder_req_address(noc1buffer_noc1encoder_req_address),
        .noc1buffer_noc1encoder_req_non_cacheable(noc1buffer_noc1encoder_req_non_cacheable),
        .noc1buffer_noc1encoder_req_size(noc1buffer_noc1encoder_req_size),
        .noc1buffer_noc1encoder_req_prefetch(noc1buffer_noc1encoder_req_prefetch),
        // .noc1buffer_noc1encoder_req_blkstore(noc1buffer_noc1encoder_req_blkstore),
        // .noc1buffer_noc1encoder_req_blkinitstore(noc1buffer_noc1encoder_req_blkinitstore),
        
        // stall signal from dmbr prevents the encoder from sending requests to the L2
        // .l15_dmbr_l1missIn(l15_dmbr_l1missIn),
        // .l15_dmbr_l1missTag(l15_dmbr_l1missTag),
        // .dmbr_l15_stall(dmbr_l15_stall),
        
        // CSM
        .l15_csm_read_ticket(l15_csm_read_ticket),
        .l15_csm_clear_ticket(l15_csm_clear_ticket),
        .l15_csm_clear_ticket_val(l15_csm_clear_ticket_val),
        .csm_l15_read_res_data(csm_l15_read_res_data),
        .csm_l15_read_res_val(csm_l15_read_res_val),
        .noc1buffer_noc1encoder_req_homeid(noc1buffer_noc1encoder_req_homeid),
        
        // .noc1buffer_l15_req_ack(noc1encoder_l15_req_ack),
        .noc1buffer_l15_req_sent(noc1encoder_l15_req_sent),
        .noc1buffer_l15_req_data_sent(noc1encoder_l15_req_data_sent),
        
        // homeid
        .noc1buffer_mshr_homeid_write_threadid_s4(noc1buffer_mshr_homeid_write_threadid_s4),
        .noc1buffer_mshr_homeid_write_val_s4(noc1buffer_mshr_homeid_write_val_s4),
        .noc1buffer_mshr_homeid_write_mshrid_s4(noc1buffer_mshr_homeid_write_mshrid_s4),
        .noc1buffer_mshr_homeid_write_data_s4(noc1buffer_mshr_homeid_write_data_s4)
    );
    
    //Connections
    noc1encoder noc1encoder(
        .clk(clk),
        .rst_n(rst_n),
        .noc1buffer_noc1encoder_req_data_0(noc1buffer_noc1encoder_req_data_0),
        .noc1buffer_noc1encoder_req_data_1(noc1buffer_noc1encoder_req_data_1),
        .noc1buffer_noc1encoder_req_val(noc1buffer_noc1encoder_req_val),
        .noc1buffer_noc1encoder_req_type(noc1buffer_noc1encoder_req_type),
        .noc1buffer_noc1encoder_req_mshrid(noc1buffer_noc1encoder_req_mshrid),
        .noc1buffer_noc1encoder_req_threadid(noc1buffer_noc1encoder_req_threadid),
        .noc1buffer_noc1encoder_req_address(noc1buffer_noc1encoder_req_address),
        .noc1buffer_noc1encoder_req_non_cacheable(noc1buffer_noc1encoder_req_non_cacheable),
        .noc1buffer_noc1encoder_req_size(noc1buffer_noc1encoder_req_size),
        .noc1buffer_noc1encoder_req_prefetch(noc1buffer_noc1encoder_req_prefetch),
        // .noc1buffer_noc1encoder_req_blkstore(noc1buffer_noc1encoder_req_blkstore),
        // .noc1buffer_noc1encoder_req_blkinitstore(noc1buffer_noc1encoder_req_blkinitstore),
        .noc1buffer_noc1encoder_req_csm_sdid(noc1buffer_noc1encoder_req_csm_sdid),
        .noc1buffer_noc1encoder_req_csm_lsid(noc1buffer_noc1encoder_req_csm_lsid),
        .noc1buffer_noc1encoder_req_homeid(noc1buffer_noc1encoder_req_homeid),
        
        .dmbr_l15_stall(dmbr_l15_stall),
        .chipid(chipid),
        .coreid_x(coreid_x),
        .coreid_y(coreid_y),
        .noc1out_ready(noc1_out_rdy),
        
        .l15_dmbr_l1missIn(l15_dmbr_l1missIn),
        .l15_dmbr_l1missTag(l15_dmbr_l1missTag),
        .noc1encoder_noc1buffer_req_ack(noc1encoder_noc1buffer_req_ack),
        .noc1encoder_noc1out_val(noc1_out_val),
        .noc1encoder_noc1out_data(noc1_out_data),
        
        // csm interface
        .noc1encoder_csm_req_ack(noc1encoder_csm_req_ack),
        .csm_noc1encoder_req_val(csm_noc1encoder_req_val),
        .csm_noc1encoder_req_type(csm_noc1encoder_req_type),
        .csm_noc1encoder_req_mshrid(csm_noc1encoder_req_mshrid),
        .csm_noc1encoder_req_address(csm_noc1encoder_req_address),
        .csm_noc1encoder_req_non_cacheable(csm_noc1encoder_req_non_cacheable),
        .csm_noc1encoder_req_size(csm_noc1encoder_req_size)
    );
    
    //Clock
    always #10 clk=~clk;
    
    //reset
//    always @ (posedge clk) begin
//        if (!rst_n) begin
//            rst_n = 1'b1;
//        end
//    end
    
    //Initiliazing values
    initial begin 
        clk = 1'b0; //clock starts from a zero
        rst_n = 1'b0; //reset always zero
        noc1_out_rdy = 1'b1; //ready to receive 
        
        chipid = `NOC_CHIPID_WIDTH'b1;
        coreid_x = `NOC_X_WIDTH'b1;
        coreid_y = `NOC_Y_WIDTH'b1;
        csm_noc1encoder_req_mshrid = `L15_CSM_NUM_TICKETS_LOG2'b1;
        l15_noc1buffer_req_mshrid =  `L15_CSM_NUM_TICKETS_LOG2'b1;
        l15_noc1buffer_req_threadid = 3'b1;
        l15_noc1buffer_req_val = 1'b1; //Initial value to prevent sending before the NoC is ready
        l15_noc1buffer_req_type = `L15_NOC1_REQTYPE_LD_REQUEST; //5'd2; //The request sent to NOC1 Check if the CSM is the REQ source
        l15_noc1buffer_req_data_0 = 64'd255; //random data
        l15_noc1buffer_req_data_1 = 64'd255; //random data

        
        l15_noc1buffer_req_address = 40'd40; //random address
        
        noc1buffer_noc1encoder_req_val = 1'd0;
        //noc1encoder_csm_req_ack = 1'd0;
        
        l15_noc1buffer_req_non_cacheable = 1'd0;
        l15_noc1buffer_req_size = `PCX_SIZE_WIDTH'b0;
        l15_noc1buffer_req_prefetch = 1'b0;
    // reg l15_noc1buffer_req_blkstore;
    // reg l15_noc1buffer_req_blkinitstore;
        l15_noc1buffer_req_csm_ticket = `L15_CSM_NUM_TICKETS_LOG2'b11;
        l15_noc1buffer_req_homeid = 30'd1;
        l15_noc1buffer_req_homeid_val = 1'b1;
        l15_noc1buffer_req_csm_data = `TLB_CSM_WIDTH'd1;

    // csm interface
        csm_l15_read_res_data = 30'd1; //static bit width
        csm_l15_read_res_val = 1'd1;
        csm_noc1encoder_req_val = 1'd1;
        
        //csm_noc1encoder_req_type = `L15_NOC1_REQTYPE_LD_REQUEST;
        csm_noc1encoder_req_type = `L15_NOC1_REQTYPE_CAS_REQUEST; 
         
        dmbr_l15_stall = 1'b0;
        csm_noc1encoder_req_address = 40'd40; //random address
        csm_noc1encoder_req_non_cacheable = 1'b0;
        csm_noc1encoder_req_size = `PCX_SIZE_WIDTH'b0;
     end

    always @ (posedge clk)
    begin
    if (noc1encoder_csm_req_ack == 0)
        rst_n = 1;
     else
        rst_n = 0;
    
    end

endmodule

//Basically the NoC1_req_val sends the same message until it is reset or an acknowledgement is sent back to the NoC after the operation is complete 
