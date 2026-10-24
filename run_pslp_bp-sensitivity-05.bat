@echo off
setlocal EnableExtensions

set "base_dir=%~dp0"
set "exe=%base_dir%pslp_bp.exe"
set "config=%base_dir%algo_config-sensitivity-05.json"
set "diagnostic=%base_dir%last_run_error-sensitivity-05.txt"

title PSLP Budget Sensitivity Experiments

if not exist "%exe%" (
    echo ERROR: Executable not found:
    echo   %exe%
    goto :failed
)

if not exist "%config%" (
    echo ERROR: Configuration not found:
    echo   %config%
    goto :failed
)

for %%D in (libscip.dll cplex2210.dll zlib1.dll ipopt-3.dll gmp-10.dll mpfr-6.dll tbb12.dll coinmumps-3.dll libiomp5md.dll libifcoremd.dll libmmd.dll svml_dispmd.dll) do (
    if not exist "%base_dir%%%D" (
        echo ERROR: Required runtime not found: %%D
        goto :failed
    )
)

for %%D in (MSVCP140.dll VCRUNTIME140.dll VCRUNTIME140_1.dll) do (
    if not exist "%base_dir%%%D" if not exist "%SystemRoot%\System32\%%D" (
        echo ERROR: Microsoft Visual C++ x64 runtime not found: %%D
        echo Install the Microsoft Visual C++ 2015-2022 Redistributable ^(x64^).
        goto :failed
    )
)

pushd "%base_dir%"
echo Starting PSLP budget sensitivity experiments...
echo Executable: %exe%
echo Configuration: %config%
echo Additional budget slack: 0.05
echo.
"%exe%" --config "%config%"
set "exit_code=%errorlevel%"
popd

echo.
if not "%exit_code%"=="0" (
    echo Experiments finished with errors. Exit code: %exit_code%
    > "%diagnostic%" (
        echo Timestamp: %date% %time%
        echo Exit code: %exit_code%
        echo Computer: %COMPUTERNAME%
        echo Executable: %exe%
        echo Configuration: %config%
        echo.
        echo Check results\s05\summary_sensitivity-05.json
        echo and the failed result JSON for details.
    )
    echo Diagnostic: %diagnostic%
) else (
    echo All budget sensitivity experiments completed successfully.
    if exist "%diagnostic%" del /q "%diagnostic%"
)

if not defined PSLP_NO_PAUSE pause
exit /b %exit_code%

:failed
if not defined PSLP_NO_PAUSE pause
exit /b 1
