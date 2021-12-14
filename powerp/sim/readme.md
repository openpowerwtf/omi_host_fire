# Sim

## add (2) omi_phygpio between DLs

### test 1

* 512d16h (512 data, 16 hdr per direction); 1:1 freq with TL/DL/WB

* need to deal with slip and phy init (to reset it) once pipeline stages added between DLs

* no changes to TL/DL

* made it through training but pending wb op is not moving

* fixed typo; lane 4 using lane 6 in one direction; now runs wb ops

### test 2

* 8d1h (8 data, 1 hdr per direction); 1:64 freq with TL/DL/WB (all clk slow except for PHY)




### test 3

* 8d1h; 1:1 with WB, 1:64 with TL/DL (SOC clk with bitrate-matched OMI)











