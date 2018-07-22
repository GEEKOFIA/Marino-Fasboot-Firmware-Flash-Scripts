#!/bin/bash +x
# This script was auto-generated on Thu Sep 28 03:09:19 2017
# Python version 2.7.5
# ('Linux', 'ilclbld86', '4.2.0-42-generic', '#49~14.04.1-Ubuntu SMP Wed Jun 29 20:22:11 UTC 2016', 'x86_64', 'x86_64')
# Source validation file  'device/moto/mot6757/hw_descriptor/vhw.xml'
# TARGET_PRODUCT=marino_retail BUILD_ID=NMC26.74-31

flash_hw_brady() {
	echo "start flashing brady"
	echo "validation file version: [1.0]"
	echo "hw version: [$version]"
	if [ "$version" == "1.0" ]
	then
		echo "Version match no need to upgrade"
		exit 0
	fi
	echo "Version does not match, upgrading"
	$fastboot oem hw +.features 2> /dev/null
	$fastboot oem hw .features 'radio,ram,storage,dualsim,imager,fps,dtv,nfc,e'
	[ $? != "0" ] && err_out_lnx "add data for .features"
	$fastboot oem hw .features +'compass,frontcolor'
	[ $? != "0" ] && err_out_lnx "add more data for .features"

	$fastboot oem hw +.attributes 2> /dev/null
	$fastboot oem hw .attributes '.range,.cmdline,.chosen,.system,.auto'
	[ $? != "0" ] && err_out_lnx "add data for .attributes"

	echo "start creating requested utags"
	$fastboot oem hw +dtv 2> /dev/null
	$fastboot oem hw +dtv/.auto 2> /dev/null
	$fastboot oem hw +dtv/.chosen 2> /dev/null
	$fastboot oem hw +dtv/.range 2> /dev/null
	$fastboot oem hw +dtv/.system 2> /dev/null
	$fastboot oem hw +dualsim 2> /dev/null
	$fastboot oem hw +dualsim/.auto 2> /dev/null
	$fastboot oem hw +dualsim/.cmdline 2> /dev/null
	$fastboot oem hw +dualsim/.range 2> /dev/null
	$fastboot oem hw +dualsim/.system 2> /dev/null
	$fastboot oem hw +ecompass 2> /dev/null
	$fastboot oem hw +ecompass/.auto 2> /dev/null
	$fastboot oem hw +ecompass/.chosen 2> /dev/null
	$fastboot oem hw +ecompass/.range 2> /dev/null
	$fastboot oem hw +ecompass/.system 2> /dev/null
	$fastboot oem hw +fps 2> /dev/null
	$fastboot oem hw +fps/.auto 2> /dev/null
	$fastboot oem hw +fps/.chosen 2> /dev/null
	$fastboot oem hw +fps/.range 2> /dev/null
	$fastboot oem hw +fps/.system 2> /dev/null
	$fastboot oem hw +frontcolor 2> /dev/null
	$fastboot oem hw +frontcolor/.auto 2> /dev/null
	$fastboot oem hw +frontcolor/.range 2> /dev/null
	$fastboot oem hw +frontcolor/.system 2> /dev/null
	$fastboot oem hw +imager 2> /dev/null
	$fastboot oem hw +imager/.auto 2> /dev/null
	$fastboot oem hw +imager/.chosen 2> /dev/null
	$fastboot oem hw +imager/.range 2> /dev/null
	$fastboot oem hw +imager/.system 2> /dev/null
	$fastboot oem hw +nfc 2> /dev/null
	$fastboot oem hw +nfc/.auto 2> /dev/null
	$fastboot oem hw +nfc/.chosen 2> /dev/null
	$fastboot oem hw +nfc/.range 2> /dev/null
	$fastboot oem hw +nfc/.system 2> /dev/null
	$fastboot oem hw +radio 2> /dev/null
	$fastboot oem hw +radio/.auto 2> /dev/null
	$fastboot oem hw +radio/.cmdline 2> /dev/null
	$fastboot oem hw +radio/.range 2> /dev/null
	$fastboot oem hw +ram 2> /dev/null
	$fastboot oem hw +ram/.auto 2> /dev/null
	$fastboot oem hw +ram/.range 2> /dev/null
	$fastboot oem hw +ram/.system 2> /dev/null
	$fastboot oem hw +storage 2> /dev/null
	$fastboot oem hw +storage/.auto 2> /dev/null
	$fastboot oem hw +storage/.range 2> /dev/null
	$fastboot oem hw +storage/.system 2> /dev/null
	echo "done creating requested utags"

	$fastboot oem hw dtv/.auto 'default=false'
	[ $? != "0" ] && err_out_lnx "add data for dtv/.auto"

	$fastboot oem hw dtv/.chosen 'mmi,'
	[ $? != "0" ] && err_out_lnx "add data for dtv/.chosen"

	$fastboot oem hw dtv/.range 'false,true'
	[ $? != "0" ] && err_out_lnx "add data for dtv/.range"

	$fastboot oem hw dtv/.system 'ro.hw.'
	[ $? != "0" ] && err_out_lnx "add data for dtv/.system"

	$fastboot oem hw dualsim/.auto 'default=false'
	[ $? != "0" ] && err_out_lnx "add data for dualsim/.auto"

	$fastboot oem hw dualsim/.cmdline 'androidboot.'
	[ $? != "0" ] && err_out_lnx "add data for dualsim/.cmdline"

	$fastboot oem hw dualsim/.range 'false,true'
	[ $? != "0" ] && err_out_lnx "add data for dualsim/.range"

	$fastboot oem hw dualsim/.system 'ro.hw.'
	[ $? != "0" ] && err_out_lnx "add data for dualsim/.system"

	$fastboot oem hw ecompass/.auto 'default=true'
	[ $? != "0" ] && err_out_lnx "add data for ecompass/.auto"

	$fastboot oem hw ecompass/.chosen 'mmi,'
	[ $? != "0" ] && err_out_lnx "add data for ecompass/.chosen"

	$fastboot oem hw ecompass/.range 'true,false'
	[ $? != "0" ] && err_out_lnx "add data for ecompass/.range"

	$fastboot oem hw ecompass/.system 'ro.hw.'
	[ $? != "0" ] && err_out_lnx "add data for ecompass/.system"

	$fastboot oem hw fps/.auto 'key=hwid;index=2;map=1:true,2:false,3:false'
	[ $? != "0" ] && err_out_lnx "add data for fps/.auto"

	$fastboot oem hw fps/.chosen 'mmi,'
	[ $? != "0" ] && err_out_lnx "add data for fps/.chosen"

	$fastboot oem hw fps/.range 'true,false'
	[ $? != "0" ] && err_out_lnx "add data for fps/.range"

	$fastboot oem hw fps/.system 'ro.hw.'
	[ $? != "0" ] && err_out_lnx "add data for fps/.system"

	$fastboot oem hw frontcolor/.auto 'uspace=config;name=build_vars;map=BLACK'
	[ $? != "0" ] && err_out_lnx "add data for frontcolor/.auto"
	$fastboot oem hw frontcolor/.auto +':black,GOLD:gold,black:black,gold:gold'
	[ $? != "0" ] && err_out_lnx "add more data for frontcolor/.auto"

	$fastboot oem hw frontcolor/.range 'gold,black,other'
	[ $? != "0" ] && err_out_lnx "add data for frontcolor/.range"

	$fastboot oem hw frontcolor/.system 'ro.hw.'
	[ $? != "0" ] && err_out_lnx "add data for frontcolor/.system"

	$fastboot oem hw imager/.auto 'default=8MP'
	[ $? != "0" ] && err_out_lnx "add data for imager/.auto"

	$fastboot oem hw imager/.chosen 'mmi,'
	[ $? != "0" ] && err_out_lnx "add data for imager/.chosen"

	$fastboot oem hw imager/.range '8MP'
	[ $? != "0" ] && err_out_lnx "add data for imager/.range"

	$fastboot oem hw imager/.system 'ro.hw.'
	[ $? != "0" ] && err_out_lnx "add data for imager/.system"

	$fastboot oem hw nfc/.auto 'default=false'
	[ $? != "0" ] && err_out_lnx "add data for nfc/.auto"

	$fastboot oem hw nfc/.chosen 'mmi,'
	[ $? != "0" ] && err_out_lnx "add data for nfc/.chosen"

	$fastboot oem hw nfc/.range 'false,true'
	[ $? != "0" ] && err_out_lnx "add data for nfc/.range"

	$fastboot oem hw nfc/.system 'ro.hw.'
	[ $? != "0" ] && err_out_lnx "add data for nfc/.system"

	$fastboot oem hw radio/.auto 'key=hwid;index=2;map=1:LATAM,2:EMEA,3:India,'
	[ $? != "0" ] && err_out_lnx "add data for radio/.auto"
	$fastboot oem hw radio/.auto +'4:APAC'
	[ $? != "0" ] && err_out_lnx "add more data for radio/.auto"

	$fastboot oem hw radio/.cmdline 'androidboot.'
	[ $? != "0" ] && err_out_lnx "add data for radio/.cmdline"

	$fastboot oem hw radio/.range 'LATAM,EMEA,India,APAC'
	[ $? != "0" ] && err_out_lnx "add data for radio/.range"

	$fastboot oem hw ram/.auto 'key=hwprobe;index=__ram'
	[ $? != "0" ] && err_out_lnx "add data for ram/.auto"

	$fastboot oem hw ram/.range '2GB,3GB,4GB'
	[ $? != "0" ] && err_out_lnx "add data for ram/.range"

	$fastboot oem hw ram/.system 'ro.hw.'
	[ $? != "0" ] && err_out_lnx "add data for ram/.system"

	$fastboot oem hw storage/.auto 'key=hwprobe;index=__storage'
	[ $? != "0" ] && err_out_lnx "add data for storage/.auto"

	$fastboot oem hw storage/.range '16GB,32GB,64GB'
	[ $? != "0" ] && err_out_lnx "add data for storage/.range"

	$fastboot oem hw storage/.system 'ro.hw.'
	[ $? != "0" ] && err_out_lnx "add data for storage/.system"

	echo "finished configuring brady, set version"
	$fastboot oem hw .version 1.0
	[ $? != "0" ] && err_out_lnx "set .version"
	echo "version set"
}

