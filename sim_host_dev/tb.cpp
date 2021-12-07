// Simple TB

/*
verilator --cc --exe --trace -Wno-fatal -Wno-Litendian -Isrc -I./src/dl -I./src/tl top.v tb.cpp

cd obj_dir;make -f Vtop.mk;cd ..
obj_dir/Vtop
*/

// if tracing
#define TRACING

#include <cstddef>
#include <iostream>
#include <iomanip>
#include <experimental/random>

#include "Vtop.h"
#include "verilated.h"

#ifdef TRACING
#include "Vtop__Syms.h"
#include "verilated_vcd_c.h"
VerilatedVcdC *t;
std::string f = "wtf.vcd";
const char *vcdFile = f.c_str();
#else
unsigned int t = 0;
#endif
bool tracing = false;   // based on start time

Vtop* m;

vluint64_t main_time = 0;     // in units of timeprecision used in verilog or --timescale-override

using namespace std;

double sc_time_stamp() {      // $time in verilog
   return main_time;
}

void tick(void) {
   main_time++;

   m->eval();
   if (t && tracing) t->dump(main_time*10-2);

   // rising
   m->clk = 1;
   m->clk_156_25MHz = 1;
   m->eval();
   if (t && tracing) t->dump(main_time*10);

   // falling
   m->clk = 0;
   m->clk_156_25MHz = 0;
   m->eval();
   if (t && tracing) {
      t->dump(main_time*10+5);
      t->flush();
   }
}

