@ECHO OFF
SETLOCAL EnableDelayedExpansion
SET preferred_fastboot=Windows\fastboot.exe
SET backup_fastboot=fastboot.exe
REM This script was auto-generated on Thu Sep 28 03:09:19 2017
REM Python version 2.7.5
REM ('Linux', 'ilclbld86', '4.2.0-42-generic', '#49~14.04.1-Ubuntu SMP Wed Jun 29 20:22:11 UTC 2016', 'x86_64', 'x86_64')
REM Source validation file  'device/moto/mot6757/hw_descriptor/vhw.xml'
REM TARGET_PRODUCT=marino_retail BUILD_ID=NMC26.74-31
ECHO:my working directory is [%CD%]
CALL :fastboot_path
IF %errorlevel% NEQ 0 (
	ECHO hw descriptor error: fastboot_path has failed, exit
	EXIT /B 1
)
CALL :count_devices
IF %errorlevel% NEQ 0 (
	ECHO hw descriptor error: count_devices has failed, exit
	EXIT /B 1
)
CALL :check_serial %1
IF %errorlevel% NEQ 0 (
	ECHO hw descriptor error: check_serial has failed, exit
	EXIT /B 1
)

%fastboot% getvar product
IF %errorlevel% NEQ 0 (
	ECHO hw descriptor error: get product name has failed, exit
	EXIT /B 1
)
FOR /F "tokens=2" %%X in ('%fastboot% getvar product 2^>^&1 ^| FINDSTR product') DO (SET suffix=%%X)
IF "%suffix%"=="" ECHO.%~n0: Error: empty product name & EXIT /B 1
ECHO product is [%suffix%]
%fastboot% oem hw +.version > NUL 2>&1
FOR /F "tokens=3" %%X in ('%fastboot% oem hw .version 2^>^&1 ^| FINDSTR bootloader') DO (SET version=%%X)
IF "%version%"=="" SET version=NONE
ECHO device hw descriptor version is [%version%]
SET hw_found=0
IF NOT "%suffix:brady=%"=="%suffix%" GOTO flash_hw_brady
IF NOT "%suffix:marino=%"=="%suffix%" GOTO flash_hw_marino
IF %errorlevel% NEQ 0 (
	ECHO hw descriptor error: flash_hw_marino has failed, exit
	EXIT /B 1
)
IF %hw_found% EQU 0 (
	ECHO No matching configuration found, %~n0 exit
	EXIT /B 1
)

EXIT /B 0

