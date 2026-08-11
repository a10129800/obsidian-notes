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

# =======================================
# 1. 找出所有 Markdown
# =======================================

$MarkdownFiles = Get-ChildItem `
    -LiteralPath $Content `
    -Recurse `
    -File `
    -Filter "*.md"

Write-Host "[1/3] 掃描 Markdown 圖片引用..."
Write-Host ""

$ImageNames = New-Object System.Collections.Generic.HashSet[string]

foreach ($File in $MarkdownFiles) {

    $Text = Get-Content `
        -LiteralPath $File.FullName `
        -Raw `
        -Encoding UTF8

    # 支援：
    # ![[圖片.png]]
    # ![[圖片.png|500]]
    # ![[圖片.jpg]]
    # ![[圖片.webp]]
    # ![[圖片.svg]]

    $Pattern = '!\[\[([^\]\|]+?\.(?:png|jpg|jpeg|gif|webp|svg))(?:(?:\|)[^\]]*)?\]\]'

    $Matches = [regex]::Matches(
        $Text,
        $Pattern,
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )

    foreach ($Match in $Matches) {

        $ImageName = $Match.Groups[1].Value.Trim()

        if ($ImageNames.Add($ImageName)) {
            Write-Host "找到圖片引用: $ImageName"
        }
    }
}

Write-Host ""
Write-Host "總共找到 $($ImageNames.Count) 張圖片"
Write-Host ""

# =======================================
# 2. 搜尋並複製圖片
# =======================================

Write-Host "[2/3] 搜尋 Obsidian 圖片..."
Write-Host ""

$Copied = 0
$NotFound = 0

foreach ($ImageName in $ImageNames) {

    $Image = Get-ChildItem `
        -LiteralPath $Obsidian `
        -Recurse `
        -File `
        -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Name -eq $ImageName
        } |
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

# =======================================
# 3. 結果
# =======================================

Write-Host ""
Write-Host "[3/3] 圖片處理結果"
Write-Host ""

Write-Host "======================================="
Write-Host "圖片處理完成"
Write-Host "成功複製：$Copied 張"
Write-Host "找不到：$NotFound 張"
Write-Host "======================================="
Write-Host ""

if ($NotFound -gt 0) {
    Write-Host "[注意] 有圖片找不到。" -ForegroundColor Yellow
}

exit 0