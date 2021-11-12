`timescale 1ns / 1ps

`include "l2.tmp.h"
`include "define.tmp.h"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/01/2021 10:29:46 PM
// Design Name: 
// Module Name: testbench
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


module testbench();

        //Signal declerations
    reg clk;
    reg rst_n;
    
    reg csm_en;

    
    reg pipe2_valid_S1;
    reg pipe2_valid_S2;
    reg pipe2_valid_S3;
    reg [`PHY_ADDR_WIDTH-1:0] pipe2_addr_S1;
    reg [`PHY_ADDR_WIDTH-1:0] pipe2_addr_S2;
    reg [`PHY_ADDR_WIDTH-1:0] pipe2_addr_S3;
    reg [`MSG_TYPE_WIDTH-1:0] pipe2_msg_type_S1;
    reg [`MSG_TYPE_WIDTH-1:0] pipe2_msg_type_S2;
    reg [`MSG_TYPE_WIDTH-1:0] pipe2_msg_type_S3;
    
    
    reg global_stall_S1;
    reg msg_header_valid;
    reg [`MSG_TYPE_WIDTH-1:0] msg_type; 
    reg [`MSG_DATA_SIZE_WIDTH-1:0] msg_data_size;
    reg [`MSG_CACHE_TYPE_WIDTH-1:0] msg_cache_type;
    reg mshr_hit;
    
    reg [`MSG_TYPE_WIDTH-1:0] mshr_msg_type;
    reg [`MSG_L2_MISS_BITS-1:0] mshr_l2_miss;
    reg [`MSG_DATA_SIZE_WIDTH-1:0] mshr_data_size;
    reg [`MSG_CACHE_TYPE_WIDTH-1:0] mshr_cache_type;
    
    reg [`MSG_L2_MISS_BITS-1:0] cam_mshr_l2_miss;
    reg [`MSG_CACHE_TYPE_WIDTH-1:0] cam_mshr_cache_type;

    reg mshr_pending;
    reg [`L2_MSHR_INDEX_WIDTH-1:0] mshr_pending_index;
    reg [`L2_MSHR_INDEX_WIDTH:0] mshr_empty_slots;
    
    reg mshr_smc_miss;

    
    //input from the mshr
    reg [`MSG_TYPE_WIDTH-1:0] cam_mshr_msg_type;
    reg [`MSG_DATA_SIZE_WIDTH-1:0] cam_mshr_data_size;

    reg cam_mshr_smc_miss;

        //input from the mshr
    reg [`MSG_TYPE_WIDTH-1:0] pending_mshr_msg_type;
    reg [`MSG_L2_MISS_BITS-1:0] pending_mshr_l2_miss;
    reg [`MSG_DATA_SIZE_WIDTH-1:0] pending_mshr_data_size;
    reg [`MSG_CACHE_TYPE_WIDTH-1:0] pending_mshr_cache_type;
    reg pending_mshr_smc_miss;

 
    reg global_stall_S2;
    reg global_stall_S4;
    
    reg [`PHY_ADDR_WIDTH-1:0] addr_S1;
    reg [`PHY_ADDR_WIDTH-1:0] addr_S2;
    
    reg stall_S2;
    reg msg_data_valid;
    
    
    reg [`MSG_SRC_CHIPID_WIDTH-1:0] broadcast_chipid_out;
    reg [`MSG_SRC_X_WIDTH-1:0] broadcast_x_out;
    reg [`MSG_SRC_Y_WIDTH-1:0] broadcast_y_out;
    reg [`PHY_ADDR_WIDTH-1:0] addr_S3;
    reg [`L2_DIR_ARRAY_WIDTH-1:0] dir_data_out;
    
    reg [`MSG_LSID_WIDTH-1:0] lsid_S2;
    reg [`L2_ADDR_TYPE_WIDTH-1:0] reg_rd_addr_type;
    reg [`L2_MESI_BITS-1:0] l2_way_state_mesi_S2;
    reg [`L2_VD_BITS-1:0] l2_way_state_vd_S2;
    reg [`L2_SUBLINE_BITS-1:0] l2_way_state_subline_S2;
    reg [`L2_MESI_BITS-1:0] l2_way_state_mesi_S4;
    reg [`L2_OWNER_BITS-1:0] l2_way_state_owner_S4;
    reg [`L2_VD_BITS-1:0] l2_way_state_vd_S4;
    reg [`L2_SUBLINE_BITS-1:0] l2_way_state_subline_S4;
    reg [`MSG_MSHRID_WIDTH-1:0] mshrid_S4;
    reg [`MSG_LSID_WIDTH-1:0] mshr_miss_lsid_S4;
    reg [`MSG_LSID_WIDTH-1:0] lsid_S4;
    reg [`PHY_ADDR_WIDTH-1:0] addr_S4;
    reg [`L2_MSHR_INDEX_WIDTH-1:0] mshr_empty_index;
        
    reg l2_tag_hit_S2;
    reg l2_evict_S2;
    reg l2_wb_S2;
    reg [`L2_DI_BIT-1:0] l2_way_state_cache_type_S2;
    reg req_from_owner_S2;
    reg addr_l2_aligned_S2;
    reg l2_evict_S4;
    reg l2_tag_hit_S4;
    reg [`L2_DI_BIT-1:0] l2_way_state_cache_type_S4;
    reg req_from_owner_S4;
    reg cas_cmp_S4;
    reg msg_send_ready;
    reg smc_hit;
    reg broadcast_counter_max;
    reg broadcast_counter_avail;
    reg broadcast_counter_zero;
    
    wire [`L2_ADDR_TYPE_WIDTH-1:0] reg_wr_addr_type;
    wire [`MSG_TYPE_WIDTH-1:0] msg_type_S2;
    wire [`CS_OP_WIDTH-1:0] dir_op_S2;
    wire [`L2_AMO_ALU_OP_WIDTH-1:0] amo_alu_op_S2;
    wire [`MSG_DATA_SIZE_WIDTH-1:0] data_size_S2;
    wire [`CS_OP_WIDTH-1:0] state_owner_op_S2;
    wire [`CS_OP_WIDTH-1:0] state_subline_op_S2;
    wire [`L2_VD_BITS-1:0] state_vd_S2;
    wire [`L2_MESI_BITS-1:0] state_mesi_S2;
    wire [`L2_DATA_SUBLINE_WIDTH-1:0] l2_load_data_subline_S2;
    
    wire [`L2_ADDR_OP_WIDTH-1:0] smc_addr_op;
    wire [`L2_OWNER_BITS-1:0] dir_sharer_S4;
    wire [`L2_OWNER_BITS-1:0] dir_sharer_counter_S4;
    wire [`MSG_DATA_SIZE_WIDTH-1:0] cas_cmp_data_size_S4;
    wire [`L2_P1_BUF_OUT_MODE_WIDTH-1:0] msg_send_mode;
    wire [`MSG_TYPE_WIDTH-1:0] msg_send_type;
    wire [`MSG_TYPE_WIDTH-1:0] msg_send_type_pre;
    wire [`MSG_LENGTH_WIDTH-1:0] msg_send_length;
    wire [`MSG_DATA_SIZE_WIDTH-1:0] msg_send_data_size;
    wire [`MSG_MESI_BITS-1:0] msg_send_mesi;
    wire [`MSG_MSHRID_WIDTH-1:0] msg_send_mshrid;
    wire [`MSG_SUBLINE_VECTOR_WIDTH-1:0] msg_send_subline_vector;
    wire [`L2_DIR_ARRAY_WIDTH-1:0] dir_data_sel_S4;
    wire [`L2_DIR_ARRAY_WIDTH-1:0] dir_data_S4;
    wire [`MSG_TYPE_WIDTH-1:0] msg_type_S4;
    wire [`MSG_DATA_SIZE_WIDTH-1:0] data_size_S4;
    wire [`L2_MSHR_STATE_BITS-1:0] mshr_state_in;
    wire [`L2_MSHR_INDEX_WIDTH-1:0] mshr_wr_index_in;
    wire [`L2_MSHR_INDEX_WIDTH-1:0] mshr_inv_counter_rd_index_in;
    wire [`CS_OP_WIDTH-1:0] broadcast_counter_op;
    
    wire valid_S1;
    wire stall_S1;
    wire msg_from_mshr_S1;
    wire dis_flush_S1;
    wire mshr_cam_en;
    wire mshr_pending_ready;
    wire msg_header_ready;
    wire tag_clk_en;
    wire tag_rdw_en;
    wire state_rd_en;
    wire reg_wr_en;
    wire valid_S2;
    wire stall_before_S2;
    wire stall_real_S2;
    wire msg_from_mshr_S2;
    wire special_addr_type_S2;
    wire dir_clk_en;
    wire dir_rdw_en;
    wire data_clk_en;
    wire data_rdw_en;
    wire [`MSG_CACHE_TYPE_WIDTH-1:0] cache_type_S2;
    wire state_owner_en_S2;
    wire state_subline_en_S2;
    wire state_di_en_S2;
    wire state_vd_en_S2;
    wire state_mesi_en_S2;
    wire state_lru_en_S2;
    wire [`L2_LRU_OP_BITS-1:0] state_lru_op_S2;
    wire state_rb_en_S2;
    wire state_load_sdid_S2;
    wire l2_ifill_32B_S2;
    wire msg_data_ready;
    wire smc_wr_en;
    wire smc_wr_diag_en;
    wire smc_flush_en;
    wire valid_S3;
    wire stall_S3;
    wire stall_before_S3;
    wire valid_S4;
    wire stall_S4;
    wire stall_before_S4;
    wire stall_smc_buf_S4;
    wire msg_from_mshr_S4;
    wire req_recycle_S4;
    wire inv_fwd_pending_S4;
    wire cas_cmp_en_S4;
    wire atomic_read_data_en_S4;
    wire msg_send_valid;
    wire [`MSG_CACHE_TYPE_WIDTH-1:0] msg_send_cache_type;
    wire msg_send_l2_miss;
    wire special_addr_type_S4;
    wire [`MSG_CACHE_TYPE_WIDTH-1:0] cache_type_S4;
    wire [`MSG_L2_MISS_BITS-1:0] l2_miss_S4;
    wire smc_miss_S4;
    wire mshr_wr_data_en;
    wire mshr_wr_state_en;
    wire state_wr_sel_S4;
    wire state_wr_en;
    wire broadcast_counter_op_val;
    wire smc_rd_diag_en;
    wire smc_rd_en;
    wire l2_access_valid;
    wire l2_miss_valid;
    wire reg_rd_en;

    


