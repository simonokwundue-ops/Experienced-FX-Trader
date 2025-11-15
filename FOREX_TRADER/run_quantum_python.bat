@echo off
REM =========================================
REM QuantumForexTrader Python Runner
REM =========================================

echo QuantumForexTrader - Python Quantum Analysis
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.8+ from https://www.python.org/
    pause
    exit /b 1
)

echo Python found!
echo.

REM Check if required packages are installed
echo Checking required packages...
python -c "import MetaTrader5" >nul 2>&1
if errorlevel 1 (
    echo Installing MetaTrader5 package...
    pip install MetaTrader5
)

python -c "import qiskit" >nul 2>&1
if errorlevel 1 (
    echo Installing Qiskit package...
    pip install qiskit qiskit-aer
)

python -c "import numpy" >nul 2>&1
if errorlevel 1 (
    echo Installing NumPy package...
    pip install numpy
)

python -c "import pandas" >nul 2>&1
if errorlevel 1 (
    echo Installing Pandas package...
    pip install pandas
)

python -c "import pycryptodome" >nul 2>&1
if errorlevel 1 (
    echo Installing PyCryptodome package...
    pip install pycryptodome
)

echo.
echo All packages installed!
echo.

REM Get the directory where this batch file is located
set SCRIPT_DIR=%~dp0

REM Run the quantum analysis script
echo Running Quantum Analysis...
echo.
python "%SCRIPT_DIR%Python\quantum_analysis.py"

if errorlevel 1 (
    echo.
    echo ERROR: Quantum analysis failed
    pause
    exit /b 1
)

echo.
echo Quantum analysis completed successfully!
echo.
pause
