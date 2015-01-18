@echo off

:: $Date$ 
:: $Revision$
:: $Author$

set rundebug=%1
if "%rundebug%" == "1" (
  set DEBUG=_db
) else (
  set DEBUG=
)

set BASEDIR="%CD%"
cd ..
set SVNROOT="%CD%"
cd %BASEDIR%
set TIME_FILE="%BASEDIR%\fds_case_times.txt"

::*** uncomment following two lines to use OpenMP

:: set OMP_NUM_THREADS=1

:: default FDS location

set FDSEXE=%SVNROOT%\FDS_Compilation\mpi_intel_win_64%DEBUG%\fds_mpi_win_64%DEBUG%.exe

if not exist %FDSEXE%  (
  echo "***error: The program, %FDSEXE% , was not found.  Verification test runs aborted."
  goto eof2
)

call :getfilename %FDSEXE% 
set FDSBASE=%file%

set BACKGROUNDEXE=%SVNROOT%\Utilities\background\intel_win_32\background.exe
set FDS=%BACKGROUNDEXE% -u 60 -m 70 -d 5 %FDSEXE%
set QFDS=call %SVNROOT%\Utilities\Scripts\runfds.bat

echo.
echo Creating FDS case list from FDS_Cases.sh
..\Utilities\Data_processing\sh2bat FDS_Cases.sh FDS_Cases.bat
echo Creating FDS_MPI case list from FDS_MPI_Cases.sh
..\Utilities\Data_processing\sh2bat FDS_MPI_Cases.sh FDS_MPI_Cases.bat

echo.
echo Running FDS cases
echo.

echo "FDS test cases begin" >> %TIME_FILE%
date /t >> %TIME_FILE%
time /t >> %TIME_FILE%

call FDS_Cases.bat

:: loop until all FDS cases have finished

:loop1
tasklist | find /i /c "%FDSBASE%" > temp.out
set /p numexe=<temp.out
echo Number of cases running - %numexe%
if %numexe% == 0 goto finished
Timeout /t 30 >nul 
goto loop1

:finished
echo "FDS cases completed"
goto eof

:getfilename
set file=%~nx1
exit /b

:eof
echo "FDS test cases end" >> %TIME_FILE%
date /t >> %TIME_FILE%
time /t >> %TIME_FILE%

:eof2


