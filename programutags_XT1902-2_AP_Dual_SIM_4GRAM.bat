@ECHO OFF
ECHO Motorola Mobility UTAG programming script Special Edition
ECHO This script programs the following UTAGs: carrier fsg-id and HW descriptor
ECHO.
:: always use fastboot that come with the package
SETLOCAL EnableDelayedExpansion
SET preferred_fastboot=.\Windows\fastboot.exe
SET backup_fastboot=fastboot.exe

SET sku=XT1902-2
SET radio=India
SET ram=4GB
SET storage=32GB
SET dualsim=true
SET num-sims=2
SET imager=13MP
SET fps=true
SET dtv=false
SET nfc=false
SET frontcolor=
SET display=

SET Carrier[0].Name=retapac
SET Carrier[0].Dsc=Retail APAC
SET Carrier[1].Name=retin
SET Carrier[1].Dsc=Retail India
SET Carrier[2].Name=retid
SET Carrier[2].Dsc=Retail Indonesia
SET Carrier_Length=3


::Letter Map
SET Letter[0].Value=0
SET Letter[1].Value=1
SET Letter[2].Value=2
SET Letter[3].Value=3
SET Letter[4].Value=4
SET Letter[5].Value=5
SET Letter[6].Value=6
SET Letter[7].Value=7
SET Letter[8].Value=8
SET Letter[9].Value=9
SET Letter[10].Value=A
SET Letter[11].Value=B
SET Letter[12].Value=C
SET Letter[13].Value=D
SET Letter[14].Value=E
SET Letter[15].Value=F
SET Letter[16].Value=G
SET Letter[17].Value=H
SET Letter[18].Value=I
SET Letter[19].Value=J
SET Letter[20].Value=K
SET Letter[21].Value=L
SET Letter[22].Value=M
SET Letter[23].Value=N
SET Letter[24].Value=O
SET Letter[25].Value=P
SET Letter[26].Value=Q
SET Letter[27].Value=R
SET Letter[28].Value=S
SET Letter[29].Value=T
SET Letter[30].Value=U
SET Letter[31].Value=V
SET Letter[32].Value=W
SET Letter[33].Value=X
SET Letter[34].Value=Y
SET Letter[35].Value=Z

ECHO:my working directory is [%CD%]
CALL :fastboot_path
IF %errorlevel% NEQ 0 (
	ECHO hw descriptor error: fastboot_path has failed, exit
	EXIT /B 1
)
:: always use fastboot that come with the package
SET carrier=%1%
SET fsg_model=%2%

if not "%1"=="" GOTO SETCARRIER


ECHO. need Select a carrier param 
SET Carrier_Index=0

:LoopCarrierStart
IF %Carrier_Index% EQU %Carrier_Length% GOTO :LoopCarrierOK
 
SET Carrier_Current.Name=0
SET Carrier_Current.Dsc=0
  
FOR /F "usebackq delims==. tokens=1-3" %%I IN (`SET Carrier[%Carrier_Index%]`) DO (
  SET Carrier_Current.%%J=%%K
)
FOR /F "usebackq delims==. tokens=1-3" %%I IN (`SET Letter[%Carrier_Index%]`) DO (
  SET Letter_Print.%%J=%%K
)

ECHO  %Letter_Print.Value% - %Carrier_Current.Name% # %Carrier_Current.Dsc%
SET /A Carrier_Index=%Carrier_Index% + 1
GOTO LoopCarrierStart

:LoopCarrierOK

CHOICE /C 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ /N /M "Please select Carrier: "
SET /a Number=%ERRORLEVEL%-1

if %Number% GEQ %Carrier_Length% (
  ECHO Not Supported Carrier!
  EXIT /b 1
)

SET Carrier_Current.Name=0
SET Carrier_Current.Dsc=0
FOR /F "usebackq delims==. tokens=1-3" %%I IN (`SET Carrier[%Number%]`) DO (
  SET Carrier_Current.%%J=%%K
)
SET carrier=%Carrier_Current.Name%
SET fsg_model=""


:SETCARRIER

if "%2"=="" (
  SET fsg_model=
)

:: If the carrier is support
SET Carrier_Index=0

:LoopStart
IF %Carrier_Index% EQU %Carrier_Length% (
    ECHO. Unsupport Carrier %carrier%
    EXIT /b 1
)

SET Carrier_Current.Name=0
FOR /F "usebackq delims==. tokens=1-3" %%I IN (`SET Carrier[%Carrier_Index%]`) DO (
  SET Carrier_Current.%%J=%%K
)

IF %carrier% EQU %Carrier_Current.Name% (
    ECHO.  carrier is OK
    GOTO Begin
)
  
SET /A Carrier_Index=%Carrier_Index% + 1
  
GOTO LoopStart


:Begin
:: Wait for fastboot device enumeration
CALL :wait_for_device

:: Set UTAG

if defined radio (
ECHO.
ECHO. Setting radio...
ECHO. 1

CALL :fastboot_hw_config radio "%radio%"
)
IF %errorlevel% NEQ 0 EXIT /b 1

if defined ram (
ECHO.
ECHO. Setting ram...
ECHO. 2

CALL :fastboot_hw_config ram "%ram%"
)
IF %errorlevel% NEQ 0 EXIT /b 1

if defined storage (
ECHO.
ECHO. Setting storage...
ECHO. 3

CALL :fastboot_hw_config storage "%storage%"
)
IF %errorlevel% NEQ 0 EXIT /b 1

if defined dualsim (
ECHO.
ECHO. Setting dualsim...
ECHO. 4

CALL :fastboot_hw_config dualsim "%dualsim%"
)
IF %errorlevel% NEQ 0 EXIT /b 1