:flash_hw_brady
	ECHO start flashing brady
	SET hw_found=1
	ECHO validation file version: [1.0]
	ECHO hw version: [%version%]
	IF "%version%"=="1.0" (
		ECHO Version match no need to upgrade
		EXIT /B 0
	)
	ECHO Version does not match, upgrading
	%fastboot% oem hw +.features > NUL 2>&1
	%fastboot% oem hw .features radio,ram,storage,dualsim,imager,fps,dtv,nfc,e
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for .features has failed, exit
		EXIT /B 1
	)
	%fastboot% oem hw .features +compass,frontcolor
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add more data for .features has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw +.attributes > NUL 2>&1
	%fastboot% oem hw .attributes .range,.cmdline,.chosen,.system,.auto
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for .attributes has failed, exit
		EXIT /B 1
	)

	ECHO start creating requested utags
	%fastboot% oem hw +dtv > NUL 2>&1
	%fastboot% oem hw +dtv/.auto > NUL 2>&1
	%fastboot% oem hw +dtv/.chosen > NUL 2>&1
	%fastboot% oem hw +dtv/.range > NUL 2>&1
	%fastboot% oem hw +dtv/.system > NUL 2>&1
	%fastboot% oem hw +dualsim > NUL 2>&1
	%fastboot% oem hw +dualsim/.auto > NUL 2>&1
	%fastboot% oem hw +dualsim/.cmdline > NUL 2>&1
	%fastboot% oem hw +dualsim/.range > NUL 2>&1
	%fastboot% oem hw +dualsim/.system > NUL 2>&1
	%fastboot% oem hw +ecompass > NUL 2>&1
	%fastboot% oem hw +ecompass/.auto > NUL 2>&1
	%fastboot% oem hw +ecompass/.chosen > NUL 2>&1
	%fastboot% oem hw +ecompass/.range > NUL 2>&1
	%fastboot% oem hw +ecompass/.system > NUL 2>&1
	%fastboot% oem hw +fps > NUL 2>&1
	%fastboot% oem hw +fps/.auto > NUL 2>&1
	%fastboot% oem hw +fps/.chosen > NUL 2>&1
	%fastboot% oem hw +fps/.range > NUL 2>&1
	%fastboot% oem hw +fps/.system > NUL 2>&1
	%fastboot% oem hw +frontcolor > NUL 2>&1
	%fastboot% oem hw +frontcolor/.auto > NUL 2>&1
	%fastboot% oem hw +frontcolor/.range > NUL 2>&1
	%fastboot% oem hw +frontcolor/.system > NUL 2>&1
	%fastboot% oem hw +imager > NUL 2>&1
	%fastboot% oem hw +imager/.auto > NUL 2>&1
	%fastboot% oem hw +imager/.chosen > NUL 2>&1
	%fastboot% oem hw +imager/.range > NUL 2>&1
	%fastboot% oem hw +imager/.system > NUL 2>&1
	%fastboot% oem hw +nfc > NUL 2>&1
	%fastboot% oem hw +nfc/.auto > NUL 2>&1
	%fastboot% oem hw +nfc/.chosen > NUL 2>&1
	%fastboot% oem hw +nfc/.range > NUL 2>&1
	%fastboot% oem hw +nfc/.system > NUL 2>&1
	%fastboot% oem hw +radio > NUL 2>&1
	%fastboot% oem hw +radio/.auto > NUL 2>&1
	%fastboot% oem hw +radio/.cmdline > NUL 2>&1
	%fastboot% oem hw +radio/.range > NUL 2>&1
	%fastboot% oem hw +ram > NUL 2>&1
	%fastboot% oem hw +ram/.auto > NUL 2>&1
	%fastboot% oem hw +ram/.range > NUL 2>&1
	%fastboot% oem hw +ram/.system > NUL 2>&1
	%fastboot% oem hw +storage > NUL 2>&1
	%fastboot% oem hw +storage/.auto > NUL 2>&1
	%fastboot% oem hw +storage/.range > NUL 2>&1
	%fastboot% oem hw +storage/.system > NUL 2>&1
	ECHO done creating requested utags

	%fastboot% oem hw dtv/.auto default=false
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for dtv/.auto has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw dtv/.chosen mmi,
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for dtv/.chosen has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw dtv/.range false,true
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for dtv/.range has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw dtv/.system ro.hw.
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for dtv/.system has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw dualsim/.auto default=false
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for dualsim/.auto has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw dualsim/.cmdline androidboot.
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for dualsim/.cmdline has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw dualsim/.range false,true
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for dualsim/.range has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw dualsim/.system ro.hw.
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for dualsim/.system has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw ecompass/.auto default=true
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for ecompass/.auto has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw ecompass/.chosen mmi,
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for ecompass/.chosen has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw ecompass/.range true,false
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for ecompass/.range has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw ecompass/.system ro.hw.
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for ecompass/.system has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw fps/.auto key=hwid;index=2;map=1:true,2:false,3:false
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for fps/.auto has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw fps/.chosen mmi,
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for fps/.chosen has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw fps/.range true,false
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for fps/.range has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw fps/.system ro.hw.
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for fps/.system has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw frontcolor/.auto uspace=config;name=build_vars;map=BLACK
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for frontcolor/.auto has failed, exit
		EXIT /B 1
	)
	%fastboot% oem hw frontcolor/.auto +:black,GOLD:gold,black:black,gold:gold
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add more data for frontcolor/.auto has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw frontcolor/.range gold,black,other
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for frontcolor/.range has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw frontcolor/.system ro.hw.
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for frontcolor/.system has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw imager/.auto default=8MP
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for imager/.auto has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw imager/.chosen mmi,
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for imager/.chosen has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw imager/.range 8MP
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for imager/.range has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw imager/.system ro.hw.
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for imager/.system has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw nfc/.auto default=false
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for nfc/.auto has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw nfc/.chosen mmi,
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for nfc/.chosen has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw nfc/.range false,true
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for nfc/.range has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw nfc/.system ro.hw.
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for nfc/.system has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw radio/.auto key=hwid;index=2;map=1:LATAM,2:EMEA,3:India,
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for radio/.auto has failed, exit
		EXIT /B 1
	)
	%fastboot% oem hw radio/.auto +4:APAC
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add more data for radio/.auto has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw radio/.cmdline androidboot.
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for radio/.cmdline has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw radio/.range LATAM,EMEA,India,APAC
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for radio/.range has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw ram/.auto key=hwprobe;index=__ram
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for ram/.auto has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw ram/.range 2GB,3GB,4GB
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for ram/.range has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw ram/.system ro.hw.
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for ram/.system has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw storage/.auto key=hwprobe;index=__storage
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for storage/.auto has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw storage/.range 16GB,32GB,64GB
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for storage/.range has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw storage/.system ro.hw.
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for storage/.system has failed, exit
		EXIT /B 1
	)

	ECHO finished configuring brady, set version
	%fastboot% oem hw .version 1.0
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for 1.0 has failed, exit
		EXIT /B 1
	)
	ECHO version set
	GOTO:EOF


