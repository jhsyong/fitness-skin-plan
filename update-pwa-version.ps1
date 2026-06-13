param(
  [string]$SourceHtml = "..\6个月身材皮肤计划.html",
  [string]$Version = (Get-Date -Format "yyyy-MM-dd")
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourcePath = Resolve-Path (Join-Path $Root $SourceHtml)
$IndexPath = Join-Path $Root "index.html"
$VersionDir = Join-Path $Root "versions\$Version"
$VersionPath = Join-Path $VersionDir "index.html"

New-Item -ItemType Directory -Force -Path $VersionDir | Out-Null

$html = Get-Content -LiteralPath $SourcePath -Raw -Encoding utf8

$pwaHead = @"
  <meta name="theme-color" content="#3f6249">
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-title" content="身材皮肤计划">
  <meta name="apple-mobile-web-app-status-bar-style" content="default">
  <link rel="manifest" href="manifest.webmanifest">
"@

if ($html -notmatch 'rel="manifest"') {
  $html = $html -replace '(<meta name="viewport" content="width=device-width, initial-scale=1">\r?\n)', "`$1$pwaHead"
}

if ($html -notmatch '当前版本 \d{4}-\d{2}-\d{2}') {
  $html = $html -replace '(<span class="tag">120g蛋白/天</span>\r?\n)', "`$1          <span class=`"tag`">当前版本 $Version</span>`r`n"
} else {
  $html = $html -replace '当前版本 \d{4}-\d{2}-\d{2}', "当前版本 $Version"
}

$swSnippet = @"

    if ("serviceWorker" in navigator && location.protocol.startsWith("http")) {
      window.addEventListener("load", () => {
        navigator.serviceWorker.register("service-worker.js");
      });
    }
"@

if ($html -notmatch 'serviceWorker' -and $html -match 'renderWeek\(\);') {
  $html = $html -replace '(\r?\n    renderWeek\(\);)', "$swSnippet`$1"
}

Set-Content -LiteralPath $IndexPath -Value $html -Encoding utf8

$historyHtml = Get-Content -LiteralPath $SourcePath -Raw -Encoding utf8
if ($historyHtml -notmatch '历史版本 \d{4}-\d{2}-\d{2}') {
  $historyHtml = $historyHtml -replace '(<span class="tag">120g蛋白/天</span>\r?\n)', "`$1          <span class=`"tag`">历史版本 $Version</span>`r`n"
} else {
  $historyHtml = $historyHtml -replace '历史版本 \d{4}-\d{2}-\d{2}', "历史版本 $Version"
}
Set-Content -LiteralPath $VersionPath -Value $historyHtml -Encoding utf8

$swPath = Join-Path $Root "service-worker.js"
$sw = Get-Content -LiteralPath $swPath -Raw -Encoding utf8
$sw = $sw -replace 'fitness-skin-plan-v\d{4}-\d{2}-\d{2}', "fitness-skin-plan-v$Version"
$sw = $sw -replace '\./versions/\d{4}-\d{2}-\d{2}/index\.html', "./versions/$Version/index.html"
Set-Content -LiteralPath $swPath -Value $sw -Encoding utf8

$changelogPath = Join-Path $Root "CHANGELOG.md"
$entry = @"

## $Version

- 刷新 PWA 最新版入口。
- 生成历史版本：`versions/$Version/index.html`。
"@
Add-Content -LiteralPath $changelogPath -Value $entry -Encoding utf8

Write-Host "PWA updated: $IndexPath"
Write-Host "History version: $VersionPath"
