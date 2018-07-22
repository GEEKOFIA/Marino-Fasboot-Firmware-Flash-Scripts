@ECHO OFF
@SETLOCAL enabledelayedexpansion

ECHO Motorola Mobility Fastboot script Special Edition by GEEKOFIA

:: always use fastboot that come with the package
SET fastboot=.\Windows\fastboot.exe

::
:: command line options to override the defaults
:: useful for factory software preparation
::
SET flash_userdata=1
SET erase_userdata=0
SET erase_cache=0
SET para_flash=1
SET serial_number=
SET device_list=
SET device_count=0
SET opts=
SET flash_script=%0
SET no_reboot=0

::
:: process command line options
::

:proc_option

IF "%1" == "" (
        GOTO :start_flashing
)

SET bad_option=1

:: flash userdata?
IF "%1" == "/u" (
        SET flash_userdata=1
        SHIFT
        SET bad_option=0
        SET opts=%opts% /u
)

:: erase userdata?
IF "%1" == "/eu" (
        SET erase_userdata=1
        SHIFT
        SET bad_option=0
        SET opts=%opts% /eu
)

:: erase cache?
IF "%1" == "/ec" (
        SET erase_cache=1
        SHIFT
        SET bad_option=0
        SET opts=%opts% /ec
)

:: disable para-flash
IF "%1" == "/s" (
  SET para_flash=0
  SHIFT
  SET bad_option=0
)

:: disable fastboot reboot
IF "%1" == "/nr" (
  SET no_reboot=1
  SHIFT
  SET bad_option=0
)

:: specify device number
IF "%1" == "/d" (
  SET serial_number=%2
  SHIFT
  SHIFT
  SET bad_option=0
)

IF %bad_option% == 1 (
        CALL :show_usage
        EXIT /b 1
)

GOTO :proc_option

::
:: Start flashing
::
:start_flashing

:: not to erase userdata if we are flashing it
:: because bootloader erases the partition before
:: flashing it
IF %flash_userdata% == 1 SET erase_userdata=0

ECHO.
ECHO. Flashing Options:
ECHO. - flash userdata: %flash_userdata%
ECHO. - erase userdata: %erase_userdata%
ECHO. - erase cache:    %erase_cache%
ECHO.

ECHO.
ECHO. Waiting for repacking fastboot image...
ECHO.

:: Wait for fastboot device enumeration
ECHO.
ECHO. Waiting for fastboot enumeration...
ECHO.

CALL :enumerate_all_devices
IF %errorlevel% NEQ 0 EXIT /b 1

ECHO. There are %device_count% device(s) connected: %device_list%

IF %device_count% == 1 (
  SET /A para_flash=0
)
IF NOT "%serial_number%" == "" (
  CALL :flash_one_device
  IF %errorlevel% NEQ 0 EXIT /b 1
) else (
  FOR %%D in (%device_list::= %) do (
    ECHO. Trying to flash device %%D
    IF %para_flash% == 0 (
      CALL SET serial_number=%%D
      CALL :flash_one_device
    ) else (
      start cmd /k Call %flash_script% %opts% /s /d %%D
    )
  )
)

ECHO. All devices are flashed!

PAUSE

EXIT /b 0

:: ------------------------------------------------------------------------
:: Functions start here
:: ------------------------------------------------------------------------

:flash_one_device:
  IF "%serial_number%" == "" (
    ECHO. No device specified
    EXIT /b 1
  )

  :: Check whether the phone is connected
  CALL SET replaced=%%device_list:%serial_number%=%%
  IF "%replaced%" == "%device_list%" (
    ECHO. Device %serial_number% is not connected
    EXIT /b 1
  )

  ECHO.
  ECHO. Starting flashing device %serial_number%...
  ECHO.

