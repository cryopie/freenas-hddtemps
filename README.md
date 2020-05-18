# freenas-hddtemps
View your HDD and SSD temperatures on multiple FreeNAS machines with a single script. 

### Usage

    freenas-hddtemps.sh -r [<host>]            # Show HDD (spinning rust)
    freenas-hddtemps.sh -s [<host>]            # Show SSD
    If <host> is missing, the script is executed on every host (one per line) from /etc/hddtemps.hosts
    This host must be able to SSH/SCP to the hosts in /etc/hddtemps.hosts

### Example output

Add your hosts to `/etc/hddtemps.hosts` and run the script:

    $ cat /etc/hddtemps.hosts
    host1
    host2
    
    $ freenas-hddtemps.sh -r
    
Output (`XXXXXXXX` are serial numbers): 
    
    Running on host1 ... 
    1.    ada1    WDC WD80EMAZ-00WJTA0    XXXXXXXX    5400 RPM    39 celsius
    2.    ada2    WDC WD80EMAZ-00WJTA0    XXXXXXXX    5400 RPM    42 celsius
    3.    da0     WDC WD80EZAZ-11TDBA0    XXXXXXXX    5400 RPM    28 celsius
    4.    da1     ST8000DM004-2CX188      XXXXXXXX    5425 RPM    28 celsius
    5.    da2     ST8000DM004-2CX188      XXXXXXXX    5425 RPM    26 celsius
    6.    da3     ST8000DM004-2CX188      XXXXXXXX    5425 RPM    29 celsius
    7.    da4     WDC WD80EZAZ-11TDBA0    XXXXXXXX    5400 RPM    30 celsius
    8.    da5     WDC WD80EMAZ-00WJTA0    XXXXXXXX    5400 RPM    31 celsius
    9.    da6     WDC WD80EZAZ-11TDBA0    XXXXXXXX    5400 RPM    31 celsius

    Running on host2 ... 
    1.     da0     WDC WD30EFRX-68EUZN0    XXXXXXXX   5400 RPM    38 celsius
    2.     da1     TOSHIBA DT01ACA300      XXXXXXXX   7200 RPM    41 celsius
    3.     da2     WDC WD30EZRX-00D8PB0    XXXXXXXX   5400 RPM    37 celsius
    4.     da3     TOSHIBA DT01ACA300      XXXXXXXX   7200 RPM    38 celsius
    5.     da4     ST3000DM001-1E6166      XXXXXXXX   7200 RPM    40 celsius
    6.     da5     ST3000DM007-1WY10G      XXXXXXXX   5425 RPM    39 celsius
    7.     da6     WDC WD30EZRX-00D8PB0    XXXXXXXX   5400 RPM    37 celsius
    8.     da7     WDC WD30EZRX-00D8PB0    XXXXXXXX   5400 RPM    37 celsius
    9.     ada4    ST3000VX009-2AY10G      XXXXXXXX   5425 RPM    41 celsius
    10.    ada3    TOSHIBA DT01ACA300      XXXXXXXX   7200 RPM    39 celsius
    11.    ada2    TOSHIBA DT01ACA300      XXXXXXXX   7200 RPM    42 celsius
    
