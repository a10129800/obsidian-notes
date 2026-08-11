@echo off
chcp 65001 >nul
setlocal

cd /d "C:\Users\mice\Desktop\MyQuartz"

echo.
echo =======================================
echo        更新 Quartz 網站
echo =======================================
echo.

echo [1/5] 清理 Quartz content...
if exist "content" (
    rmdir /S /Q "content"
)

mkdir "content"

echo.
echo [2/5] 複製發布資料夾...
robocopy "E:\Obsidian\1\發布" "C:\Users\mice\Desktop\MyQuartz\content" /E /XD ".obsidian"

if errorlevel 8 (
    echo.
    echo [錯誤] 複製發布資料夾失敗。
    pause
    exit /b 1
)

echo.
echo [3/5] 尋找文章中的圖片...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0找圖片.ps1"

if errorlevel 1 (
    echo.
    echo [錯誤] 圖片處理失敗。
    echo.
    pause
    exit /b 1
)

echo.
echo [4/5] 建立網站...
call npx quartz build

if errorlevel 1 (
    echo.
    echo [錯誤] Quartz 建置失敗。
    echo.
    pause
    exit /b 1
)

echo.
echo [5/5] 檢查 Git...
git status

echo.
echo =======================================
echo        準備發布
echo =======================================
echo.

git add content quartz.config.ts "找圖片.ps1" "更新網站.bat"

git diff --cached --quiet

if %errorlevel%==0 (
    echo 沒有新的內容需要發布。
    echo.
    pause
    exit /b 0
)

git commit -m "Update published notes"

if errorlevel 1 (
    echo.
    echo [錯誤] Git commit 失敗。
    pause
    exit /b 1
)

echo.
echo [完成] 上傳 GitHub...
git push origin v4

if errorlevel 1 (
    echo.
    echo [錯誤] Git push 失敗。
    pause
    exit /b 1
)

echo.
echo =======================================
echo        網站更新完成！
echo =======================================
echo.

pause