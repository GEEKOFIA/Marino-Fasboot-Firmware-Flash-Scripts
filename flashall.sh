#!/bin/bash +x

# test variable if set to 1 will only print not execute statements
TEST=0
E_BADARGS=1
host_name=$(uname)
para_flash=1
# terminal type: 0: non-gui, 1: gui
term_type=0
no_reboot=0

if [ "$host_name" != "Linux" -a "$host_name" != "Darwin" ]; then
	# Not Linux or Mac, assume Windows
	host_name=Windows
fi

fastboot=./"$host_name"/fastboot

function usage()
{
    echo "Usage: `basename $0` [serial_of_device]."
    echo "        Note: serial_of_device: the phone to be flashed. If there is no"
    echo "              device specified, all phones will be flashed parallelly."
    echo "   or: `basename $0` [-d device_serial] [-s]"
    echo "        Note:"
    echo "            -d: the device serial number to be flashed. If there is no"
    echo "                device specified, all phones will be flashed."
    echo "            -s: flash all phones one after one. If this option is not set,"
    echo "                all phone will be flashed parallelly."
    echo "   or: `basename $0` [no-reboot]."
    echo "        Note: After flashing all images donot execute fastboot reboot"
}

function check_terminal_type()
{
    if [ -z $DISPLAY ]; then
        term_type=0
    else
        term_type=1
    fi
}

function run()
{
   echo ""
   echo $*
   if [ ${TEST} -eq 0 ]
   then
      $*
   fi
}

function wait_for_device()
{
    device_searching=1
    device_time_count=0
    device_found=0
    if [ "$TEST" -eq "1" ];then
        echo " testing ... so not really looking device"
        device_found=1
        return 1
    fi
    while [[ "$device_searching" -ne "0" ]]
    do
        sleep 1
        dlist=""
        dlist+="$($fastboot devices | grep -v finished | grep -v waiting | grep -v Done | grep -v OKAY | grep -v "\.\.\." | sed -e "s/(bootloader)//g" -e "s/INFO//g" | cut -f1)"
        if [ -z "$dlist" ];then
            echo "Waiting for device, will recheck in one second"
        else
            # found devices need to look through them
            for device in $dlist; do
                if [ "$device" == "$1" ];then
                    echo "Found $1 device"
                    device_searching=0
                    device_found=1
                    return
                fi
            done

        fi

        if [ "$device_time_count" -eq "60" ];then
            echo "Time expired device not seen"
            device_searching=0
        fi
        device_time_count=$(($device_time_count+1))
    done

# note: you can accesss the variable device_found after function returns

}