flash_hw_marino() {
	echo "start flashing marino"
	echo "validation file version: [1.1]"
	echo "hw version: [$version]"
	if [ "$version" == "1.1" ]
	then
		echo "Version match no need to upgrade"
		exit 0
	fi
	echo "Version does not match, upgrading"
	$fastboot oem hw +.features 2> /dev/null
	$fastboot oem hw .features 'radio,ram,storage,dualsim,imager,fps,dtv,nfc,e'
	[ $? != "0" ] && err_out_lnx "add data for .features"
	$fastboot oem hw .features +'compass,frontcolor'
	[ $? != "0" ] && err_out_lnx "add more data for .features"

	$fastboot oem hw +.attributes 2> /dev/null
	$fastboot oem hw .attributes '.range,.cmdline,.chosen,.system,.auto'
	[ $? != "0" ] && err_out_lnx "add data for .attributes"

	echo "start creating requested utags"
	$fastboot oem hw +dtv 2> /dev/null
	$fastboot oem hw +dtv/.auto 2> /dev/null
	$fastboot oem hw +dtv/.chosen 2> /dev/null
	$fastboot oem hw +dtv/.range 2> /dev/null
	$fastboot oem hw +dtv/.system 2> /dev/null
	$fastboot oem hw +dualsim 2> /dev/null
	$fastboot oem hw +dualsim/.auto 2> /dev/null
	$fastboot oem hw +dualsim/.cmdline 2> /dev/null
	$fastboot oem hw +dualsim/.range 2> /dev/null
	$fastboot oem hw +dualsim/.system 2> /dev/null
	$fastboot oem hw +ecompass 2> /dev/null
	$fastboot oem hw +ecompass/.auto 2> /dev/null
	$fastboot oem hw +ecompass/.chosen 2> /dev/null
	$fastboot oem hw +ecompass/.range 2> /dev/null
	$fastboot oem hw +ecompass/.system 2> /dev/null
	$fastboot oem hw +fps 2> /dev/null
	$fastboot oem hw +fps/.auto 2> /dev/null
	$fastboot oem hw +fps/.chosen 2> /dev/null
	$fastboot oem hw +fps/.range 2> /dev/null
	$fastboot oem hw +fps/.system 2> /dev/null
	$fastboot oem hw +frontcolor 2> /dev/null
	$fastboot oem hw +frontcolor/.auto 2> /dev/null
	$fastboot oem hw +frontcolor/.range 2> /dev/null
	$fastboot oem hw +frontcolor/.system 2> /dev/null
	$fastboot oem hw +imager 2> /dev/null
	$fastboot oem hw +imager/.auto 2> /dev/null
	$fastboot oem hw +imager/.chosen 2> /dev/null
	$fastboot oem hw +imager/.range 2> /dev/null
	$fastboot oem hw +imager/.system 2> /dev/null
	$fastboot oem hw +nfc 2> /dev/null
	$fastboot oem hw +nfc/.auto 2> /dev/null
	$fastboot oem hw +nfc/.chosen 2> /dev/null
	$fastboot oem hw +nfc/.range 2> /dev/null
	$fastboot oem hw +nfc/.system 2> /dev/null
	$fastboot oem hw +radio 2> /dev/null
	$fastboot oem hw +radio/.auto 2> /dev/null
	$fastboot oem hw +radio/.cmdline 2> /dev/null
	$fastboot oem hw +radio/.range 2> /dev/null
	$fastboot oem hw +ram 2> /dev/null
	$fastboot oem hw +ram/.auto 2> /dev/null
	$fastboot oem hw +ram/.range 2> /dev/null
	$fastboot oem hw +ram/.system 2> /dev/null
	$fastboot oem hw +storage 2> /dev/null
	$fastboot oem hw +storage/.auto 2> /dev/null
	$fastboot oem hw +storage/.range 2> /dev/null
	$fastboot oem hw +storage/.system 2> /dev/null
	echo "done creating requested utags"

	$fastboot oem hw dtv/.auto 'default=false'
	[ $? != "0" ] && err_out_lnx "add data for dtv/.auto"

	$fastboot oem hw dtv/.chosen 'mmi,'
	[ $? != "0" ] && err_out_lnx "add data for dtv/.chosen"

	$fastboot oem hw dtv/.range 'false,true'
	[ $? != "0" ] && err_out_lnx "add data for dtv/.range"

	$fastboot oem hw dtv/.system 'ro.hw.'
	[ $? != "0" ] && err_out_lnx "add data for dtv/.system"

	$fastboot oem hw dualsim/.auto 'default=false'
	[ $? != "0" ] && err_out_lnx "add data for dualsim/.auto"

	$fastboot oem hw dualsim/.cmdline 'androidboot.'
	[ $? != "0" ] && err_out_lnx "add data for dualsim/.cmdline"

	$fastboot oem hw dualsim/.range 'true,false'
	[ $? != "0" ] && err_out_lnx "add data for dualsim/.range"

	$fastboot oem hw dualsim/.system 'ro.hw.'
	[ $? != "0" ] && err_out_lnx "add data for dualsim/.system"

	$fastboot oem hw ecompass/.auto 'default=true'
	[ $? != "0" ] && err_out_lnx "add data for ecompass/.auto"

	$fastboot oem hw ecompass/.chosen 'mmi,'
	[ $? != "0" ] && err_out_lnx "add data for ecompass/.chosen"

	$fastboot oem hw ecompass/.range 'true,false'
	[ $? != "0" ] && err_out_lnx "add data for ecompass/.range"

	$fastboot oem hw ecompass/.system 'ro.hw.'
	[ $? != "0" ] && err_out_lnx "add data for ecompass/.system"

	$fastboot oem hw fps/.auto 'key=hwid;index=2;map=1:true,2:false,3:false'
	[ $? != "0" ] && err_out_lnx "add data for fps/.auto"

	$fastboot oem hw fps/.chosen 'mmi,'
	[ $? != "0" ] && err_out_lnx "add data for fps/.chosen"

	$fastboot oem hw fps/.range 'true,false'
	[ $? != "0" ] && err_out_lnx "add data for fps/.range"

	$fastboot oem hw fps/.system 'ro.hw.'
	[ $? != "0" ] && err_out_lnx "add data for fps/.system"

	$fastboot oem hw frontcolor/.auto 'uspace=config;name=build_vars;map=BLACK'
	[ $? != "0" ] && err_out_lnx "add data for frontcolor/.auto"
	$fastboot oem hw frontcolor/.auto +':black,GOLD:gold,black:black,gold:gold'
	[ $? != "0" ] && err_out_lnx "add more data for frontcolor/.auto"

	$fastboot oem hw frontcolor/.range 'gold,black,other'
	[ $? != "0" ] && err_out_lnx "add data for frontcolor/.range"

	$fastboot oem hw frontcolor/.system 'ro.hw.'
	[ $? != "0" ] && err_out_lnx "add data for frontcolor/.system"

	$fastboot oem hw imager/.auto 'default=13MP'
	[ $? != "0" ] && err_out_lnx "add data for imager/.auto"

	$fastboot oem hw imager/.chosen 'mmi,'
	[ $? != "0" ] && err_out_lnx "add data for imager/.chosen"

	$fastboot oem hw imager/.range '13MP'
	[ $? != "0" ] && err_out_lnx "add data for imager/.range"

	$fastboot oem hw imager/.system 'ro.hw.'
	[ $? != "0" ] && err_out_lnx "add data for imager/.system"

	$fastboot oem hw nfc/.auto 'default=false'
	[ $? != "0" ] && err_out_lnx "add data for nfc/.auto"

	$fastboot oem hw nfc/.chosen 'mmi,'
	[ $? != "0" ] && err_out_lnx "add data for nfc/.chosen"

	$fastboot oem hw nfc/.range 'false,true'
	[ $? != "0" ] && err_out_lnx "add data for nfc/.range"

	$fastboot oem hw nfc/.system 'ro.hw.'
	[ $? != "0" ] && err_out_lnx "add data for nfc/.system"

	$fastboot oem hw radio/.auto 'key=hwid;index=2;map=1:LATAM,2:EMEA,3:India'
	[ $? != "0" ] && err_out_lnx "add data for radio/.auto"

	$fastboot oem hw radio/.cmdline 'androidboot.'
	[ $? != "0" ] && err_out_lnx "add data for radio/.cmdline"

	$fastboot oem hw radio/.range 'LATAM,EMEA,India'
	[ $? != "0" ] && err_out_lnx "add data for radio/.range"

	$fastboot oem hw ram/.auto 'key=hwprobe;index=__ram'
	[ $? != "0" ] && err_out_lnx "add data for ram/.auto"

	$fastboot oem hw ram/.range '2GB,3GB,4GB'
	[ $? != "0" ] && err_out_lnx "add data for ram/.range"

	$fastboot oem hw ram/.system 'ro.hw.'
	[ $? != "0" ] && err_out_lnx "add data for ram/.system"

	$fastboot oem hw storage/.auto 'key=hwprobe;index=__storage'
	[ $? != "0" ] && err_out_lnx "add data for storage/.auto"

	$fastboot oem hw storage/.range '16GB,32GB,64GB'
	[ $? != "0" ] && err_out_lnx "add data for storage/.range"

	$fastboot oem hw storage/.system 'ro.hw.'
	[ $? != "0" ] && err_out_lnx "add data for storage/.system"

	echo "finished configuring marino, set version"
	$fastboot oem hw .version 1.1
	[ $? != "0" ] && err_out_lnx "set .version"
	echo "version set"
}