l2_pipe1_ctrl ctrl(
        .clk                        (clk),
        .rst_n                      (rst_n),
        `ifndef NO_RTL_CSM
        .csm_en                     (csm_en),
        `endif
    
        .pipe2_valid_S1             (pipe2_valid_S1),
        .pipe2_valid_S2             (pipe2_valid_S2),
        .pipe2_valid_S3             (pipe2_valid_S3),
        .pipe2_msg_type_S1          (pipe2_msg_type_S1),
        .pipe2_msg_type_S2          (pipe2_msg_type_S2),
        .pipe2_msg_type_S3          (pipe2_msg_type_S3),
        .pipe2_addr_S1              (pipe2_addr_S1),
        .pipe2_addr_S2              (pipe2_addr_S2),
        .pipe2_addr_S3              (pipe2_addr_S3),
    
        .global_stall_S1            (global_stall_S1),
        .msg_header_valid_S1        (msg_header_valid),
        .msg_type_S1                (msg_type),
        .msg_data_size_S1           (msg_data_size),
        .msg_cache_type_S1          (msg_cache_type),
        .mshr_hit_S1                (mshr_hit),
    `ifdef NO_L2_CAM_MSHR
        .mshr_msg_type_S1           (mshr_msg_type),
        .mshr_l2_miss_S1            (mshr_l2_miss),
        .mshr_data_size_S1          (mshr_data_size),
        .mshr_cache_type_S1         (mshr_cache_type),
    `else
        .cam_mshr_msg_type_S1       (cam_mshr_msg_type),
        .cam_mshr_l2_miss_S1        (cam_mshr_l2_miss),
        .cam_mshr_data_size_S1      (cam_mshr_data_size),
        .cam_mshr_cache_type_S1     (cam_mshr_cache_type), 
    `endif // L2_CAM_MSHR
        .mshr_pending_S1            (mshr_pending),
        .mshr_pending_index_S1      (mshr_pending_index),
        .mshr_empty_slots_S1        (mshr_empty_slots),
        `ifndef NO_RTL_CSM
    `ifdef NO_L2_CAM_MSHR
        .mshr_smc_miss_S1           (mshr_smc_miss),
    `else
        .cam_mshr_smc_miss_S1       (cam_mshr_smc_miss),
    `endif // L2_CAM_MSHR
        `endif
    `ifndef NO_L2_CAM_MSHR
        .pending_mshr_msg_type_S1           (pending_mshr_msg_type),
        .pending_mshr_l2_miss_S1            (pending_mshr_l2_miss),
        .pending_mshr_data_size_S1          (pending_mshr_data_size),
        .pending_mshr_cache_type_S1         (pending_mshr_cache_type), 
        `ifndef NO_RTL_CSM
        .pending_mshr_smc_miss_S1           (pending_mshr_smc_miss),
        `endif
    `endif // L2_CAM_MSHR
        .msg_data_valid_S1          (msg_data_valid),
        .addr_S1                    (addr_S1),
       
        .global_stall_S2            (global_stall_S2),
        .l2_tag_hit_S2              (l2_tag_hit_S2),
        .l2_evict_S2                (l2_evict_S2),
        .l2_wb_S2                   (l2_wb_S2),
        .l2_way_state_mesi_S2       (l2_way_state_mesi_S2),
        .l2_way_state_vd_S2         (l2_way_state_vd_S2),
        .l2_way_state_cache_type_S2 (l2_way_state_cache_type_S2),
        .l2_way_state_subline_S2    (l2_way_state_subline_S2),
        .req_from_owner_S2          (req_from_owner_S2),
        .addr_l2_aligned_S2         (addr_l2_aligned_S2),
        .lsid_S2                    (lsid_S2),
        .msg_data_valid_S2          (msg_data_valid),
        .addr_S2                    (addr_S2),
    
        .dir_data_S3                (dir_data_out),
        .addr_S3                    (addr_S3),
    
        .global_stall_S4            (global_stall_S4),
        .l2_evict_S4                (l2_evict_S4),
        .l2_tag_hit_S4              (l2_tag_hit_S4),
        .l2_way_state_mesi_S4       (l2_way_state_mesi_S4),
        .l2_way_state_owner_S4      (l2_way_state_owner_S4),
        .l2_way_state_vd_S4         (l2_way_state_vd_S4),
        .l2_way_state_subline_S4    (l2_way_state_subline_S4),
        .l2_way_state_cache_type_S4 (l2_way_state_cache_type_S4),
        .mshrid_S4                  (mshrid_S4),
        .req_from_owner_S4          (req_from_owner_S4),
        .mshr_miss_lsid_S4          (mshr_miss_lsid_S4),
        .lsid_S4                    (lsid_S4),
        .addr_S4                    (addr_S4),
        .cas_cmp_S4                 (cas_cmp_S4),
        .msg_send_ready_S4          (msg_send_ready),
        .mshr_empty_index_S4        (mshr_empty_index),
        
        `ifndef NO_RTL_CSM
        .smc_hit_S4                 (smc_hit),
        .broadcast_counter_zero_S4  (broadcast_counter_zero),
        .broadcast_counter_max_S4   (broadcast_counter_max),
        .broadcast_counter_avail_S4 (broadcast_counter_avail),
        .broadcast_chipid_out_S4    (broadcast_chipid_out),
        .broadcast_x_out_S4         (broadcast_x_out),
        .broadcast_y_out_S4         (broadcast_y_out),
        `endif
    
        .valid_S1                   (valid_S1),  
        .stall_S1                   (stall_S1),    
        .msg_from_mshr_S1           (msg_from_mshr_S1), 
        .dis_flush_S1               (dis_flush_S1),
        .mshr_cam_en_S1             (mshr_cam_en),
        .mshr_pending_ready_S1      (mshr_pending_ready),
        .msg_header_ready_S1        (msg_header_ready),
        .tag_clk_en_S1              (tag_clk_en),
        .tag_rdw_en_S1              (tag_rdw_en),
        .state_rd_en_S1             (state_rd_en),
        .reg_wr_en_S1               (reg_wr_en),
        .reg_wr_addr_type_S1        (reg_wr_addr_type),
    
    
        .valid_S2                   (valid_S2),    
        .stall_S2                   (stall_S2), 
        .stall_before_S2            (stall_before_S2), 
        .stall_real_S2              (stall_real_S2),
        .msg_type_S2                (msg_type_S2),
        .msg_from_mshr_S2           (msg_from_mshr_S2),
        .special_addr_type_S2       (special_addr_type_S2),
        .dir_clk_en_S2              (dir_clk_en),
        .dir_rdw_en_S2              (dir_rdw_en),
        .dir_op_S2                  (dir_op_S2),
        .data_clk_en_S2             (data_clk_en),
        .data_rdw_en_S2             (data_rdw_en),
        .amo_alu_op_S2              (amo_alu_op_S2),
        .data_size_S2               (data_size_S2),
        .cache_type_S2              (cache_type_S2),
        .state_owner_en_S2          (state_owner_en_S2),
        .state_owner_op_S2          (state_owner_op_S2),
        .state_subline_en_S2        (state_subline_en_S2),
        .state_subline_op_S2        (state_subline_op_S2),   
        .state_di_en_S2             (state_di_en_S2),
        .state_vd_en_S2             (state_vd_en_S2),
        .state_vd_S2                (state_vd_S2),
        .state_mesi_en_S2           (state_mesi_en_S2),
        .state_mesi_S2              (state_mesi_S2),
        .state_lru_en_S2            (state_lru_en_S2),
        .state_lru_op_S2            (state_lru_op_S2),
        .state_rb_en_S2             (state_rb_en_S2),
        .state_load_sdid_S2         (state_load_sdid_S2),
        .l2_ifill_32B_S2            (l2_ifill_32B_S2),
        .l2_load_data_subline_S2    (l2_load_data_subline_S2),
        .msg_data_ready_S2          (msg_data_ready),
        `ifndef NO_RTL_CSM
        .smc_wr_en_S2               (smc_wr_en),
        .smc_wr_diag_en_S2          (smc_wr_diag_en),
        .smc_flush_en_S2            (smc_flush_en),
        .smc_addr_op_S2             (smc_addr_op),
        `endif    
    
        .valid_S3                   (valid_S3),    
        .stall_S3                   (stall_S3), 
        .stall_before_S3            (stall_before_S3), 
    
        .valid_S4                   (valid_S4),    
        .stall_S4                   (stall_S4), 
        .stall_before_S4            (stall_before_S4),
        `ifndef NO_RTL_CSM 
        .stall_smc_buf_S4           (stall_smc_buf_S4),
        `endif
        .msg_from_mshr_S4           (msg_from_mshr_S4),
        .req_recycle_S4             (req_recycle_S4),
        .inv_fwd_pending_S4         (inv_fwd_pending_S4),
        .dir_sharer_S4              (dir_sharer_S4),
        .dir_sharer_counter_S4      (dir_sharer_counter_S4),
        .cas_cmp_en_S4              (cas_cmp_en_S4),
        .atomic_read_data_en_S4     (atomic_read_data_en_S4),
        .cas_cmp_data_size_S4       (cas_cmp_data_size_S4),
        .msg_send_valid_S4          (msg_send_valid),
        .msg_send_mode_S4           (msg_send_mode),
        .msg_send_type_S4           (msg_send_type),
        .msg_send_type_pre_S4       (msg_send_type_pre),
        .msg_send_length_S4         (msg_send_length),
        .msg_send_data_size_S4      (msg_send_data_size),
        .msg_send_cache_type_S4     (msg_send_cache_type),
        .msg_send_mesi_S4           (msg_send_mesi),
        .msg_send_l2_miss_S4        (msg_send_l2_miss),
        .msg_send_mshrid_S4         (msg_send_mshrid),
        .msg_send_subline_vector_S4 (msg_send_subline_vector),
        .special_addr_type_S4       (special_addr_type_S4),
        .dir_data_sel_S4            (dir_data_sel_S4),
        .dir_data_S4                (dir_data_S4),
        .msg_type_S4                (msg_type_S4),
        .data_size_S4               (data_size_S4),
        .cache_type_S4              (cache_type_S4),
        .l2_miss_S4                 (l2_miss_S4),
        `ifndef NO_RTL_CSM
        .smc_miss_S4                (smc_miss_S4),
        `endif
        .mshr_wr_data_en_S4         (mshr_wr_data_en),
        .mshr_wr_state_en_S4        (mshr_wr_state_en),
        .mshr_state_in_S4           (mshr_state_in),
        .mshr_wr_index_in_S4        (mshr_wr_index_in),    
        .mshr_inv_counter_rd_index_in_S4(mshr_inv_counter_rd_index_in),    
        .state_wr_sel_S4            (state_wr_sel_S4),
        .state_wr_en_S4             (state_wr_en),
        `ifndef NO_RTL_CSM
        .broadcast_counter_op_S4    (broadcast_counter_op),
        .broadcast_counter_op_val_S4(broadcast_counter_op_val),
        `endif
        
        `ifndef NO_RTL_CSM
        .smc_rd_diag_en_buf_S4      (smc_rd_diag_en),
        .smc_rd_en_buf_S4           (smc_rd_en),
        `endif
    
        .l2_access_valid_S4         (l2_access_valid),
        .l2_miss_valid_S4           (l2_miss_valid),
        .reg_rd_en_S4               (reg_rd_en),
        .reg_rd_addr_type_S4        (reg_rd_addr_type)
    );
    
    initial begin
    //The registers that have no values do not matter in this case since we are using a CSM. If a CSM is not being used then these registers are used 
    //instead of their corresponding registers that we use right now since a CSM is being used in thio case.
        rst_n = 1'b1;
        clk = 1'b0;
        csm_en = 1'b1;
        
    
        //valid_S1
        msg_header_valid = 1'b1;
        //mshr_pending = 1'b0;
        
        mshrid_S4 = 8'd64;
        
        //stall_pre_S1 
        global_stall_S1 = 1'b0;
        
        //stall_S2 = valid_S2 && (stall_real_S2 || stall_load_S2);
        global_stall_S2 = 1'b0;
        
        mshr_pending = 1'b1;
        
        //Enables Content Addressable Memory in the MSHR
        
        pending_mshr_msg_type = `MSG_TYPE_NC_LOAD_REQ;
        msg_type = `MSG_TYPE_NC_LOAD_REQ;
        mshr_msg_type = `MSG_TYPE_NC_LOAD_REQ;
        pending_mshr_data_size = `MSG_DATA_SIZE_64B;
        pending_mshr_cache_type = `MSG_CACHE_TYPE_DATA;

        
        mshr_msg_type = `MSG_TYPE_NC_LOAD_REQ;
        mshr_l2_miss = 1'b0;
        mshr_data_size = `MSG_DATA_SIZE_64B;
        mshr_cache_type = `MSG_CACHE_TYPE_DATA;
        cam_mshr_l2_miss = 1'b0;
        cam_mshr_cache_type = 1'b0;
        
        addr_S1 = 40'b0;
        addr_S2 = 40'b0;
        addr_S4 = 40'd0;
        
        addr_S1[`L2_ADDR_TYPE] = `L2_ADDR_TYPE_DATA_ACCESS;
        addr_S2[`L2_ADDR_TYPE] = `L2_ADDR_TYPE_DATA_ACCESS;
        addr_S4[`L2_ADDR_TYPE] = `MSG_TYPE_NC_LOAD_REQ;
        
        addr_S1[`L2_TAG_INDEX] = 8'b11111111;
        addr_S2[`L2_TAG_INDEX] = 8'b11111111;
        
        pipe2_addr_S2 = 40'd0;
        pipe2_addr_S3 = 40'd0;

        
        pipe2_addr_S2 = 32'd1;
        pipe2_addr_S3 = 32'd1;
        
        pipe2_valid_S1 = 1'b1;
        pipe2_valid_S2 = 1'b1;
        pipe2_valid_S3 = 1'b1;
        
        pipe2_msg_type_S1 = `MSG_TYPE_WB_REQ;
        pipe2_msg_type_S2 = `MSG_TYPE_WB_REQ;
        pipe2_msg_type_S3 = `MSG_TYPE_WB_REQ;
        
        pipe2_addr_S1 = `PHY_ADDR_WIDTH'd1;
        addr_S3 = `PHY_ADDR_WIDTH'd1;
        //(addr_S3[`L2_TAG_PLUS_INDEX] == pipe2_addr_S1[`L2_TAG_PLUS_INDEX]))
        msg_data_size = `MSG_DATA_SIZE_64B;
        msg_data_valid = 1'b1;
        global_stall_S4 = 1'b0;
        mshr_hit = 1'b1;
        mshr_smc_miss = 1'b0;
        msg_cache_type = 1'b1;
        pending_mshr_cache_type = 1'b1;
        
        l2_way_state_mesi_S2 = `L2_MESI_S;
        
        pending_mshr_smc_miss = 1'b1;
        
        dir_data_out = 64'd29111996;
        
        mshr_empty_index = 3'b1;
        l2_wb_S2 = 1'b0;
        
        pending_mshr_l2_miss= 1'b0;
        
        l2_tag_hit_S2 = 1'b1;
        
        l2_way_state_vd_S4 = `L2_VD_CLEAN; //For the CS_S4 Control Stastus Stage 4 register
        
        l2_way_state_subline_S4 = 4'd9;
        
    end
    
    always #10 clk=~clk;
    always #40 rst_n=~rst_n;
    
    always @ (posedge clk) begin
        

        
    
    end

endmodule
