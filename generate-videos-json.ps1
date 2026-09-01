# Scans videos/, renames new files to video-001.mp4 style, and regenerates videos.json
# Usage: .\generate-videos-json.ps1

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$videosDir = Join-Path $root "videos"
$thumbnailsDir = Join-Path $root "thumbnails"
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
    @{ username = "fiona_macdonald"; displayName = "Fiona MacDonald" },
    @{ username = "rosalie_fletcher"; displayName = "Rosalie Fletcher" },
    @{ username = "imogen_shaw"; displayName = "Imogen Shaw" },
    @{ username = "genevieve_hart"; displayName = "Genevieve Hart" },
    @{ username = "celeste_barnes"; displayName = "Celeste Barnes" },
    @{ username = "arabella_sinclair"; displayName = "Arabella Sinclair" },
    @{ username = "penelope_wells"; displayName = "Penelope Wells" },
    @{ username = "cordelia_frost"; displayName = "Cordelia Frost" },
    @{ username = "tabitha_grant"; displayName = "Tabitha Grant" },
    @{ username = "miranda_hayes"; displayName = "Miranda Hayes" },
    @{ username = "juliet_stone"; displayName = "Juliet Stone" },
    @{ username = "daphne_cross"; displayName = "Daphne Cross" },
    @{ username = "lenore_vance"; displayName = "Lenore Vance" },
    @{ username = "beatrix_lane"; displayName = "Beatrix Lane" },
    @{ username = "ophelia_drake"; displayName = "Ophelia Drake" },
    @{ username = "serena_blake"; displayName = "Serena Blake" },
    @{ username = "adeline_pierce"; displayName = "Adeline Pierce" },
    @{ username = "clementine_shaw"; displayName = "Clementine Shaw" },
    @{ username = "isla_montgomery"; displayName = "Isla Montgomery" },
    @{ username = "sienna_barrett"; displayName = "Sienna Barrett" },
    @{ username = "tessa_holloway"; displayName = "Tessa Holloway" },
    @{ username = "vivienne_archer"; displayName = "Vivienne Archer" },
    @{ username = "wren_hollis"; displayName = "Wren Hollis" },
    @{ username = "alina_petrov"; displayName = "Alina Petrov" },
    @{ username = "daria_volkov"; displayName = "Daria Volkov" },
    @{ username = "anastasia_ivanova"; displayName = "Anastasia Ivanova" },
    @{ username = "natasha_sokolov"; displayName = "Natasha Sokolov" },
    @{ username = "svetlana_kuznetsova"; displayName = "Svetlana Kuznetsova" },
    @{ username = "elena_smirnova"; displayName = "Elena Smirnova" },
    @{ username = "irina_popov"; displayName = "Irina Popov" },
    @{ username = "olga_lebedev"; displayName = "Olga Lebedev" },
    @{ username = "vera_kozlov"; displayName = "Vera Kozlov" },
    @{ username = "polina_morozov"; displayName = "Polina Morozov" },
    @{ username = "katerina_orlova"; displayName = "Katerina Orlova" },
    @{ username = "yulia_fedorova"; displayName = "Yulia Fedorova" },
    @{ username = "brooke_mitchell"; displayName = "Brooke Mitchell" },
    @{ username = "tayla_harris"; displayName = "Tayla Harris" },
    @{ username = "matilda_fraser"; displayName = "Matilda Fraser" },
    @{ username = "abbey_roberts"; displayName = "Abbey Roberts" },
    @{ username = "jessica_campbell"; displayName = "Jessica Campbell" },
    @{ username = "georgia_anderson"; displayName = "Georgia Anderson" },
    @{ username = "holly_walker"; displayName = "Holly Walker" },
    @{ username = "maddison_young"; displayName = "Maddison Young" },
    @{ username = "sarah_murphy"; displayName = "Sarah Murphy" },
    @{ username = "lauren_thompson"; displayName = "Lauren Thompson" },
    @{ username = "sophie_morrison"; displayName = "Sophie Morrison" },
    @{ username = "emma_williams"; displayName = "Emma Williams" },
    @{ username = "charlotte_taylor"; displayName = "Charlotte Taylor" },
    @{ username = "ruby_martin"; displayName = "Ruby Martin" },
    @{ username = "chloe_brown"; displayName = "Chloe Brown" },
    @{ username = "amelia_davis"; displayName = "Amelia Davis" },
    @{ username = "mackenzie_tremblay"; displayName = "Mackenzie Tremblay" },
    @{ username = "bailey_macdonald"; displayName = "Bailey MacDonald" },
    @{ username = "sydney_fraser"; displayName = "Sydney Fraser" },
    @{ username = "avery_campbell"; displayName = "Avery Campbell" },
    @{ username = "riley_obrien"; displayName = "Riley O'Brien" },
    @{ username = "peyton_leblanc"; displayName = "Peyton Leblanc" },
    @{ username = "morgan_roy"; displayName = "Morgan Roy" },
    @{ username = "dakota_gagnon"; displayName = "Dakota Gagnon" },
    @{ username = "cheyenne_bouchard"; displayName = "Cheyenne Bouchard" },
    @{ username = "hannah_wilson"; displayName = "Hannah Wilson" },
    @{ username = "katelyn_prescott"; displayName = "Katelyn Prescott" },
    @{ username = "brittany_mckenzie"; displayName = "Brittany McKenzie" },
    @{ username = "ashley_sinclair"; displayName = "Ashley Sinclair" },
    @{ username = "megan_crawford"; displayName = "Megan Crawford" },
    @{ username = "rachel_harrison"; displayName = "Rachel Harrison" },
    @{ username = "lindsay_parker"; displayName = "Lindsay Parker" },
    @{ username = "allison_cooper"; displayName = "Allison Cooper" },
    @{ username = "samantha_reed"; displayName = "Samantha Reed" },
    @{ username = "nicole_foster"; displayName = "Nicole Foster" },
    @{ username = "stephanie_brooks"; displayName = "Stephanie Brooks" },
    @{ username = "rebecca_price"; displayName = "Rebecca Price" },
    @{ username = "danielle_ward"; displayName = "Danielle Ward" },
    @{ username = "courtney_ross"; displayName = "Courtney Ross" },
    @{ username = "jordan_murphy"; displayName = "Jordan Murphy" },
    @{ username = "taylor_sullivan"; displayName = "Taylor Sullivan" },
    @{ username = "alexis_kelly"; displayName = "Alexis Kelly" },
    @{ username = "brianna_collins"; displayName = "Brianna Collins" },
    @{ username = "hailey_stewart"; displayName = "Hailey Stewart" },
    @{ username = "jasmine_murray"; displayName = "Jasmine Murray" },
    @{ username = "savannah_macdonald"; displayName = "Savannah MacDonald" },
    @{ username = "ariana_petrov"; displayName = "Ariana Petrov" },
    @{ username = "lillian_volkov"; displayName = "Lillian Volkov" },
    @{ username = "audrey_ivanova"; displayName = "Audrey Ivanova" },
    @{ username = "caroline_sokolov"; displayName = "Caroline Sokolov" },
    @{ username = "victoria_kuznetsova"; displayName = "Victoria Kuznetsova" },
    @{ username = "grace_smirnova"; displayName = "Grace Smirnova" },
    @{ username = "lily_popov"; displayName = "Lily Popov" },
    @{ username = "zoe_lebedev"; displayName = "Zoe Lebedev" },
    @{ username = "mia_kozlov"; displayName = "Mia Kozlov" },
    @{ username = "ava_morozov"; displayName = "Ava Morozov" },
    @{ username = "ella_orlova"; displayName = "Ella Orlova" },
    @{ username = "scarlett_fedorova"; displayName = "Scarlett Fedorova" },
    @{ username = "paige_mitchell"; displayName = "Paige Mitchell" },
    @{ username = "jade_fraser"; displayName = "Jade Fraser" },
    @{ username = "keira_anderson"; displayName = "Keira Anderson" },
    @{ username = "molly_walker"; displayName = "Molly Walker" },
    @{ username = "zara_thompson"; displayName = "Zara Thompson" },
    @{ username = "isabella_morrison"; displayName = "Isabella Morrison" },
    @{ username = "olivia_williams"; displayName = "Olivia Williams" },
    @{ username = "sophia_taylor"; displayName = "Sophia Taylor" },
    @{ username = "ava_martin"; displayName = "Ava Martin" },
    @{ username = "mia_brown"; displayName = "Mia Brown" },
    @{ username = "lucy_davis"; displayName = "Lucy Davis" },
    @{ username = "freya_sinclair"; displayName = "Freya Sinclair" },
    @{ username = "maeve_oconnell"; displayName = "Maeve OConnell" },
    @{ username = "niamh_gallagher"; displayName = "Niamh Gallagher" },
    @{ username = "orla_kennedy"; displayName = "Orla Kennedy" }
)

