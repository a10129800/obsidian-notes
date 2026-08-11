$ErrorActionPreference = "Stop"

$QuartzRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$Content = Join-Path $QuartzRoot "content"
$Obsidian = "E:\Obsidian\1"

Write-Host ""
Write-Host "======================================="
Write-Host "        Quartz 圖片同步工具"
Write-Host "======================================="
Write-Host ""

if (-not (Test-Path -LiteralPath $Content)) {
    Write-Host "[錯誤] 找不到 Quartz content 資料夾。" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path -LiteralPath $Obsidian)) {
    Write-Host "[錯誤] 找不到 Obsidian 資料夾：" -ForegroundColor Red
    Write-Host $Obsidian
    exit 1
}

# 找出 content 裡所有 Markdown
$MarkdownFiles = Get-ChildItem `
    -LiteralPath $Content `
    -Filter "*.md" `
    -File `
    -Recurse

Write-Host "[1/2] 掃描 Markdown 圖片引用..."
Write-Host ""

$ImageNames = New-Object System.Collections.Generic.HashSet[string]

foreach ($File in $MarkdownFiles) {

    $Text = Get-Content `
        -LiteralPath $File.FullName `
        -Raw `
        -Encoding UTF8

    # Obsidian 圖片：
    # ![[圖片.png]]
    $Matches = [regex]::Matches(
        $Text,
        '!\[\[([^\]]+\.(png|jpg|jpeg|gif|webp|svg))\]\]',
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )

    foreach ($Match in $Matches) {
        $ImageName = $Match.Groups[1].Value.Trim()

        # 如果有 Obsidian 的尺寸，例如：
        # ![[圖片.png|500]]
        if ($ImageName.Contains("|")) {
            $ImageName = $ImageName.Split("|")[0].Trim()
        }

        if ($ImageNames.Add($ImageName)) {
            Write-Host "找到圖片引用: $ImageName"
        }
    }
}

Write-Host ""
Write-Host "[2/2] 複製圖片..."
Write-Host ""

$Copied = 0
$NotFound = 0

foreach ($ImageName in $ImageNames) {

    # 先從 Obsidian 整個資料夾搜尋
    $Image = Get-ChildItem `
        -LiteralPath $Obsidian `
        -Recurse `
        -File `
        -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -eq $ImageName } |
        Select-Object -First 1

    if ($null -eq $Image) {
        Write-Host "[找不到] $ImageName" -ForegroundColor Yellow
        $NotFound++
        continue
    }

    $Destination = Join-Path $Content $ImageName

    Copy-Item `
        -LiteralPath $Image.FullName `
        -Destination $Destination `
        -Force

    Write-Host "✓ 複製圖片: $ImageName" -ForegroundColor Green
    $Copied++
}

Write-Host ""
Write-Host "======================================="
Write-Host "圖片處理完成"
Write-Host "成功複製：$Copied 張"
Write-Host "找不到：$NotFound 張"
Write-Host "======================================="
Write-Host ""

if ($NotFound -gt 0) {
    Write-Host "[注意] 有圖片找不到，但不會中止更新。" -ForegroundColor Yellow
}

exit 0