:flash_hw_marino
	ECHO start flashing marino
	SET hw_found=1
	ECHO validation file version: [1.1]
	ECHO hw version: [%version%]
	IF "%version%"=="1.1" (
		ECHO Version match no need to upgrade
		EXIT /B 0
	)
	ECHO Version does not match, upgrading
	%fastboot% oem hw +.features > NUL 2>&1
	%fastboot% oem hw .features radio,ram,storage,dualsim,imager,fps,dtv,nfc,e
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for .features has failed, exit
		EXIT /B 1
	)
	%fastboot% oem hw .features +compass,frontcolor
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add more data for .features has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw +.attributes > NUL 2>&1
	%fastboot% oem hw .attributes .range,.cmdline,.chosen,.system,.auto
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for .attributes has failed, exit
		EXIT /B 1
	)

	ECHO start creating requested utags
	%fastboot% oem hw +dtv > NUL 2>&1
	%fastboot% oem hw +dtv/.auto > NUL 2>&1
	%fastboot% oem hw +dtv/.chosen > NUL 2>&1
	%fastboot% oem hw +dtv/.range > NUL 2>&1
	%fastboot% oem hw +dtv/.system > NUL 2>&1
	%fastboot% oem hw +dualsim > NUL 2>&1
	%fastboot% oem hw +dualsim/.auto > NUL 2>&1
	%fastboot% oem hw +dualsim/.cmdline > NUL 2>&1
	%fastboot% oem hw +dualsim/.range > NUL 2>&1
	%fastboot% oem hw +dualsim/.system > NUL 2>&1
	%fastboot% oem hw +ecompass > NUL 2>&1
	%fastboot% oem hw +ecompass/.auto > NUL 2>&1
	%fastboot% oem hw +ecompass/.chosen > NUL 2>&1
	%fastboot% oem hw +ecompass/.range > NUL 2>&1
	%fastboot% oem hw +ecompass/.system > NUL 2>&1
	%fastboot% oem hw +fps > NUL 2>&1
	%fastboot% oem hw +fps/.auto > NUL 2>&1
	%fastboot% oem hw +fps/.chosen > NUL 2>&1
	%fastboot% oem hw +fps/.range > NUL 2>&1
	%fastboot% oem hw +fps/.system > NUL 2>&1
	%fastboot% oem hw +frontcolor > NUL 2>&1
	%fastboot% oem hw +frontcolor/.auto > NUL 2>&1
	%fastboot% oem hw +frontcolor/.range > NUL 2>&1
	%fastboot% oem hw +frontcolor/.system > NUL 2>&1
	%fastboot% oem hw +imager > NUL 2>&1
	%fastboot% oem hw +imager/.auto > NUL 2>&1
	%fastboot% oem hw +imager/.chosen > NUL 2>&1
	%fastboot% oem hw +imager/.range > NUL 2>&1
	%fastboot% oem hw +imager/.system > NUL 2>&1
	%fastboot% oem hw +nfc > NUL 2>&1
	%fastboot% oem hw +nfc/.auto > NUL 2>&1
	%fastboot% oem hw +nfc/.chosen > NUL 2>&1
	%fastboot% oem hw +nfc/.range > NUL 2>&1
	%fastboot% oem hw +nfc/.system > NUL 2>&1
	%fastboot% oem hw +radio > NUL 2>&1
	%fastboot% oem hw +radio/.auto > NUL 2>&1
	%fastboot% oem hw +radio/.cmdline > NUL 2>&1
	%fastboot% oem hw +radio/.range > NUL 2>&1
	%fastboot% oem hw +ram > NUL 2>&1
	%fastboot% oem hw +ram/.auto > NUL 2>&1
	%fastboot% oem hw +ram/.range > NUL 2>&1
	%fastboot% oem hw +ram/.system > NUL 2>&1
	%fastboot% oem hw +storage > NUL 2>&1
	%fastboot% oem hw +storage/.auto > NUL 2>&1
	%fastboot% oem hw +storage/.range > NUL 2>&1
	%fastboot% oem hw +storage/.system > NUL 2>&1
	ECHO done creating requested utags

	%fastboot% oem hw dtv/.auto default=false
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for dtv/.auto has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw dtv/.chosen mmi,
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for dtv/.chosen has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw dtv/.range false,true
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for dtv/.range has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw dtv/.system ro.hw.
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for dtv/.system has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw dualsim/.auto default=false
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for dualsim/.auto has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw dualsim/.cmdline androidboot.
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for dualsim/.cmdline has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw dualsim/.range true,false
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for dualsim/.range has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw dualsim/.system ro.hw.
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for dualsim/.system has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw ecompass/.auto default=true
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for ecompass/.auto has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw ecompass/.chosen mmi,
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for ecompass/.chosen has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw ecompass/.range true,false
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for ecompass/.range has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw ecompass/.system ro.hw.
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for ecompass/.system has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw fps/.auto key=hwid;index=2;map=1:true,2:false,3:false
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for fps/.auto has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw fps/.chosen mmi,
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for fps/.chosen has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw fps/.range true,false
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for fps/.range has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw fps/.system ro.hw.
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for fps/.system has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw frontcolor/.auto uspace=config;name=build_vars;map=BLACK
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for frontcolor/.auto has failed, exit
		EXIT /B 1
	)
	%fastboot% oem hw frontcolor/.auto +:black,GOLD:gold,black:black,gold:gold
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add more data for frontcolor/.auto has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw frontcolor/.range gold,black,other
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for frontcolor/.range has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw frontcolor/.system ro.hw.
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for frontcolor/.system has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw imager/.auto default=13MP
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for imager/.auto has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw imager/.chosen mmi,
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for imager/.chosen has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw imager/.range 13MP
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for imager/.range has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw imager/.system ro.hw.
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for imager/.system has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw nfc/.auto default=false
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for nfc/.auto has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw nfc/.chosen mmi,
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for nfc/.chosen has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw nfc/.range false,true
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for nfc/.range has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw nfc/.system ro.hw.
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for nfc/.system has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw radio/.auto key=hwid;index=2;map=1:LATAM,2:EMEA,3:India
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for radio/.auto has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw radio/.cmdline androidboot.
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for radio/.cmdline has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw radio/.range LATAM,EMEA,India
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for radio/.range has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw ram/.auto key=hwprobe;index=__ram
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for ram/.auto has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw ram/.range 2GB,3GB,4GB
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for ram/.range has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw ram/.system ro.hw.
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for ram/.system has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw storage/.auto key=hwprobe;index=__storage
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for storage/.auto has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw storage/.range 16GB,32GB,64GB
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for storage/.range has failed, exit
		EXIT /B 1
	)

	%fastboot% oem hw storage/.system ro.hw.
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for storage/.system has failed, exit
		EXIT /B 1
	)

	ECHO finished configuring marino, set version
	%fastboot% oem hw .version 1.1
	IF %errorlevel% NEQ 0 (
		ECHO hw descriptor error: add data for 1.1 has failed, exit
		EXIT /B 1
	)
	ECHO version set
	GOTO:EOF