$extraFirstNames = @(
    "Abigail", "Addison", "Adriana", "Ainsley", "Alana", "Amber", "Annika", "April", "Astrid", "Autumn",
    "Belinda", "Bethany", "Blair", "Bridget", "Bronwyn", "Callie", "Cassandra", "Cecilia", "Celine", "Clara",
    "Colette", "Diana", "Eden", "Elisa", "Eloise", "Emilia", "Esther", "Felicity", "Flora", "Gabrielle",
    "Gemma", "Giselle", "Holly", "Ilona", "Irene", "Jacqueline", "Jenna", "Joanna", "Josephine", "Joy",
    "Judith", "Katrina", "Keira", "Kelsey", "Kristen", "Lana", "Leslie", "Lillian", "Lydia", "Mabel",
    "Madeleine", "Marina", "Melanie", "Michelle", "Miriam", "Monica", "Naomi", "Nicole", "Noelle", "Odette",
    "Paige", "Paula", "Renata", "Rhiannon", "Sabrina", "Selena", "Simone", "Sonia", "Sylvia", "Tamara",
    "Tiffany", "Trinity", "Valeria", "Vanessa", "Veronica", "Victoria", "Viola", "Wendy", "Whitney", "Yvette",
    "Anastasia", "Daria", "Irina", "Katya", "Larisa", "Marina", "Nadia", "Oksana", "Tatiana", "Veronika",
    "Aroha", "Maia", "Kiri", "Anahera", "Hine", "Ria", "Tia", "Nikau", "Piper", "Quinn"
)

