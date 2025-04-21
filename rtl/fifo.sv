module fifo #(
    parameter int unsigned DATA_WIDTH   = 8,  
    parameter int unsigned DEPTH        = 2,    
    parameter type dtype                = logic [DATA_WIDTH-1:0],
    parameter int unsigned ADDR_DEPTH   = (DEPTH > 1) ? $clog2(DEPTH) : 1
)(
    input  logic  clk_i,         
    input  logic  rst_ni,         

    output logic  full_o,           
    output logic  empty_o,        

    input  dtype  data_i,           

    input  logic  push_i,           

    output dtype  data_o,           
    input  logic  pop_i          
);
    dtype read_data;
    localparam int unsigned FifoDepth = (DEPTH > 0) ? DEPTH : 1;
    logic en;
    logic [ADDR_DEPTH:0] read_pointer_n, read_pointer_q, write_pointer_n, write_pointer_q;
    logic read_enable;
    dtype [FifoDepth - 1:0] fifo;
    dtype [FifoDepth - 1:0] fifo_q;

    if (DEPTH == 0) begin : gen_pass_through
        assign empty_o     = ~push_i;
        assign full_o      = ~pop_i;
    end else begin : gen_fifo
      assign empty_o = (write_pointer_q == read_pointer_q);
      assign full_o  = (write_pointer_q[ADDR_DEPTH] != read_pointer_q[ADDR_DEPTH]) &&
                        (write_pointer_q[ADDR_DEPTH-1:0] == read_pointer_q[ADDR_DEPTH-1:0]);

    end

    always_comb begin : read_write_comb
        read_pointer_n  = read_pointer_q;
        write_pointer_n = write_pointer_q;
        data_o = fifo_q[read_pointer_q[ADDR_DEPTH-1:0]];
        fifo = fifo_q;
        en      = 1'b1;
        if (push_i && ~full_o) begin
            en = 1'b0;
            fifo[write_pointer_q[ADDR_DEPTH-1:0]] = data_i;
            if (write_pointer_q == FifoDepth[ADDR_DEPTH-1:0] - 1)
                write_pointer_n = '0;
            else
                write_pointer_n = write_pointer_q + 1;
        end
        if (pop_i && ~empty_o) begin
            
            if (read_pointer_n == FifoDepth[ADDR_DEPTH-1:0] - 1)
                read_pointer_n = '0;
            else
                read_pointer_n = read_pointer_q + 1;
        end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(~rst_ni) begin
            fifo_q <= '0;
        end else if (!en) begin
            fifo_q <= fifo;
        end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(~rst_ni) begin
            read_pointer_q  <= '0;
            write_pointer_q <= '0;
        end
        else begin
            read_pointer_q  <= read_pointer_n;
            write_pointer_q <= write_pointer_n;
        end
    end

endmodule 


