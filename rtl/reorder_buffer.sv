module reorder_buffer #(
  parameter DATA_WIDTH = 8
)(
  input logic                   clk,
  input logic                   rst_n,
  //AR slave interface
  input logic [3:0]             s_arid_i,
  input logic                   s_arvalid_i,
  output logic                  s_arready_o,
  //R slave interface
  output logic [DATA_WIDTH-1:0] s_rdata_o,
  output logic [3:0]            s_rid_o,
  output logic                  s_rvalid_o,
  input logic                   s_rready_i,
  //AR master interface
  output logic [3:0]            m_arid_o,
  output logic                  m_arvalid_o,
  input logic                   m_arready_i,
  //R master interface
  input logic [DATA_WIDTH-1:0]  m_rdata_i,
  input logic [3:0]             m_rid_i,
  input logic                   m_rvalid_i,
  output logic                  m_rready_o
);
 
  localparam ID_DEPTH = 16;

  logic [3:0] id_fifo_data_in, id_fifo_data_out, id_fifo_data_out_ff;
  logic       id_fifo_push, id_fifo_pop;
  logic       id_fifo_full, id_fifo_empty;

  logic [DATA_WIDTH-1:0] id_data    [ID_DEPTH - 1:0];
  logic                  id_valid   [ID_DEPTH - 1:0];

  fifo #(
    .DATA_WIDTH (4 ),
    .DEPTH      (ID_DEPTH )
  ) id_fifo (
    .clk_i      ( clk              ),
    .rst_ni     ( rst_n            ),
    .full_o     ( id_fifo_full     ),
    .empty_o    ( id_fifo_empty    ),
    .data_i     ( id_fifo_data_in  ),
    .push_i     ( id_fifo_push     ),
    .data_o     ( id_fifo_data_out ),
    .pop_i      ( id_fifo_pop      )
  );

  assign s_arready_o     = !id_fifo_full;
  assign m_arvalid_o     = s_arvalid_i && s_arready_o;
  assign m_arid_o        = s_arid_i;
  assign id_fifo_data_in = s_arid_i;
  assign id_fifo_push    = s_arvalid_i && s_arready_o && m_arready_i;

  assign m_rready_o = 1'b1;

  always_ff @(posedge clk) begin
    if ( !rst_n || id_fifo_empty) begin
      for ( int i = 0; i < ID_DEPTH; i++ ) begin
        id_valid[i] = '0;
      end
    end
    else if (m_rvalid_i) begin
      id_data[m_rid_i]  <= m_rdata_i;
      id_valid[m_rid_i] <= '1;
    end
  end

  logic [3:0] current_id;

  assign current_id = id_fifo_data_out;

  assign s_rvalid_o  = !id_fifo_empty && id_valid[current_id];
  assign s_rdata_o   = id_data[current_id];
  assign s_rid_o     = current_id;
  assign id_fifo_pop = s_rvalid_o && s_rready_i;
  
endmodule