function flash_single_phone()
{
    if [ ! $# -eq 1 ]; then
        echo "Only need to specify the phone serial number to be flashed on."
        exit $E_BADARGS
    fi

    serial_number=$1

    echo ">>flashing phone [$serial_number]"

    echo ""
    echo ">> Waiting for fastboot enumeration..."
    wait_for_device "$serial_number"

    if [ "$device_found" -eq "0" ]; then
        echo ">> Unable to find the device $serial_number"
        exit -1
    else
        echo ">> Found $serial_number device"
    fi

#    echo ""
#    echo ">> Flashing PGPT..."
#    run $fastboot -s "$serial_number" flash gpt PGPT
#    if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi

    echo ""
    echo ">> Flashing trustzone..."
    run $fastboot -s "$serial_number" flash tee1 trustzone.bin
    if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi

    echo ""
    echo ">> Flashing trustzone..."
    run $fastboot -s "$serial_number" flash tee2 trustzone.bin
    if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi

    echo ""
    echo ">> Flashing modem image..."
    run $fastboot -s "$serial_number" flash md1img md1rom.img
    if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi
    run $fastboot -s "$serial_number" flash md1dsp md1dsp.img
    if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi
    run $fastboot -s "$serial_number" flash md1arm7 md1arm7.img
    if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi
    run $fastboot -s "$serial_number" flash md3img md3rom.img
    if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi

    echo ""
    echo ">> Flashing preloader..."
    run $fastboot -s "$serial_number" flash preloader preloader.img
    if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi

    echo ""
    echo ">> Flashing lk..."
    run $fastboot -s "$serial_number" flash lk lk.bin
    if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi
    run $fastboot -s "$serial_number" flash lk2 lk.bin
    if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi

#    echo ""
#    echo ">> Rebooting bootloader..."
#    run $fastboot -s "$serial_number" reboot-bootloader
#    wait_for_device "$serial_number"

#    echo ""
#    echo ">> Flashing AP images..."


    run $fastboot -s "$serial_number" flash logo logo.bin
    if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi

    run $fastboot -s "$serial_number" flash boot boot.img
    if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi

    run $fastboot -s "$serial_number" flash recovery recovery.img
    if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi

    run $fastboot -s "$serial_number" flash system system.img
    if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi

    if [ -e oem.img ]; then
        run $fastboot -s "$serial_number" flash oem oem.img
        if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi
    fi

    if [ -e cache.img ]; then
        run $fastboot -s "$serial_number" flash cache cache.img
        if [ $? -ne 0 ]; then
            echo "ERROR: fastboot flash cache failed."
            echo "Now format cache..."
            run $fastboot -s "$serial_number" format cache
        fi
    fi

    if [ -e userdata.img ]; then
        run $fastboot -s "$serial_number" flash userdata serdata.img
        if [ $? -ne 0 ]; then
            echo "ERROR: fastboot flash userdata failed."
            echo "Now format userdata..."
            run $fastboot -s "$serial_number" format userdata
        fi
    fi
#    if [ -x ./hwflash.sh ]; then
#        saved_hwlock=$($fastboot -s "$serial_number" oem hw status 2>&1 | grep utags | cut -f5 -d' ')
#        if [ "$saved_hwlock" == "locked" ]; then run $fastboot -s "$serial_number" oem hw unlock; fi

#        current_hwlock=$($fastboot -s "$serial_number" oem hw status 2>&1 | grep utags | cut -f5 -d' ')
#        if [ "$current_hwlock" == "unlocked" ]; then
#            run ./hwflash.sh "$serial_number"
#            if [ $? -ne 0 ]; then
#                echo "ERROR: hw descriptor failure";
#                if [ "$saved_hwlock" == "locked" ]; then run $fastboot -s "$serial_number" oem hw lock; fi
#                exit -1;
#            fi
#        fi

#        if [ "$saved_hwlock" == "locked" ]; then run $fastboot -s "$serial_number" oem hw lock; fi
#    fi

    #echo ""
    #echo ">> clearing boot mode..."
    #run $fastboot -s "$serial_number" oem config unset bootmode

    # check if the device is flashed with factory software
#    fingerprint=$($fastboot -s "$serial_number" getvar ro.build.fingerprint 2>&1 >/dev/null)
#    if [ -n "$fingerprint" ]; then
#        if echo "$fingerprint" | grep -q "factory" ; then
#                echo "[WARNING] FACTORY SOFTWARE LOADED."
#                echo "PLEASE ERASE USERDATA"
#                echo "use \"fastboot erase userdata\" command to erase userdata"
#                sleep 5
#        fi
#    fi

    echo ""
    echo ">> All images flashed on $serial_number successfully!"
    echo ""
    if [ $no_reboot -eq 0 ]; then
        echo "Rebooting phone now..."
        run $fastboot -s "$serial_number" reboot
    fi

    return 0
}

function get_device_count()
{
    device_count=0
    for device in $*; do
        device_count=$(($device_count+1))
    done
    return $device_count
}

function flash_phone()
{
    local x   # x coordinate where the xterm window should be placed
    local y   # y coordinate where the xterm window should be placed
    local i   # device index we are currently flashing

    y=0
    x=0
    i=0

    for device in $*; do
        if [ $para_flash -eq 0 ]; then
            # flash the phone one by one
            flash_single_phone $device
            if [ $? -eq -1 ]; then
                echo "Failed to flash the phone $device"
            fi
        else
            # flash phone in a new terminal
            if [ "$host_name" == "Darwin" ]; then
                x=$(expr $i % 2)            # 2 windows per row
                x=$(expr $x \* 490 + 165)   # space windows every 490 pixels, starting at pixel 165
                y=$(expr $i / 2)            # 2 windows per row
                y=$(expr $y \* 200)         # space rows every 200 pixels, starting at pixel 0

                xterm -geometry 80x13+$x+$y -title "flashing $device..." -e bash -c "cd `pwd`; pwd; $0 -d $device; echo -n \"Press any key to exit...\"; read -n 1 -s" &

                i=$(expr $i + 1)
            else
                gnome-terminal -t "flashing $device..." -x bash -c "$0 -d $device; echo -n \"Press any key to exit...\"; read -n 1 -s"
            fi
        fi
    done
}

echo ""
echo "Motorola Mobility flashing station script version 2.1"
echo ""

device_number=""

if [ $# -gt 4 ]; then
    echo "To many arguments:"
    usage
    exit $E_BADARGS
fi

# parse the parameters
if [ $# -eq 1 -a "$1" != "-d" -a "$1" != "-s" -a "$1" != "no-reboot" ]; then
    device_number=$1
else
    while [ $# -gt 0 ]; do
        if [ "$1" == "-s" ]; then
            para_flash=0
            shift
        elif [ "$1" == "no-reboot" ]; then
            no_reboot=1
            shift
        elif [ "$1" == "-d" ]; then
            if [ $# -lt 2 -o "$2" == "-s" -o "$2" == "no-reboot" ]; then
                usage
                exit $E_BADARGS
            fi
            device_number=$2
            shift 2
        else
            # no handler for single parameter without "-x"
            usage
            exit $E_BADARGS
        fi
    done
fi

# check whether it's under GUI terminal
check_terminal_type

if [ $term_type -eq 0 ]; then
    echo "Not detect GUI terminal, disable parallel flash"
    para_flash=0
fi

# Allow time for fastboot enumeration to stablize
sleep 2

if [ -z $device_number ]; then
    # no device specified, flash all connected devices
    dlist=""
    dlist+="$($fastboot devices | grep -v finished | grep -v waiting | grep -v Done | grep -v OKAY | grep -v "\.\.\." | sed -e "s/(bootloader)//g" -e "s/INFO//g" | cut -f1)"
    if [ -z "$dlist" ];then
        echo "No devices where found!"
        exit $E_BADARGS
    fi

    # check device count
    get_device_count $dlist
    if [ $? -eq 1 ]; then
        flash_single_phone $dlist
    else
        flash_phone $dlist
    fi
else
    flash_single_phone $device_number
    if [ $? -eq -1 ]; then
        echo "Failed to flash phone $device_number"
        exit -1
    fi
fi

exit 0