::  ECHO.
::  ECHO. Flashing PGPT ...
::  ECHO.
::  CALL :fastboot_flash gpt PGPT
::  IF %errorlevel% NEQ 0 EXIT /b 1

  ECHO.
  ECHO. Flashing trustzone ...
  ECHO.
  CALL :fastboot_flash tee1 trustzone.bin
  IF %errorlevel% NEQ 0 EXIT /b 1

  ECHO.
  ECHO. Flashing trustzone ...
  ECHO.
  CALL :fastboot_flash tee2 trustzone.bin
  IF %errorlevel% NEQ 0 EXIT /b 1

  ECHO.
  ECHO. Flashing modem image ...
  ECHO.
  CALL :fastboot_flash md1img md1rom.img
  IF %errorlevel% NEQ 0 EXIT /b 1
  CALL :fastboot_flash md1dsp md1dsp.img
  IF %errorlevel% NEQ 0 EXIT /b 1
  CALL :fastboot_flash md1arm7 md1arm7.img
  IF %errorlevel% NEQ 0 EXIT /b 1
  CALL :fastboot_flash md3img md3rom.img
  IF %errorlevel% NEQ 0 EXIT /b 1

  ECHO.
  ECHO. Flashing preloader ...
  ECHO.
  CALL :fastboot_flash preloader preloader.img
  IF %errorlevel% NEQ 0 EXIT /b 1

  ECHO.
  ECHO. Flashing lk ...
  ECHO.
  CALL :fastboot_flash lk lk.bin
  IF %errorlevel% NEQ 0 EXIT /b 1
  CALL :fastboot_flash lk2 lk.bin
  IF %errorlevel% NEQ 0 EXIT /b 1

::  ECHO.
::  ECHO. Rebooting bootloader ...
::  ECHO.
::  CALL :fastboot_reboot_bl
::  timeout /t 3

  :flash_ap
::  ECHO.
::  ECHO. Flashing AP Images...
::  ECHO.

  CALL :fastboot_flash logo logo.bin
  IF %errorlevel% NEQ 0 EXIT /b 1
  CALL :fastboot_flash boot boot.img
  IF %errorlevel% NEQ 0 EXIT /b 1
  CALL :fastboot_flash recovery recovery.img
  IF %errorlevel% NEQ 0 EXIT /b 1
  CALL :fastboot_flash system system.img
  IF %errorlevel% NEQ 0 EXIT /b 1
  IF EXIST "oem.img" (
      CALL :fastboot_flash oem oem.img
      IF %errorlevel% NEQ 0 EXIT /b 1
  )

  IF EXIST "cache.img" (
    CALL :fastboot_flash cache cache.img
    IF %errorlevel% NEQ 0 (
        ECHO Flash cache filed.
        ECHO Now format cache...
        %fastboot% -s %serial_number% format cache
    )
  )
  :: Is there hw descriptor configuration script to run?
::  IF EXIST hwflash.bat (
::	ECHO.
::	ECHO. Flashing HW Descriptor...
::	ECHO.
::	CALL :get_lock_status saved_hwlock
::	IF "!saved_hwlock!" == "locked" CALL :set_lock OFF
::	CALL :get_lock_status current_hwlock
::	IF "!current_hwlock!" == "unlocked" (
::		CALL hwflash.bat %serial_number%
::		IF !errorlevel! NEQ 0 ( 
::                         ECHO hw descriptor flash script failed.
::                         IF "!saved_hwlock!" == "locked" CALL :set_lock ON
::                         EXIT /b 1
::                )
::		ECHO hw descriptor flash script finished.
::		IF "!saved_hwlock!" == "locked" CALL :set_lock ON
::        )
::  )


  :: Erase userdata?
  :erase_userdata
  IF %erase_userdata% == 1 (
          GOTO :do_erase_userdata
  )
  GOTO :erase_cache
  :do_erase_userdata
  ECHO. Erasing userdata...
  CALL :fastboot_erase userdata
  IF %errorlevel% NEQ 0 EXIT /b 1

  :: Erase cache?
  :erase_cache
  IF %erase_cache% == 1 (
          GOTO :do_erase_cache
  )
  GOTO :flash_userdata
  :do_erase_cache
  ECHO. Erasing cache
  CALL :fastboot_erase cache
  IF %errorlevel% NEQ 0 EXIT /b 1

  :: Flash userdata?
  :flash_userdata
  IF %flash_userdata% == 1 (
          GOTO :do_flash_userdata
  )
  GOTO :all_done
  :do_flash_userdata
  ECHO. Flashing userdata...
  IF EXIST "userdata.img" (
      CALL :fastboot_flash userdata userdata.img
      IF %errorlevel% NEQ 0  (
          ECHO Flash userdata filed.
          ECHO Now format userdata...
           %fastboot% -s %serial_number% format userdata
      )
  )

  :all_done
  ECHO.
  ECHO. All images flashed successfully!

  :: check if the device is flashed with factory software
