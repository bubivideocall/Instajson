# Instajson — Video API for Android

JSON API for serving videos from GitHub Pages to your Android app.

## Setup

1. Edit `github-config.json` with your GitHub username and repo name:
   ```json
   {
     "owner": "your-username",
     "repo": "Instajson",
     "branch": "main"
   }
   ```

2. Enable **GitHub Pages** on the `main` branch (Settings → Pages).

3. Push this repo to GitHub (including the `videos/` folder).

## API endpoint

After pushing to GitHub, your Android app can fetch:

```
https://YOUR_USERNAME.github.io/Instajson/videos.json
```

Each video entry includes a direct `url` to the MP4 file on GitHub Pages.

## Adding new videos

1. Drop new `.mp4` files into the `videos/` folder (any filename).
2. Run:
   ```powershell
   .\generate-videos-json.ps1
   ```
3. Commit and push `videos/`, `thumbnails/`, `videos.json`, and any renamed files.

The script will:
- Rename new videos to `video-029.mp4`, `video-030.mp4`, etc.
- Keep existing `video-XXX.mp4` names unchanged
- Extract a thumbnail JPG into `thumbnails/` for each video (requires [ffmpeg](https://ffmpeg.org/))
- Regenerate `videos.json` with updated GitHub Pages URLs and count

## JSON structure

```json
{
  "version": 1,
  "lastUpdated": "2026-08-31T12:00:00Z",
  "baseUrl": "https://your-username.github.io/Instajson",
  "totalVideos": 28,
  "videos": [
    {
      "id": "video-001",
      "username": "emma_wilson",
      "displayName": "Emma Wilson",
      "filename": "video-001.mp4",
      "url": "https://your-username.github.io/Instajson/videos/video-001.mp4",
      "thumbnailFilename": "video-001.jpg",
      "thumbnailUrl": "https://your-username.github.io/Instajson/thumbnails/video-001.jpg",
      "sizeBytes": 7452953,
      "thumbnailSizeBytes": 42180,
      "order": 1
    }
  ]
}
```

## Android usage example

```kotlin
// Fetch video list
val response = URL("https://bubivideocall.github.io/Instajson/videos.json").readText()
// Parse JSON and use video.url for ExoPlayer / MediaPlayer
```
