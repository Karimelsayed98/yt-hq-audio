# yt-hq-audio

Download **high-quality audio** from **YouTube and Spotify** (and most other
sites) by just pasting links. Grabs the best available audio stream and, by
default, keeps it in its **native codec with no lossy re-encoding**.

## 1. Install dependencies (one time)

```bash
./install.sh
```

This installs the tools needed:

| Tool       | Role                                                      |
|------------|-----------------------------------------------------------|
| **yt-dlp** | Downloads audio from YouTube and most sites               |
| **ffmpeg** | Extracts / converts audio, embeds metadata + cover art    |
| **spotdl** | Handles Spotify links (see “How Spotify works” below)     |

- **macOS:** uses Homebrew for yt-dlp/ffmpeg and pipx for spotdl. Install Homebrew first from <https://brew.sh> if you don't have it.
- **Linux:** installs ffmpeg via apt/dnf/pacman and yt-dlp/spotdl via pipx.

## 2. Download audio

```bash
# YouTube — best quality, native Opus, no re-encoding (default)
./yt-audio "https://www.youtube.com/watch?v=k2CjGx_mLOg"

# Spotify — track, album, or playlist
./yt-audio "https://open.spotify.com/track/xxxxxxxxxxxx"
./yt-audio "https://open.spotify.com/playlist/xxxxxxxxxxxx"

# Mix several links of either kind at once
./yt-audio "https://youtu.be/AAA" "https://open.spotify.com/track/BBB"

# From a file of links (one URL per line — YouTube and Spotify can be mixed)
./yt-audio -b links.txt
```

Files land in `./downloads/` by default.

## How Spotify works (important)

Spotify's own audio is **DRM-protected and cannot be downloaded**. So for a
Spotify link, `spotdl`:

1. Reads only the **metadata** (title, artist, album, cover art) from Spotify.
2. Finds the **matching song on YouTube** and downloads that audio.

In other words, a Spotify link is used as a *song list* — the audio itself comes
from YouTube, so quality is YouTube-quality (lossy ~130–160 kbps), not Spotify's
stream. No Spotify login or API keys are required.

## Options

```
-f, --format FMT   opus (default) | m4a | mp3 | flac | wav
-o, --outdir DIR   output directory (default: ./downloads)
-b, --batch FILE   read URLs from FILE (one per line, # comments allowed)
-h, --help         show help
```

### Which format?

| Format   | Quality                          | Use when…                                  |
|----------|----------------------------------|--------------------------------------------|
| **opus** | Best — native, no re-encode      | Default. You just want the best audio.     |
| **m4a**  | Native AAC, no double-compress   | You need Apple/QuickTime compatibility.    |
| **mp3**  | Lossy re-encode                  | You need it to play literally everywhere.  |
| **flac** | Lossless container               | A tool requires FLAC input.                |
| **wav**  | Lossless 16-bit/48 kHz PCM       | A DAW/editor requires WAV input. (~650 MB/hr) |

> ⚠️ The source audio is already lossy (~130–160 kbps). Converting to
> **wav/flac** does **not** improve quality — it only makes a much bigger file.
> Use them only when a specific app demands that format.

## Examples

```bash
./yt-audio -f mp3 "https://youtu.be/dQw4w9WgXcQ"
./yt-audio -f wav -o ~/Music/stems "https://youtu.be/dQw4w9WgXcQ"
./yt-audio -b links.txt -f m4a
./yt-audio -f flac "https://open.spotify.com/album/xxxxxxxxxxxx"
```

## Legal note

Downloading copyrighted music — whether via YouTube or Spotify links — is
generally against those platforms' Terms of Service and may infringe copyright
depending on your jurisdiction. Use this only for content you own or have the
right to download.

## Troubleshooting

- **`yt-dlp`/`ffmpeg`/`spotdl` not found** → run `./install.sh`. If `spotdl`
  still isn't found, add pipx's bin dir to your PATH:
  `export PATH="$HOME/.local/bin:$PATH"` (then open a new terminal).
- **YouTube "challenge" / signature errors** → update yt-dlp (`brew upgrade yt-dlp`).
  On Linux you may also need [deno](https://deno.land).
- **spotdl install fails on Python 3.14** → spotdl needs Python ≤3.13;
  `install.sh` auto-selects 3.13/3.12 when available. Install one with
  `brew install python@3.13` (macOS) and re-run.
- **Spotify download produces no file / HTTP 403** → this tool already works
  around two spotdl quirks (it writes nothing on absolute `--output` paths, and
  its default YouTube client gets 403) by writing into the output dir directly
  and forcing the `android_vr` player client. If it still fails, refresh
  spotdl's bundled downloader: `pipx inject spotdl yt-dlp --force`.
- **Age-restricted / private videos** → may require cookies; see
  `yt-dlp --help` (`--cookies-from-browser`).
