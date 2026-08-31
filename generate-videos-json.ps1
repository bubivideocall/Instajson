# Scans videos/, renames new files to video-001.mp4 style, and regenerates videos.json
# Usage: .\generate-videos-json.ps1

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$videosDir = Join-Path $root "videos"
$configPath = Join-Path $root "github-config.json"
$outputPath = Join-Path $root "videos.json"

if (-not (Test-Path $videosDir)) {
    Write-Error "videos/ folder not found at $videosDir"
}

$config = Get-Content $configPath -Raw | ConvertFrom-Json
$baseUrl = "https://$($config.owner).github.io/$($config.repo)"

function Get-NextVideoNumber {
    param([string[]]$ExistingNames)
    $max = 0
    foreach ($name in $ExistingNames) {
        if ($name -match '^video-(\d{3})\.mp4$') {
            $num = [int]$Matches[1]
            if ($num -gt $max) { $max = $num }
        }
    }
    return $max + 1
}

$allFiles = Get-ChildItem $videosDir -File -Filter "*.mp4"
$alreadyNamed = @($allFiles | Where-Object { $_.Name -match '^video-\d{3}\.mp4$' })
$needsRename = @($allFiles | Where-Object { $_.Name -notmatch '^video-\d{3}\.mp4$' } | Sort-Object LastWriteTime, Name)

$nextNum = Get-NextVideoNumber -ExistingNames @($alreadyNamed.Name)
$renamed = @()

foreach ($file in $needsRename) {
    $newName = "video-{0:D3}.mp4" -f $nextNum
    $newPath = Join-Path $videosDir $newName

    while (Test-Path $newPath) {
        $nextNum++
        $newName = "video-{0:D3}.mp4" -f $nextNum
        $newPath = Join-Path $videosDir $newName
    }

    Rename-Item -LiteralPath $file.FullName -NewName $newName
    Write-Host "Renamed: $($file.Name) -> $newName"
    $renamed += [PSCustomObject]@{ Old = $file.Name; New = $newName }
    $nextNum++
}

$videoFiles = Get-ChildItem $videosDir -File -Filter "video-*.mp4" |
    Where-Object { $_.Name -match '^video-\d{3}\.mp4$' } |
    Sort-Object {
        if ($_.Name -match '^video-(\d{3})\.mp4$') { [int]$Matches[1] } else { 9999 }
    }

$videos = @()
$order = 1
foreach ($file in $videoFiles) {
    $id = $file.BaseName
    $videos += [ordered]@{
        id        = $id
        filename  = $file.Name
        url       = "$baseUrl/videos/$($file.Name)"
        sizeBytes = $file.Length
        order     = $order
    }
    $order++
}

$output = [ordered]@{
    version     = 1
    lastUpdated = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    baseUrl     = $baseUrl
    totalVideos = $videos.Count
    videos      = $videos
}

$json = $output | ConvertTo-Json -Depth 10
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($outputPath, $json, $utf8NoBom)

Write-Host ""
Write-Host "Done! Generated $outputPath with $($videos.Count) videos."
if ($renamed.Count -gt 0) {
    Write-Host "Renamed $($renamed.Count) new file(s)."
}