# print error message, and exit
function err_out_lnx () {
        echo "hw descriptor error [$1], exit"
        exit 1
}

# print warning message
function err_lnx () {
        echo "hw descriptor warning $1"
}

# backup hw partition
function backup_hw () {
        echo "hw descriptor creating hw partition backup"
        $fastboot oem partition dump hw
}

echo "my working directory is [$PWD]"
host_name=$(uname)

if [ "$host_name" != "Linux" -a "$host_name" != "Darwin" ]; then
        echo "host type [$host_name], defaulting to Windows"
        host_name="Windows"
fi

if [ -e ./"$host_name"/fastboot ]; then
        fastboot=./"$host_name"/fastboot
else
        echo "preferred fastboot [./"$host_name"/fastboot] does not exist"
        fastboot=fastboot
        echo "looking for [$fastboot] in PATH"
        which fastboot
        [ $? != "0" ] && err_out_lnx "no fastboot executable found"
fi

device_count=$($fastboot devices | grep fastboot | wc -l)
if [ $device_count -eq 0 ]; then
	echo "No fastboot devices, $0 is going to exit"
	exit 1
fi

if [ -z $1 ] && [ $device_count -gt 1 ]; then
	echo "There are $device_count fastboot devices"
	echo "serial number parameter is required in this case:"
	echo "$0 <serial number>"
	exit 1
