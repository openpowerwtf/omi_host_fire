# OC Stuff

## Packet Decoder

### *by opcode*

| opcode | c/r | name | sender | desc | notes |
| -------- | - | ---------------- | --- | ------------------------------ | ------------------------------|
| 00 | c | nop | TL | |
| 00 | c | nop | TLx | |
| 00 | r | nop | TL | |
| 00 | r | nop | TLx | |
| 01 | r | return_tlx_credits | TL | add to TLx credits | * no credits req'd to send
| 01 | r | mem_rd_response| TLx | good read |
| 02 | r | mem_rd_fail | TLx | bad read |
| 04 | r | mem_wr_response | TLx | good write |
| 05 | r | mem_wr_fail | TLx | bad write |
| 08 | r | return_tl_credits | TLx | add to TL credits | * no credits req'd to send
| 28 | c | pr_rd_mem | TL | partial memory read |
| 86 | c | pr_wr_mem | TL | partial memory write |

### *by sender*

| opcode | c/r | name | sender | desc | notes |
| -------- | - | ---------------- | --- | ------------------------------ | ------------------------------|
| 00 | c | nop | TL | |
| 00 | r | nop | TL | |
| 01 | r | return_tlx_credits | TL | add to TLx credits | * no credits req'd to send
| 28 | c | pr_rd_mem | TL | partial memory read |
| 86 | c | pr_wr_mem | TL | partial memory write |
|||||||
| 00 | c | nop | TLx | |
| 00 | r | nop | TLx | |
| 01 | r | mem_rd_response| TLx | good read |
| 02 | r | mem_rd_fail | TLx | bad read |
| 04 | r | mem_wr_response | TLx | good write |
| 05 | r | mem_wr_fail | TLx | bad write |
| 08 | r | return_tl_credits | TLx | add to TL credits | * no credits req'd to send

## Credits

* held in framer (backwards terminology)

```
        // -----------------------------------
        // TLX Parser to TLX Framer Interface
        // -----------------------------------
        input              rcv_xmt_tl_credit_vc0_valid       ;  // TL credit for VC0,  to send to TL
        input              rcv_xmt_tl_credit_vc1_valid       ;  // TL credit for VC1,  to send to TL
        input              rcv_xmt_tl_credit_dcp0_valid      ;  // TL credit for DCP0, to send to TL
        input              rcv_xmt_tl_credit_dcp1_valid      ;  // TL credit for DCP1, to send to TL
        input              rcv_xmt_tl_crd_cfg_dcp1_valid     ;  // TL credit for DCP1, to send to TL

        input              rcv_xmt_tlx_credit_valid          ;  // Indicates there are valid TLX credits to capture and use
        input   [  3:0]    rcv_xmt_tlx_credit_vc0            ;  // TLX credit for VC0,  to be used by TLX
        input   [  3:0]    rcv_xmt_tlx_credit_vc3            ;  // TLX credit for VC3,  to be used by TLX
        input   [  5:0]    rcv_xmt_tlx_credit_dcp0           ;  // TLX credit for DCP0, to be used by TLX
        input   [  5:0]    rcv_xmt_tlx_credit_dcp3           ;  // TLX credit for DCP3, to be used by TLX
```

* VC/DCP

* virtual channels are for cmds/rsps; data credit pools are for immediate data

| vc | c/r | owner | consumer | desc | notes |
|-----|---|-----|-----|---------------------------------|--------------------------------|
| 0 | c | TLx | TL | commands from TL->TLx | unused (xlate, intrp) |
| 1 | c | TLx | TL | commands from TL->TLx | read, write |
| 0 | r | TLx | TL | responses from TL->TLx | unused (touch, DMA read/write, intrp, wake)
| 0 | r | TL | TLx | responses from TLx->TL | read, write |
| 3 | c | TL  | TLx | commands from TLx->TL | unused (n/c, acTag, intrp, wake, xlate) |

| dcp | c/r | owner | consumer | desc | notes |
|-----|---|-----|-----|---------------------------------|--------------------------------|
| 0 | r | TLx | TL | response data from TL->TLx | unused (DMA read)|
| 1 | c | TLx | TL | command data from TL->TLx | write |
| 0 | r | TL | TLx | response data from TLx->TL | read, write |
| 3 | c | TL  | TLx | command data from TLx->TL | unused (intrp) |

* credits maintained within TL logic (not in owner)

* initial credits passed when link up

* host read: tl vc1 -> tlx vc0/dcp0

* host write: tl vc1/dcp1 -> tlx vc0