int main(int argc, char **argv) {

   cout << setfill('0');

   Verilated::commandArgs(argc, argv);
   m = new Vtop;

#ifdef TRACING
      Verilated::traceEverOn(true);
      t = new VerilatedVcdC;
      m->trace(t, 99);  // hierarchy levels
      t->open(vcdFile);
#endif

   bool ok = true;
   bool done = false;
   int i;
   unsigned int quiescing = 0;
   unsigned int runCycles = 500000;
   unsigned int startTrace = 450000;
   unsigned adrMask = 0x0000003C; // restrict address range

   unsigned int tx_data, tx_clk, rx_data, wb_ack;
   bool reqPending = false, reqRd, reqWr;
   unsigned int reqAdr, reqSel, reqData, adr, data, mask;

   unsigned int linkUp = 0, tlReady = 0, phy_rx_valid[8], phy_rx_header[8], phy_rx_data[8],
                                         phy_tx_header[8], phy_tx_data[8];

   unsigned int clk_156_25MHz, hb_gtwiz_reset_all_in, send_first,
                gtwiz_reset_rx_done_in, gtwiz_reset_tx_done_in,
                gtwiz_buffbypass_rx_done_in, gtwiz_buffbypass_tx_done_in,
                gtwiz_userclk_rx_active_in, gtwiz_userclk_tx_active_in,
                gtwiz_reset_all_out, gtwiz_reset_rx_datapath_out;
   unsigned int dlx_config_info, tsm_state2_to_3 = -1, tsm_state4_to_5 = -1, tsm_state6_to_1 = -1;
   unsigned int startRetrain = -1;

   unsigned int mem[1024/4];
   // Init I/O

   //cout << "PHY Clk = 2:1" << endl;
   //m->cfg = (unsigned int)0x80000000;
   //cout << "PHY Clk = 4:1" << endl;
   //m->cfg = 0x00000001;

   //cout << "Debug Mode (data=~adr)" << endl;
   //m->cfg |= (unsigned int)0x40000000;

   // m->clk_156_25MHz = 0; this needs to run if emulating xil phy
   m->hb_gtwiz_reset_all_in = 0;
   /* need to release this
   assign dlx_reset = (send_first)                ? ~(gtwiz_reset_tx_done_in & gtwiz_buffbypass_tx_done_in) :
                      (rec_first_xtsm_q == 1'b0)  ? ~(gtwiz_reset_rx_done_in & gtwiz_buffbypass_rx_done_in) :
                                                    1'b0;

   */
   /* need to enable this
    assign io_pb_o0_rx_init_done = (xtsm_q == pulse_done) ? {8{gtwiz_reset_rx_done_in & gtwiz_buffbypass_rx_done_in & gtwiz_userclk_rx_active_in}} :
                                                          8'b0;
   */
   m->send_first = 1; // 1=host 0=dev
   m->gtwiz_reset_rx_done_in = 0;
   m->gtwiz_reset_tx_done_in = 0;
   m->gtwiz_buffbypass_rx_done_in = 0;
   m->gtwiz_buffbypass_tx_done_in = 0;
   m->gtwiz_userclk_rx_active_in = 0;
   m->gtwiz_userclk_tx_active_in = 0;

   if (startTrace == 0) tracing = true;

   cout << "Seed=" << setw(8) << setfill('0') << hex << 0x8675309 << endl;
   srand(0x8675309);  //wtf NOT WORKING??@?@?@

   // Reset
   cout << "Resetting..." << endl;
   m->rst = 1;
   tick();
   tick();
   tick();
   m->rst = 0;
   tick();
   cout << "Go!" << endl;
   tick();
   //cout << "Enabling link..." << endl;
   //m->cfg &= 0x7FFFFFFF;      // enable link after phy clock running

   /*
   assign io_pb_o0_rx_init_done = (xtsm_q == pulse_done) ? {8{gtwiz_reset_rx_done_in & gtwiz_buffbypass_rx_done_in & gtwiz_userclk_rx_active_in}} :
   */
   m->gtwiz_reset_rx_done_in = 1;
   m->gtwiz_buffbypass_rx_done_in = 1;
   m->gtwiz_userclk_rx_active_in = 1;

   m->gtwiz_reset_tx_done_in = 1;
   m->gtwiz_buffbypass_tx_done_in = 1;
   m->gtwiz_userclk_tx_active_in = 1;

   //m->top->host->omi_host->dl->reg_04_val = 0x00800000;
   //m->top->dev->dl->reg_04_val = 0x00800000;

   dlx_config_info = m->top->host->omi_host->dlx_config_info;
   cout << "DLX Config: " << setw(8) << hex << dlx_config_info << endl;

   // Sim loop
   while (!Verilated::gotFinish() && !done) {

      if (!tracing && startTrace <= main_time) tracing = true;

      if (quiescing) {
         quiescing--;
         if (quiescing == 0) {
            done = true;
         }
      }

      tick();

      if (dlx_config_info != m->top->host->omi_host->dlx_config_info) {
         dlx_config_info = m->top->host->omi_host->dlx_config_info;
         cout << "DLX Config: " << setw(8) << hex << dlx_config_info << endl;
      }

      if (startRetrain != m->top->host->omi_host->dl->tx->ctl->start_retrain_q) {
         startRetrain = m->top->host->omi_host->dl->tx->ctl->start_retrain_q;
         cout << "startRetrain=" << setw(1) << startRetrain << endl;
      }

      if (m->top->host->omi_host->dl->tx->ctl->tsm_q == 6) {
         m->host_tsm_state6_to_1 = 1; //wtf kick seq into action
         cout << "Setting host tsm 6->1..." << endl;
      }

      if (m->top->dev->dl->tx->ctl->tsm_q == 6) {
         m->dev_tsm_state6_to_1 = 1; //wtf kick seq into action
         cout << "Setting device tsm 6->1..." << endl;
      }

      /*
      if (m->top->host->omi_host->dl->tx->ctl->tsm_q == 2) {
         m->host_tsm_state2_to_3 = 1;
         cout << "Setting host tsm 2->3..." << endl;
      }
      if (m->top->dev->dl->tx->ctl->tsm_q == 2) {
         m->dev_tsm_state2_to_3 = 1;
         cout << "Setting device tsm 2->3..." << endl;
      }
      */
      //tie these in top level instead, and remove from inputs
      m->host_tsm_state6_to_1 = 1;
      m->host_tsm_state2_to_3 = 1;
      m->host_tsm_state4_to_5 = 1;
      m->dev_tsm_state6_to_1 = 1;
      m->dev_tsm_state2_to_3 = 1;
      m->dev_tsm_state4_to_5 = 1;




      if ((main_time %100) == 0) {
         cout << "cyc=" << setw(8) << setfill('0') << dec << main_time << endl; //" count=" << m->rootp->top__DOT__dufimem__DOT__count_q + 0 << endl;
      }
      if (!reqPending) {
         if (!quiescing && experimental::randint(1, 10) > 5) {
            if (experimental::randint(1, 2) == 1) {
               m->wb_cyc = 1;
               m->wb_stb = 1;
               m->wb_we = 0;
               reqAdr = experimental::randint(0, 1023) & adrMask;
               m->wb_adr = reqAdr;
               cout << "cyc=" << setw(8) << setfill('0') << dec << main_time;
               cout << " Read @" << setw(8) << setfill('0') << hex << reqAdr << endl;
               reqPending = true;
               reqRd = true;
            } else {
               m->wb_cyc = 1;
               m->wb_stb = 1;
               m->wb_we = 1;
               reqSel = experimental::randint(0, 15);
               m->wb_sel = reqSel;
               reqAdr = experimental::randint(0, 1023) & adrMask;
               reqData = experimental::randint(0, 0x7FFFFFFF);
               m->wb_adr = reqAdr;
               mask = 0;
               if (reqSel & 0x1) {
                  mask |= 0x000000FF;
               }
               if (reqSel & 0x2) {
                  mask |= 0x0000FF00;
               }
               if (reqSel & 0x4) {
                  mask |= 0x00FF0000;
               }
               if (reqSel & 0x8) {
                  mask |= 0xFF000000;
               }
               data = (mem[reqAdr] & ~mask) | (reqData & mask);
               m->wb_dat_i = reqData;
               cout << "cyc=" << setw(8) << setfill('0') << dec << main_time;
               cout << " Write @" << setw(8) << setfill('0') << hex << reqAdr << " sel=" << setw(1) << reqSel <<
                 " data=" << setw(8) << reqData << " mem=" << setw(8) << mem[reqAdr] << "->" << setw(8) << data << endl;
               mem[reqAdr] = data;
               reqPending = true;
               reqWr = true;
            }
         } else {
            m->wb_cyc = 0;
            m->wb_stb = 0;
         }
      } else {
         m->wb_cyc = 1;
         m->wb_stb = 1;
         if (reqRd) {
            m->wb_we = 0;
         } else {
            m->wb_we = 1;
         }
         m->wb_sel = reqSel;
         m->wb_adr = reqAdr;
         m->wb_dat_i = reqData;
      }

      wb_ack = m->wb_ack;
      if (wb_ack & !reqPending) {
         cout << "cyc=" << setw(8) << setfill('0') << dec << main_time;
         cout << " Bad ack!" << endl;
         quiescing = 10;
      } else if (wb_ack & reqRd) {
         reqRd = false;
         m->wb_cyc = 0;
         m->wb_stb = 0;
         data = m->wb_dat_o;
         cout << "cyc=" << setw(8) << setfill('0') << dec << main_time;
         cout << " ACK RD  data=" << setw(8) << setfill('0') << hex << data << endl;
         adr = reqAdr & 0x000000FF;
         if (data != mem[adr]) {
            cout << " ** MISCOMPARE Exp=@" << setw(8) << setfill('0') << hex << adr << "=" << mem[adr] << " **" << endl;
            quiescing = 100;
            ok = false;
         }
         reqPending = false;
      } else if (wb_ack) {
         reqWr = false;
         m->wb_cyc = 0;
         m->wb_stb = 0;
         cout << "cyc=" << setw(8) << setfill('0') << dec << main_time;
         cout << " ACK WR" << endl;
         reqPending = false;
      }

      if (!linkUp) {
         linkUp = m->rootp->top->host->omi_host->dlx_tlx_link_up;
         if (linkUp) {
            cout << "cyc=" << setw(8) << setfill('0') << dec << main_time;
            cout << " DL says link is up!" << endl;
         }
      }

      if (!tlReady) {
         tlReady = m->rootp->top->host->tl_ready;
         if (tlReady) {
            cout << "cyc=" << setw(8) << setfill('0') << dec << main_time;
            cout << " TL says ready!" << endl;
         }
      }

      if ((main_time > runCycles) & !quiescing) {
         cout << "Quiescing..." << endl;
         quiescing = 10;
      }

   }

#ifdef TRACING
   t->close();
#endif

   if (reqPending) {
      ok = false;
      cout << "Request is outstanding!" << endl;
   }

   cout << "Done." << endl;
   if (ok) {
      cout << endl << "You has opulence." << endl << endl;
   } else {
      cout << endl << "You are worthless and weak!" << endl << endl;
   }
   cout << "Seed=" << setw(8) << setfill('0') << hex << 0x8675309 << endl;

   m->final();

   exit(EXIT_SUCCESS);

}