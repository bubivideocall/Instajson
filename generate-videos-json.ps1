# Scans videos/, renames new files to video-001.mp4 style, and regenerates videos.json
# Usage: .\generate-videos-json.ps1

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$videosDir = Join-Path $root "videos"
$configPath = Join-Path $root "github-config.json"
$profilesPath = Join-Path $root "video-profiles.json"
$outputPath = Join-Path $root "videos.json"

$namePool = @(
    @{ username = "shreya_bakshi"; displayName = "Shreya Bakshi" },
    @{ username = "tara_mehta"; displayName = "Tara Mehta" },
    @{ username = "uma_sharma"; displayName = "Uma Sharma" },
    @{ username = "vidya_nambiar"; displayName = "Vidya Nambiar" },
    @{ username = "wafa_ansari"; displayName = "Wafa Ansari" },
    @{ username = "xara_khan"; displayName = "Xara Khan" },
    @{ username = "yashika_reddy"; displayName = "Yashika Reddy" },
    @{ username = "zoya_malik"; displayName = "Zoya Malik" },
    @{ username = "amrita_suri"; displayName = "Amrita Suri" },
    @{ username = "barkha_grover"; displayName = "Barkha Grover" },
    @{ username = "charu_oberoi"; displayName = "Charu Oberoi" },
    @{ username = "damini_rastogi"; displayName = "Damini Rastogi" },
    @{ username = "ekta_sawant"; displayName = "Ekta Sawant" },
    @{ username = "farah_qureshi"; displayName = "Farah Qureshi" },
    @{ username = "geetika_luthra"; displayName = "Geetika Luthra" },
    @{ username = "harleen_kaur"; displayName = "Harleen Kaur" },
    @{ username = "indira_puri"; displayName = "Indira Puri" },
    @{ username = "jhanvi_sood"; displayName = "Jhanvi Sood" },
    @{ username = "kamya_bhalla"; displayName = "Kamya Bhalla" },
    @{ username = "laxmi_tiwari"; displayName = "Laxmi Tiwari" }
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
