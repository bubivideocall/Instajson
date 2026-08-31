# Instajson — Video API for Android

JSON API for serving videos from GitHub to your Android app.

## Setup

1. Edit `github-config.json` with your GitHub username and repo name:
   ```json
   {
     "owner": "your-username",
     "repo": "Instajson",
     "branch": "main"
   }
   ```

2. Push this repo to GitHub (including the `videos/` folder).

## API endpoint

After pushing to GitHub, your Android app can fetch:

```
https://raw.githubusercontent.com/YOUR_USERNAME/Instajson/main/videos.json
```

Each video entry includes a direct `url` to the MP4 file on GitHub.

## Adding new videos

1. Drop new `.mp4` files into the `videos/` folder (any filename).
2. Run:
   ```powershell
   .\generate-videos-json.ps1
   ```
3. Commit and push `videos/`, `videos.json`, and any renamed files.

The script will:
- Rename new videos to `video-029.mp4`, `video-030.mp4`, etc.
- Keep existing `video-XXX.mp4` names unchanged
- Regenerate `videos.json` with updated URLs and count

## JSON structure

```json
{
  "version": 1,
  "lastUpdated": "2026-08-31T12:00:00Z",
  "baseUrl": "https://raw.githubusercontent.com/user/repo/main",
  "totalVideos": 28,
  "videos": [
    {
      "id": "video-001",
      "filename": "video-001.mp4",
      "url": "https://raw.githubusercontent.com/user/repo/main/videos/video-001.mp4",
      "sizeBytes": 7452953,
      "order": 1
    }
  ]
}
```

## Android usage example

```kotlin
// Fetch video list
val response = URL("https://raw.githubusercontent.com/YOUR_USERNAME/Instajson/main/videos.json").readText()
// Parse JSON and use video.url for ExoPlayer / MediaPlayer
```
