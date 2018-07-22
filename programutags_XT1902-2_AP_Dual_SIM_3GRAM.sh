#!/bin/bash

# test variable if set to 1 will only print not execute statements
TEST=0
E_BADARGS=1
host_name=$(uname)

if [ "$host_name" != "Linux" -a "$host_name" != "Darwin" ]; then
	# Not Linux or Mac, assume Windows
	host_name=Windows
fi

fastboot=./"$host_name"/fastboot

function run()
{
   echo ""
   echo $*
   if [ ${TEST} -eq 0 ]
   then
      $*
   fi
}

echo ""
echo "Motorola Mobility UTAG programming script"
echo "This script programs the following UTAGs: fsg-id and carrier."
echo ""

# Allow time for fastboot enumeration to stablize
sleep 2

if [ ! -n "$1" ]; then
    dlist=""
    dlist+="$($fastboot devices | grep -v finished | grep -v waiting | grep -v Done | grep -v OKAY | grep -v "\.\.\." | sed -e "s/(bootloader)//g" -e "s/INFO//g" | cut -f1)"
    if [ -z "$dlist" ];then
        echo "No devices where found!"
        exit $E_BADARGS
    fi
    device_count=0
    for device in $dlist; do
        device_count=$(($device_count + 1))
    done

    if [ $device_count -eq 1 ];then
       serial_number=$dlist
       echo "serial number not passed but found one device to flash"
    else
       echo "To many choices please use serial otherwise remove other devices"
       echo "Usage: `basename $0` serial_of_device."
       exit $E_BADARGS
    fi
else
    serial_number=$1
fi

if [ -n "$2" ]; then
    echo "To many arguments:"
    echo "Usage: `basename $0` serial_of_device."
    exit $E_BADARGS
fi

sku="XT1902-2"
radio="India"
ram="3GB"
storage="32GB"
dualsim="true"
num_sims="2"
imager="13MP"
fps="true"
dtv="false"
nfc="false"
frontcolor=""
display=""


PS3='Please select Carrier: '
options=("Retail APAC-retapac" "Retail India-retin" "Retail Indonesia-retid" "Quit")
select opt in "${options[@]}"
	do
		case $opt in
		"Retail APAC-retapac")
			carrier="retapac"
			break
			;;
		"Retail India-retin")
			carrier="retin"
			break
			;;
		"Retail Indonesia-retid")
			carrier="retid"
			break
			;;
		"Quit")
			break
			;;
		*) echo invalid option;;
	esac
done

if [ "$carrier" == "" ]; then
    echo ""
    echo ">> EXIT: Carrier config not executed"
    exit 1
fi

echo ""
echo ">> Programming [$serial_number]"

echo ""
echo ">> Setting carrier..."
run $fastboot -s "$serial_number" oem hw radio $radio
if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi

echo ""
echo ">> Setting ram..."
run $fastboot -s "$serial_number" oem hw ram $ram
if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi

echo ""
echo ">> Setting storage..."
run $fastboot -s "$serial_number" oem hw storage $storage
if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi

echo ""
echo ">> Setting dualsim..."
run $fastboot -s "$serial_number" oem hw dualsim $dualsim
if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi

echo ""
echo ">> Setting fps..."
run $fastboot -s "$serial_number" oem hw fps $fps
if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi

echo ""
echo ">> Setting dtv..."
run $fastboot -s "$serial_number" oem hw dtv $dtv
if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi

echo ""
echo ">> Setting nfc..."
run $fastboot -s "$serial_number" oem hw nfc $nfc
if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi

echo ""
echo ">> Setting frontcolor..."
run $fastboot -s "$serial_number" oem hw frontcolor $frontcolor
if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi

echo ""
echo ">> Setting display..."
run $fastboot -s "$serial_number" oem config display $display
if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi

echo ""
echo ">> Setting sku..."
run $fastboot -s "$serial_number" oem config sku $sku
if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi

echo ""
echo ">> Setting num-sims..."
run $fastboot -s "$serial_number" oem config num-sims $num_sims
if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi


echo ""
if [ "$fsg_model" ]; then
    echo ">> Setting fsg-id..."
    run $fastboot -s "$serial_number" oem config fsg-id $fsg_model
else
    echo ">> Erasing fsg-id..."
    $fastboot -s "$serial_number" oem config fsg-id ""
fi
if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi

echo ""
echo ">> Setting carrier..."
run $fastboot -s "$serial_number" oem config carrier $carrier
if [ $? -ne 0 ]; then echo "ERROR: fastboot failed."; exit -1; fi


echo ""
echo ">> All UTAGs programmed successfully!"
exit 0
