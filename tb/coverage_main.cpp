#include "Vtb_sync_fifo.h"
#include "verilated.h"
#include "verilated_cov.h"

int main(int argc, char** argv) {
    VerilatedContext context;
    context.commandArgs(argc, argv);
    Vtb_sync_fifo model{&context};

    while (!context.gotFinish()) {
        model.eval();
        if (!model.eventsPending()) break;
        context.time(model.nextTimeSlot());
    }
    model.final();
    if (!context.gotFinish()) return 1;

    context.coveragep()->write("sim/coverage/coverage.dat");
    return 0;
}