if defined imager (
ECHO.
ECHO. Setting imager... skip
ECHO. 5

)
IF %errorlevel% NEQ 0 EXIT /b 1

if defined fps (
ECHO. 
ECHO. Setting fps...
ECHO. 6

CALL :fastboot_hw_config fps "%fps%"
)
IF %errorlevel% NEQ 0 EXIT /b 1

if defined dtv (
ECHO.
ECHO. Setting dtv...
ECHO. 7

CALL :fastboot_hw_config dtv "%dtv%"
IF %errorlevel% NEQ 0 EXIT /b 1
)

if defined nfc (
ECHO.
ECHO. Setting nfc...
ECHO. 8

CALL :fastboot_hw_config nfc "%nfc%"
)
IF %errorlevel% NEQ 0 EXIT /b 1

if defined frontcolor (
ECHO.
ECHO. Setting frontcolor...
ECHO. 9

CALL :fastboot_hw_config frontcolor "%frontcolor%"
IF %errorlevel% NEQ 0 EXIT /b 1
)

if defined display (
ECHO.
ECHO. Setting display...
ECHO. 10

CALL :fastboot_oem_config display "%display%"
)
IF %errorlevel% NEQ 0 EXIT /b 1

if defined fsg_model (
:: Set OEM
ECHO.
ECHO. Setting fsg-id...
ECHO.

CALL :fastboot_oem_config fsg-id "%fsg_model%"
)
IF %errorlevel% NEQ 0 EXIT /b 1

if defined carrier (
ECHO.
ECHO. Setting carrier...
ECHO.

CALL :fastboot_oem_config carrier "%carrier%"
)
IF %errorlevel% NEQ 0 EXIT /b 1

if defined sku (
ECHO.
ECHO. Setting sku...
ECHO. 10

CALL :fastboot_oem_config sku "%sku%"
)
IF %errorlevel% NEQ 0 EXIT /b 1

if defined num-sims (
ECHO.
ECHO. Setting num-sims...
ECHO. 10

CALL :fastboot_oem_config num-sims "%num-sims%"
)
IF %errorlevel% NEQ 0 EXIT /b 1

ECHO.
ECHO. All UTAGs programmed successfully!
ECHO.


PAUSE

EXIT /b 0

:: ------------------------------------------------------------------------
:: Functions start here
:: ------------------------------------------------------------------------

:wait_for_device
	SETLOCAL

	ECHO.
	ECHO. Waiting for fastboot enumeration...
	ECHO.

	SET /A wait_time=1

	:loop
	SET /A device_count=0

	FOR /F "usebackq tokens=2" %%X in (`%fastboot% devices`) do (
		IF "%%X" == "fastboot" SET /A device_count+=1
	)

	IF %device_count% LSS 1 (
		ping -n 2 127.0.0.1 > NUL
		SET /A wait_time+=1
		IF %wait_time% == 10 (
			ECHO. Still waiting...
			ECHO. Do you by any chance have a JTAG flex attached?
			ECHO. If so, detach the JTAG flex and try again.
			ECHO.

			SET /A wait_time=1
		)
		GOTO :loop
	)

	IF %device_count% GTR 1 (
		ECHO. Too many devices!
		ping -n 2 127.0.0.1 > NUL
		GOTO :loop
	)

	:: Allow time for fastboot enumeration to stablize
	ping -n 3 127.0.0.1 > NUL

	ECHO. Fastboot device is ready!!

	ENDLOCAL
	EXIT /b 0

:fastboot_erase
        ECHO. Executing "%fastboot% erase %~1"

        SETLOCAL

        SET /A okay_count=0

        FOR /F "usebackq tokens=*" %%X in (`%fastboot% erase %~1  2^>^&1`) do (
                ECHO. %%X

                FOR /F "usebackq tokens=1" %%C in (`echo %%X ^| find /C "OKAY"`) do (
                        IF "%%C" == "1" SET /A okay_count+=1
                )
        )

        IF %okay_count% NEQ 1 (
                ECHO. %fastboot% erase %~1  failed!!
                PAUSE
                ENDLOCAL
                EXIT /b 1
        )

        ECHO.

        ENDLOCAL
        EXIT /b 0

:fastboot_oem_config
	ECHO. Executing "%fastboot% oem config %~1 %~2"

	SETLOCAL

	SET /A okay_count=0

	FOR /F "usebackq tokens=*" %%X in (`%fastboot% oem config %~1  %~2 2^>^&1`) do (
		ECHO. %%X

		FOR /F "usebackq tokens=1" %%C in (`echo "%%X" ^| find /C "OKAY"`) do (
			IF "%%C" == "1" SET /A okay_count+=1
		)
	)

	IF %okay_count% NEQ 1 (
		ECHO. %fastboot% oem config %~1 %~2 failed!!
		PAUSE
		ENDLOCAL
		EXIT /b 1
	)

	ECHO.

	ENDLOCAL
	EXIT /b 0

:fastboot_hw_config
	ECHO. Executing "%fastboot% oem hw %~1 %~2"

	SETLOCAL

	SET /A okay_count=0

	FOR /F "usebackq tokens=*" %%X in (`%fastboot% oem hw %~1  %~2 2^>^&1`) do (
		ECHO. %%X

		FOR /F "usebackq tokens=1" %%C in (`echo "%%X" ^| find /C "OKAY"`) do (
			IF "%%C" == "1" SET /A okay_count+=1
		)
	)

	IF %okay_count% NEQ 1 (
		ECHO. %fastboot% oem hw %~1 %~2 failed!!
		PAUSE
		ENDLOCAL
		EXIT /b 1
	)

	ECHO. ======================================

	ENDLOCAL
	EXIT /b 0

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