:backup_hw_bat
        ECHO hw descriptor creating hw partition backup
        %fastboot% oem partition dump hw
        GOTO:EOF

:fastboot_path
REM Need delayedexpansion in this function's ELSE to access fastboot variable in the same block.
REM Otherwise it will be available only after the block is closed out or the function returns
        IF EXIST %preferred_fastboot% (
                SET fastboot=%preferred_fastboot%
        ) ELSE (
                ECHO:preferred fastboot [%preferred_fastboot%] does not exist
                SET fastboot=%backup_fastboot%
                ECHO:looking for [!fastboot!] in PATH or local directory
                WHERE !fastboot!
        )
        GOTO:EOF

:count_devices
        SET hw_cnt=0
        SET wfind=%systemroot%\system32\find
        FOR /F "tokens=1" %%X in ('%fastboot% devices 2^>^&1 ^| %wfind% "" /V /C') DO (SET hw_cnt=%%X)
        ECHO fastboot device count [%hw_cnt%]
        IF %hw_cnt% EQU 0 EXIT /B 1
        GOTO:EOF

:check_serial
        IF NOT [%1]==[] (SET fastboot=%fastboot% -s %1) ELSE (
                IF %hw_cnt% GTR 1 (
                        ECHO Serial number required: %~n0 ^<serial number^>
                        EXIT /B 1
                )
        )
        ECHO %~n0 is using [%fastboot%]
        GOTO:EOF
