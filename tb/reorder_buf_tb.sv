module tb_reorder_buffer;

  parameter DATA_WIDTH = 8;

  logic clk;
  logic rst_n;

  // AR slave interface
  logic [3:0] s_arid_i;
  logic       s_arvalid_i;
  logic       s_arready_o;

  // R slave interface
  logic [DATA_WIDTH-1:0] s_rdata_o;
  logic [3:0]            s_rid_o;
  logic                  s_rvalid_o;
  logic                  s_rready_i;

  // AR master interface
  logic [3:0] m_arid_o;
  logic       m_arvalid_o;
  logic       m_arready_i;

  // R master interface
  logic [DATA_WIDTH-1:0] m_rdata_i;
  logic [3:0]            m_rid_i;
  logic                  m_rvalid_i;
  logic                  m_rready_o;

  // Instantiate reorder_buffer
  reorder_buffer #(
    .DATA_WIDTH(DATA_WIDTH)
  ) DUT (
    .clk         (clk),
    .rst_n       (rst_n),
    .s_arid_i    (s_arid_i),
    .s_arvalid_i (s_arvalid_i),
    .s_arready_o (s_arready_o),
    .s_rdata_o   (s_rdata_o),
    .s_rid_o     (s_rid_o),
    .s_rvalid_o  (s_rvalid_o),
    .s_rready_i  (s_rready_i),
    .m_arid_o    (m_arid_o),
    .m_arvalid_o (m_arvalid_o),
    .m_arready_i (m_arready_i),
    .m_rdata_i   (m_rdata_i),
    .m_rid_i     (m_rid_i),
    .m_rvalid_i  (m_rvalid_i),
    .m_rready_o  (m_rready_o)
  );

  parameter CLK_PERIOD = 100;

  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end 

  task reset();
    begin
      rst_n = '0;
      s_arvalid_i = '0;
      s_arready_o = '0;
      m_arready_i = '0;
      m_rvalid_i  = '0;
      s_rready_i = '0;
      @(posedge clk);
      @(posedge clk);
      rst_n = '1;
      s_rready_i = '1;
      @(posedge clk);
    end
  endtask

  task send_ar(input [3:0] id);
    begin
      s_arid_i = id;
      s_arvalid_i = 1;
      m_arready_i = 1;
      wait (s_arready_o && m_arvalid_o);
      @(posedge clk);
      s_arvalid_i = 0;
      m_arready_i = 0;
    end
  endtask

  task send_r(input [3:0] id, input [DATA_WIDTH-1:0] data);
    begin
      m_rid_i    = id;
      m_rdata_i  = data;
      m_rvalid_i = 1;
      @(posedge clk);
      @(posedge clk);
      m_rvalid_i = 0;
    end
  endtask

  task read_r();
    begin
    //   s_rready_i = 1;
      wait (s_rvalid_o);
      $display("Read: ID=%0d Data=%0h", s_rid_o, s_rdata_o);
      @(posedge clk);
      @(posedge clk);
    //   s_rready_i = 0;
    end
   endtask

   initial begin
      reset();
  
      //Посылаем три AR-запроса
      send_ar(4);
      send_ar(1);
      send_ar(7);
      @(posedge clk);
      @(posedge clk);
      @(posedge clk);
      @(posedge clk);
      send_ar(8);
  
      // R master отдает данные в другом порядке
      @(posedge clk);
      @(posedge clk);
      send_r(1, 8'hA1);
      // @(posedge clk);
      send_r(8, 8'hC7);
      // @(posedge clk);
      send_r(4, 8'h44);
      @(posedge clk);
      @(posedge clk);
      @(posedge clk);
      @(posedge clk);
      send_r(7, 8'h11);
      
  
      //Читаем данные на R slave
      @(posedge clk);
      @(posedge clk);
      read_r(); // ожидаем ID=4, Data=44
      @(posedge clk);

      read_r(); // ожидаем ID=1, Data=A1
      @(posedge clk);

      read_r(); // ожидаем ID=7, Data=C7
      @(posedge clk);

      read_r(); // ожидаем ID=7, Data=C7


      $finish;
    end

endmodule