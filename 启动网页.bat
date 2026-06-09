@echo off
chcp 65001 >nul
title LIUBOHUI 舞蹈摄影师 - 本地服务器
echo.
echo ============================================
echo   LIUBOHUI · 小辉 · 舞蹈摄影师
echo   正在启动本地服务器...
echo ============================================
echo.

REM 切换到脚本所在目录
cd /d "%~dp0"

set PORT=8080

REM 用 PowerShell 启动 HTTP 服务器并打开浏览器
powershell.exe -ExecutionPolicy Bypass -NoProfile -Command "
    $port = %PORT%
    $root = (Get-Location).Path
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add('http://localhost:' + $port + '/')
    try {
        $listener.Start()
        Write-Host ('')
        Write-Host ('  服务器已启动！') -ForegroundColor Green
        Write-Host ('  访问地址: http://localhost:' + $port + '/portfolio.html') -ForegroundColor Cyan
        Write-Host ('')
        Write-Host ('  正在打开浏览器...') -ForegroundColor Yellow
        Write-Host ('')
        Write-Host ('  提示: 关闭此窗口即可停止服务器') -ForegroundColor DarkGray
        Write-Host ('')
        Start-Sleep -Milliseconds 500
        Start-Process ('http://localhost:' + $port + '/portfolio.html')
        while ($listener.IsListening) {
            $ctx = $listener.GetContext()
            $req = $ctx.Request
            $res = $ctx.Response
            $path = $req.Url.LocalPath.TrimStart('/')
            if ($path -eq '') { $path = 'portfolio.html' }
            $file = Join-Path $root $path
            if (Test-Path $file -PathType Leaf) {
                $ext = [IO.Path]::GetExtension($file).ToLower()
                $mime = switch ($ext) {
                    '.html' { 'text/html; charset=utf-8' }
                    '.css'  { 'text/css' }
                    '.js'   { 'application/javascript' }
                    '.mp4'  { 'video/mp4' }
                    '.mov'  { 'video/quicktime' }
                    '.png'  { 'image/png' }
                    '.jpg'  { 'image/jpeg' }
                    '.jpeg' { 'image/jpeg' }
                    '.svg'  { 'image/svg+xml' }
                    '.woff2'{ 'font/woff2' }
                    default { 'application/octet-stream' }
                }
                $res.ContentType = $mime
                $bytes = [IO.File]::ReadAllBytes($file)
                $res.ContentLength64 = $bytes.Length
                $res.OutputStream.Write($bytes, 0, $bytes.Length)
            } else {
                $res.StatusCode = 404
                $msg = [Text.Encoding]::UTF8.GetBytes('404 Not Found')
                $res.ContentLength64 = $msg.Length
                $res.OutputStream.Write($msg, 0, $msg.Length)
            }
            $res.OutputStream.Close()
        }
    } catch {
        Write-Host ('')
        Write-Host ('  启动失败: ' + $_.Exception.Message) -ForegroundColor Red
        Write-Host ('')
    } finally {
        $listener.Stop()
    }
"

echo.
pause
