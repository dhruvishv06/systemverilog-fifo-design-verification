module tb_sync_fifo;
    parameter int DATA_WIDTH = 8;
    parameter int DEPTH = 16;
    localparam int AW = $clog2(DEPTH);

    logic clk = 0;
    always #5 clk = ~clk;
    logic rst_n = 0, wr_en = 0, rd_en = 0;
    logic [DATA_WIDTH-1:0] wr_data = 0;
    logic [DATA_WIDTH-1:0] rd_data;
    logic full, empty;
    logic [AW:0] count;

    sync_fifo #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) dut (.*);
    fifo_assertions #(.DEPTH(DEPTH)) checks (
        .clk, .rst_n, .wr_en, .rd_en, .full, .empty, .count
    );

    logic [DATA_WIDTH-1:0] model[$];
    logic [DATA_WIDTH-1:0] expected;
    bit did_read, did_write;
    int tests = 0;
    int coverage [0:2][0:3]; // occupancy: empty/middle/full x requests: idle/write/read/both

    task automatic step(input bit w, input bit r,
                        input logic [DATA_WIDTH-1:0] data);
        int occ_bin, op_bin;
        @(negedge clk);
        wr_en = w; rd_en = r; wr_data = data;
        occ_bin = (model.size() == 0) ? 0 : ((model.size() == DEPTH) ? 2 : 1);
        op_bin = int'({w,r});
        coverage[occ_bin][op_bin]++;
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
        int covered = 0;
        repeat (2) @(negedge clk);
        rst_n = 1;
        step(0, 0, '0);
        step(0, 1, '0); // Empty read ignored
        step(1, 1, DATA_WIDTH'(99)); // Empty read+write accepts write only
        step(0, 1, '0);
        for (int i = 0; i < DEPTH; i++) step(1, 0, DATA_WIDTH'(i));
        step(1, 0, '1); // Full write ignored
        step(1, 1, DATA_WIDTH'(165)); // Full read+write accepted
        for (int i = 0; i < 2000; i++)
            step(1'($urandom_range(0,1)),
                 1'($urandom_range(0,1)),
                 DATA_WIDTH'($urandom));
        while (model.size() != 0) step(0, 1, '0);
        for (int occ = 0; occ < 3; occ++) begin
            for (int op = 0; op < 4; op++) begin
                if (coverage[occ][op] > 0) covered++;
                $display("COVERAGE occupancy=%0d operation=%0d hits=%0d",
                         occ, op, coverage[occ][op]);
            end
        end
        $display("COVERAGE SUMMARY: %0d/12 occupancy x request bins hit", covered);
        // Explicit closure criterion: every bin must be exercised.
        assert (covered == 12)
            else $fatal(1, "Functional coverage incomplete: %0d/12", covered);
        $display("PASS: %0d checked cycles, all 12 functional bins covered", tests);
        $finish;
    end
endmodule
