module tb_sync_fifo;
    localparam int DATA_WIDTH = 8;
    localparam int DEPTH = 16;
    localparam int AW = $clog2(DEPTH);

    logic clk = 0;
    always #5 clk = ~clk;
    logic rst_n = 0, wr_en = 0, rd_en = 0;
    logic [DATA_WIDTH-1:0] wr_data = 0;
    logic [DATA_WIDTH-1:0] rd_data;
    logic full, empty;
    logic [AW:0] count;

    sync_fifo #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) dut (.*);

    logic [DATA_WIDTH-1:0] model[$];
    logic [DATA_WIDTH-1:0] expected;
    bit did_read, did_write;
    int tests = 0;

    task automatic step(input bit w, input bit r,
                        input logic [DATA_WIDTH-1:0] data);
        // Drive on the falling edge; sample outputs after the rising edge.
        @(negedge clk);
        wr_en = w; rd_en = r; wr_data = data;
        did_read = r && (model.size() != 0);
        did_write = w && ((model.size() < DEPTH) || did_read);
        if (did_read) expected = model.pop_front();
        if (did_write) model.push_back(data);
        @(posedge clk);
        #1;
        assert (count == model.size())
            else $fatal(1, "Count mismatch: RTL=%0d model=%0d", count, model.size());
        assert (empty == (model.size() == 0))
            else $fatal(1, "Empty flag mismatch");
        assert (full == (model.size() == DEPTH))
            else $fatal(1, "Full flag mismatch");
        if (did_read)
            assert (rd_data === expected)
                else $fatal(1, "Data mismatch: got %h expected %h", rd_data, expected);
        tests++;
    endtask

    initial begin
        repeat (2) @(negedge clk);
        rst_n = 1;
        step(0, 1, 0); // Empty read ignored
        for (int i = 0; i < DEPTH; i++) step(1, 0, 8'(i));
        step(1, 0, 8'hFF); // Full write ignored
        step(1, 1, 8'hA5); // Full read+write accepted
        for (int i = 0; i < 2000; i++)
            step(1'($urandom_range(0,1)),
                 1'($urandom_range(0,1)),
                 8'($urandom));
        while (model.size() != 0) step(0, 1, 0);
        $display("PASS: %0d checked cycles", tests);
        $finish;
    end
endmodule
