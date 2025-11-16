@echo off
echo ================================================
echo HackIFM Backend - Automatic Setup
echo ================================================
echo.

echo [1/5] Creating virtual environment...
python -m venv venv
if errorlevel 1 (
    echo ERROR: Failed to create virtual environment
    pause
    exit /b 1
)
echo ✓ Virtual environment created
echo.

echo [2/5] Activating virtual environment...
call venv\Scripts\activate.bat
if errorlevel 1 (
    echo ERROR: Failed to activate virtual environment
    pause
    exit /b 1
)
echo ✓ Virtual environment activated
echo.

echo [3/5] Installing dependencies...
pip install -r requirements.txt
if errorlevel 1 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)
echo ✓ Dependencies installed
echo.

echo [4/5] Setting up environment file...
if not exist .env (
    copy .env.example .env
    echo ✓ Environment file created (.env)
) else (
    echo ✓ Environment file already exists
)
echo.

echo [5/5] Starting Flask server...
echo.
echo ================================================
echo Server will start at: http://localhost:5000
echo ================================================
echo.
echo Press Ctrl+C to stop the server
echo.
python app.py

pause
