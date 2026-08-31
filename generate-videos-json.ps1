# Scans videos/, renames new files to video-001.mp4 style, and regenerates videos.json
# Usage: .\generate-videos-json.ps1

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$videosDir = Join-Path $root "videos"
$configPath = Join-Path $root "github-config.json"
$profilesPath = Join-Path $root "video-profiles.json"
$outputPath = Join-Path $root "videos.json"

$namePool = @(
    @{ username = "scarlett_wright"; displayName = "Scarlett Wright" },
    @{ username = "violet_hughes"; displayName = "Violet Hughes" },
    @{ username = "stella_cooper"; displayName = "Stella Cooper" },
    @{ username = "maya_bennett"; displayName = "Maya Bennett" },
    @{ username = "claire_foster"; displayName = "Claire Foster" },
    @{ username = "audrey_brooks"; displayName = "Audrey Brooks" },
    @{ username = "hazel_price"; displayName = "Hazel Price" },
    @{ username = "savannah_ward"; displayName = "Savannah Ward" },
    @{ username = "autumn_ross"; displayName = "Autumn Ross" },
    @{ username = "skylar_bailey"; displayName = "Skylar Bailey" },
    @{ username = "paisley_reed"; displayName = "Paisley Reed" },
    @{ username = "willow_morgan"; displayName = "Willow Morgan" },
    @{ username = "piper_sullivan"; displayName = "Piper Sullivan" },
    @{ username = "quinn_murphy"; displayName = "Quinn Murphy" },
    @{ username = "reagan_kelly"; displayName = "Reagan Kelly" },
    @{ username = "sloane_parker"; displayName = "Sloane Parker" },
    @{ username = "teagan_collins"; displayName = "Teagan Collins" },
    @{ username = "blair_stewart"; displayName = "Blair Stewart" },
    @{ username = "caitlin_murray"; displayName = "Caitlin Murray" },
    @{ username = "fiona_macdonald"; displayName = "Fiona MacDonald" }
)

if (-not (Test-Path $videosDir)) {
    Write-Error "videos/ folder not found at $videosDir"
}

$config = Get-Content $configPath -Raw | ConvertFrom-Json
$baseUrl = "https://$($config.owner).github.io/$($config.repo)"

if (Test-Path $profilesPath) {
    $profiles = Get-Content $profilesPath -Raw | ConvertFrom-Json
} else {
    $profiles = @{}
}

function Get-OrAssignProfile {
    param([string]$VideoId)

    if ($profiles.PSObject.Properties.Name -contains $VideoId) {
        return $profiles.$VideoId
    }

    $usedUsernames = @()
    foreach ($prop in $profiles.PSObject.Properties) {
        $usedUsernames += $prop.Value.username
    }

    $available = @($namePool | Where-Object { $usedUsernames -notcontains $_.username })
    if ($available.Count -eq 0) {
        $suffix = Get-Random -Minimum 100 -Maximum 9999
        $profile = @{
            username    = "user_$suffix"
            displayName = "User $suffix"
        }
    } else {
        $profile = $available[0]
    }

    $profiles | Add-Member -NotePropertyName $VideoId -NotePropertyValue $profile -Force
    return $profile
}

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
    $profile = Get-OrAssignProfile -VideoId $id
    $videos += [ordered]@{
        id          = $id
        username    = $profile.username
        displayName = $profile.displayName
        filename    = $file.Name
        url         = "$baseUrl/videos/$($file.Name)"
        sizeBytes   = $file.Length
        order       = $order
    }
    $order++
}

$profiles | ConvertTo-Json -Depth 5 | ForEach-Object {
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($profilesPath, $_, $utf8NoBom)
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
