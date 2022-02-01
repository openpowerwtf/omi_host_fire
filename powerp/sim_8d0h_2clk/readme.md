# Sim

## add (2) omi_phygpio between DLs

### test 1

* 512d16h (512 data, 16 hdr per direction); 1:1 freq with TL/DL/WB

* need to deal with slip and phy init (to reset it) once pipeline stages added between DLs

* no changes to TL/DL

* made it through training but pending wb op is not moving

* fixed typo; lane 4 using lane 6 in one direction; now runs wb ops

### test 2

* 8d0h (8 data, 0 hdr per direction); 1:66 freq with TL/DL, 1:1 WB (OMI runs slow, PHY/SOC runs normal)

### test 3

* 8d0h, all 1:1, using rxvalid to throttle DL



