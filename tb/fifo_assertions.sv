// Bind-free protocol/invariant checker for the synchronous FIFO.
module fifo_assertions #(
    parameter int DEPTH = 16,
    parameter int AW = $clog2(DEPTH)
) (
    input logic clk, rst_n, wr_en, rd_en, full, empty,
    input logic [AW:0] count
);
    logic past_valid = 1'b0;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) past_valid <= 1'b0;
        else past_valid <= 1'b1;
    end

    a_count_bounds: assert property (@(posedge clk) disable iff (!rst_n)
        count <= DEPTH);
    a_full_flag: assert property (@(posedge clk) disable iff (!rst_n)
        full == (count == DEPTH));
    a_empty_flag: assert property (@(posedge clk) disable iff (!rst_n)
        empty == (count == 0));
    a_no_both_flags: assert property (@(posedge clk) disable iff (!rst_n)
        !(full && empty));

    // These sample the previous cycle's requests and occupancy.
    a_count_transition: assert property (@(posedge clk) disable iff (!rst_n)
        past_valid |-> count ==
            ($past(count) +
             (int'($past(wr_en && (!full || (rd_en && !empty)))) -
              int'($past(rd_en && !empty)))));
endmodule