::  for /f "delims=" %%X in ('%fastboot% getvar ro.build.fingerprint %~1 %~2 2^>^&1') do (
::      set fingerprint=!fingerprint! %%X
::  )
::  ECHO. %fingerprint% | findstr /C:"factory">nul && (
::  ECHO [WARNING] FACTORY SOFTWARE LOADED.
::  ECHO PLEASE ERASE USERDATA
::  ECHO use "fastboot erase userdata" command to erase userdata
::  timeout /t 5
::  )
  IF %no_reboot% == 0 (
      ECHO. Rebooting device...
      ECHO.
      %fastboot% -s %serial_number% reboot
  )

  EXIT /b 0

:show_usage
        ECHO.
        ECHO. Flashes all images with fastboot
        ECHO.
        ECHO. flashall [/?] [/u] [/eu] [/ec] [/s] [/d device_number] [/nr]
        ECHO.
        ECHO. /?   Help
        ECHO. /u   Flash userdata
        ECHO. /eu  Erase userdata
        ECHO. /ec  Erase cache
        ECHO. /s   Disable para-flash
        ECHO. /d   device_number   specify the device to be flashed
        ECHO. /nr  disable fastboot reboot after flashing all images
        ECHO.
        EXIT /b 0

:enumerate_all_devices
        SET /A wait_time=1
        SET /A ret=0

        :loop

        FOR /F "usebackq tokens=1" %%X in (`%fastboot% devices`) do (
                IF NOT "%%X" == "" (
                  SET /A device_count+=1
                  SET device_list=!device_list! %%X
                )
        )
        IF "%device_list%" == "" (
                ping -n 2 127.0.0.1 > NUL
                SET /A wait_time+=1
                IF %wait_time% == 10 (
                        ECHO. Not found any devices connected. Please check and try again.
                        ECHO.

                        SET /A ret=1
                        GOTO :exit_enumeration
                )
                GOTO :loop
        )

        IF NOT "%serial_number%" == "" (
                :: Check whether the phone is connected
                CALL SET replaced=%%device_list:%serial_number%=%%
                IF "%replaced%" == "%device_list%" (
                    ECHO. Device %serial_number% is not connected
                    EXIT /b 1
                )
        )
        ECHO. Fastboot device is ready!!

:exit_enumeration
        EXIT /b %ret%

:get_lock_status
	FOR /F "tokens=5" %%X in ('%fastboot% -s %serial_number% oem hw status 2^>^&1 ^| FINDSTR bootloader') DO (SET lock_status=%%X)
	SET %1=%lock_status%

        EXIT /b 0

:set_lock
	IF "%~1" == "ON" (
		SET instruction=lock
	) ELSE SET instruction=unlock
	%fastboot% -s %serial_number% oem hw %instruction% > NUL

        EXIT /b 0

:fastboot_flash
        ECHO. Executing "%fastboot% -s %serial_number% flash %~1 %~2"

        %fastboot% -s %serial_number% flash %~1 %~2
        IF %errorlevel% NEQ 0 EXIT /b 1

        ECHO.

        EXIT /b 0

:fastboot_reboot_bl
        ECHO. Executing %fastboot% -s %serial_number% reboot-bootloader
        %fastboot% -s %serial_number% reboot-bootloader
        IF %errorlevel% NEQ 0 EXIT /b 1

        : to allow time for fastboot de-enumeration before continuing
        ping -n 5 127.0.0.1 > NUL

        EXIT /b 0

:fastboot_erase
        ECHO. Executing "%fastboot% -s %serial_number% erase %~1"
        %fastboot% -s %serial_number% erase %~1
        IF %errorlevel% NEQ 0 EXIT /b 1

        ECHO.

        ENDLOCAL
        EXIT /b 0

EXIT /b 1