fi

if [ -z $1 ]; then
	serial_option=""
else
	serial_option=" -s "$1
fi

fastboot=$fastboot$serial_option
echo "$0 is using [$fastboot] command"

devices=(
	brady
	marino
)

$fastboot getvar product 2> /dev/null
[ $? != "0" ] && err_out_lnx "read product suffix"
suffix=$($fastboot getvar product 2>&1 | grep product | cut -d ' ' -f 2 | tr '[:upper:]' '[:lower:]')
[ -z "$suffix" ] && err_out_lnx "got empty product suffix"
echo "product is [$suffix], available configurations:"
printf '\t%s\n' "${devices[@]}"
for n in "${devices[@]}"; do
	if [[ $suffix == *"$n"* ]]; then
		echo "match $n"
		target_function=flash_hw_$n
		echo "target function is $target_function"
	fi
done
if [ -z ${target_function} ]; then
	echo "No matching configuration, exit"
	exit 1
fi
$fastboot oem hw +.version 2>&1 | grep -v OKAY | grep -v finished | grep .version
[ $? != "0" ] && err_lnx "add .version"
$fastboot oem hw .version 2> /dev/null
[ $? != "0" ] && err_out_lnx "get .version"
version=$($fastboot oem hw .version 2>&1 | grep -v OKAY | grep -v finished | grep .version | cut -d' ' -f3)
echo "device hw descriptor version is [$version]"
eval $target_function