$extraLastNames = @(
    "Anderson", "Bailey", "Bennett", "Brooks", "Campbell", "Carter", "Clark", "Collins", "Cooper", "Crawford",
    "Davis", "Edwards", "Evans", "Fisher", "Foster", "Fraser", "Graham", "Grant", "Green", "Hall",
    "Hamilton", "Harrison", "Hayes", "Henderson", "Hughes", "Jackson", "Johnson", "Jones", "Kelly", "King",
    "Lawson", "Lee", "Lewis", "MacDonald", "Martin", "Mason", "Mitchell", "Moore", "Morgan", "Morris",
    "Murphy", "Murray", "Nelson", "Parker", "Patterson", "Phillips", "Powell", "Reed", "Richardson", "Roberts",
    "Robinson", "Rogers", "Ross", "Russell", "Scott", "Simpson", "Smith", "Stewart", "Taylor", "Thomas",
    "Thompson", "Turner", "Walker", "Ward", "Watson", "White", "Williams", "Wilson", "Wood", "Wright",
    "Tremblay", "Gagnon", "Roy", "Bouchard", "Leblanc", "Cote", "Pelletier", "Beaulieu", "Lavoie", "Fortin",
    "Ivanova", "Petrov", "Volkov", "Sokolov", "Kuznetsova", "Smirnova", "Popov", "Lebedev", "Kozlov", "Morozov",
    "Fedorova", "Orlova", "Romanova", "Vasilieva", "Nikolaeva", "Pavlova", "Semenova", "Vinogradova", "Borisova", "Grigorieva"
)

$disallowedUsernamePattern = '^(priya|ananya|meera|yasmin|sana|tara|uma|rhea)_|_(khan|sharma|patel|reddy|mehra|kapoor|nair|iyer|ali|tanaka|nakamura|chen|wong|liu|lim|sato|cho|yamamoto|suzuki|fujita|itoh|aoki|matsumoto|inoue|hayashi|kobayashi|mori|ishikawa|yamada|endo|goto|ikeda|ota|abe|petit|laurent|roux|silva|costa|santos|oliveira|vargas|cruz|kowalski|kowalczyk|novak|horvat|jovanovic|popescu|bauer|berg)$|^user_\d+$'

if (-not (Test-Path $videosDir)) {
    Write-Error "videos/ folder not found at $videosDir"
}

if (-not (Test-Path $thumbnailsDir)) {
    New-Item -ItemType Directory -Path $thumbnailsDir | Out-Null
    Write-Host "Created thumbnails/ folder."
}

