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