function Ensure-Thumbnail {
    param(
        [string]$VideoPath,
        [string]$ThumbnailPath
    )

    if (Test-Path $ThumbnailPath) {
        return
    }

    $ffmpegArgs = @(
        "-y",
        "-ss", "00:00:01",
        "-i", $VideoPath,
        "-vframes", "1",
        "-q:v", "2",
        $ThumbnailPath
    )

    $prevErrorAction = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        & ffmpeg @ffmpegArgs 2>&1 | Out-Null
    } finally {
        $ErrorActionPreference = $prevErrorAction
    }
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Failed to create thumbnail for $VideoPath"
    }
}

$config = Get-Content $configPath -Raw | ConvertFrom-Json
$baseUrl = "https://$($config.owner).github.io/$($config.repo)"

if (Test-Path $profilesPath) {
    $profiles = Get-Content $profilesPath -Raw | ConvertFrom-Json
} else {
    $profiles = @{}
}

function Get-UsedUsernames {
    $used = @()
    foreach ($prop in $profiles.PSObject.Properties) {
        $used += $prop.Value.username
    }
    return $used
}

function New-UniqueGirlProfile {
    param([string[]]$UsedUsernames)

    $available = @($namePool | Where-Object { $UsedUsernames -notcontains $_.username })
    if ($available.Count -gt 0) {
        return $available[0]
    }

    foreach ($first in $extraFirstNames) {
        foreach ($last in $extraLastNames) {
            $username = "$($first.ToLower())_$($last.ToLower())"
            if ($UsedUsernames -notcontains $username) {
                return @{
                    username    = $username
                    displayName = "$first $last"
                }
            }
        }
    }

    throw "Ran out of unique girl names. Expand name lists in generate-videos-json.ps1."
}

function Test-AllowedProfile {
    param($Profile)
    return $Profile.username -notmatch $disallowedUsernamePattern
}

function Get-OrAssignProfile {
    param([string]$VideoId)

    if ($profiles.PSObject.Properties.Name -contains $VideoId) {
        $existing = $profiles.$VideoId
        if (Test-AllowedProfile -Profile $existing) {
            return $existing
        }
    }

    $profile = New-UniqueGirlProfile -UsedUsernames (Get-UsedUsernames)
    $profiles | Add-Member -NotePropertyName $VideoId -NotePropertyValue $profile -Force
    return $profile
}

function Get-NextVideoNumber {
    param([string[]]$ExistingNames)
    $max = 0
    foreach ($name in $ExistingNames) {
        if ($name -cmatch '^video-(\d{3})\.mp4$') {
            $num = [int]$Matches[1]
            if ($num -gt $max) { $max = $num }
        }
    }
    return $max + 1
}

$allFiles = Get-ChildItem $videosDir -File -Filter "*.mp4"
$alreadyNamed = @($allFiles | Where-Object { $_.Name -cmatch '^video-\d{3}\.mp4$' })
$needsRename = @($allFiles | Where-Object { $_.Name -cnotmatch '^video-\d{3}\.mp4$' } | Sort-Object LastWriteTime, Name)

$nextNum = Get-NextVideoNumber -ExistingNames @($allFiles.Name)
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

$videoFiles = Get-ChildItem $videosDir -File -Filter "*.mp4" |
    Where-Object { $_.Name -cmatch '^video-\d{3}\.mp4$' } |
    Sort-Object {
        if ($_.Name -cmatch '^video-(\d{3})\.mp4$') { [int]$Matches[1] } else { 9999 }
    }

$videos = @()
$order = 1
foreach ($file in $videoFiles) {
    $id = $file.BaseName
    $profile = Get-OrAssignProfile -VideoId $id
    $thumbnailFilename = "$id.jpg"
    $thumbnailPath = Join-Path $thumbnailsDir $thumbnailFilename
    Ensure-Thumbnail -VideoPath $file.FullName -ThumbnailPath $thumbnailPath
    $thumbnailSizeBytes = if (Test-Path $thumbnailPath) { (Get-Item $thumbnailPath).Length } else { 0 }

    $videos += [ordered]@{
        id                = $id
        username          = $profile.username
        displayName       = $profile.displayName
        filename          = $file.Name
        url               = "$baseUrl/videos/$($file.Name)"
        thumbnailFilename = $thumbnailFilename
        thumbnailUrl      = "$baseUrl/thumbnails/$thumbnailFilename"
        sizeBytes         = $file.Length
        thumbnailSizeBytes = $thumbnailSizeBytes
        order             = $order
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
