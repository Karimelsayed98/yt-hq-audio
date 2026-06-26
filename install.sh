#!/usr/bin/env bash
#
# install.sh — install the dependencies yt-audio needs:
#   * yt-dlp + ffmpeg  (YouTube and most sites)
#   * spotdl           (Spotify links → matched & downloaded from YouTube)
#
# Supports macOS (Homebrew) and Linux (apt / dnf / pacman + pipx).
#
set -euo pipefail

info() { printf '\033[36m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '\033[33m!\033[0m %s\n' "$*"; }
die()  { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

OS="$(uname -s)"

# spotdl is a Python CLI — installed with pipx into its own isolated env.
# Note: spotdl does not yet support Python 3.14, so we prefer 3.13/3.12 when present.
pick_python() {
  for v in 3.13 3.12 3.11 3.10; do
    if have "python$v"; then command -v "python$v"; return; fi
    for p in "/opt/homebrew/opt/python@$v/bin/python$v" "/usr/local/opt/python@$v/bin/python$v"; do
      [[ -x "$p" ]] && { echo "$p"; return; }
    done
  done
  return 1
}

install_spotdl() {
  have pipx || { info "Installing pipx..."; if have brew; then brew install pipx; elif have pip3; then pip3 install --user pipx; fi; }
  have pipx || { warn "pipx unavailable — skipping spotdl (Spotify links won't work)."; return; }
  pipx ensurepath >/dev/null 2>&1 || true

  local py; py="$(pick_python || true)"
  info "Installing spotdl via pipx${py:+ (Python: $py)}..."
  local installed=0
  # Select the interpreter via PIPX_DEFAULT_PYTHON — pipx ignores --python when
  # --force is given, but honours the env var for both fresh and forced installs.
  if [[ -n "$py" ]]; then
    PIPX_DEFAULT_PYTHON="$py" pipx install spotdl --force && installed=1
  else
    pipx install spotdl --force && installed=1
  fi
  [[ $installed -eq 1 ]] || { warn "spotdl install failed — Spotify links won't work until it's fixed."; return; }

  # Keep spotdl's bundled yt-dlp current — an outdated one fails on YouTube.
  info "Updating yt-dlp inside spotdl..."
  pipx inject spotdl yt-dlp --force >/dev/null 2>&1 || true
}

install_macos() {
  have brew || die "Homebrew not found. Install it from https://brew.sh then re-run."
  info "Installing yt-dlp + ffmpeg via Homebrew..."
  brew install yt-dlp ffmpeg
  install_spotdl
}

install_linux() {
  if have apt-get; then
    info "Installing ffmpeg via apt..."; sudo apt-get update && sudo apt-get install -y ffmpeg pipx
  elif have dnf; then
    info "Installing ffmpeg via dnf...";  sudo dnf install -y ffmpeg pipx
  elif have pacman; then
    info "Installing ffmpeg via pacman..."; sudo pacman -S --noconfirm ffmpeg python-pipx
  else
    die "No supported package manager found. Install ffmpeg manually."
  fi

  if have pipx; then
    info "Installing yt-dlp via pipx..."; pipx install yt-dlp --force || pipx upgrade yt-dlp || true
  elif have pip3; then
    info "Installing yt-dlp via pip3..."; pip3 install --user --upgrade yt-dlp
  else
    die "Need pipx or pip3 to install yt-dlp. Install Python first."
  fi

  install_spotdl

  cat <<'EOF'
Note: YouTube sometimes needs a JS runtime (deno) to solve player challenges.
If downloads fail with a "challenge" error, install deno:  https://deno.land
EOF
}

case "$OS" in
  Darwin) install_macos ;;
  Linux)  install_linux ;;
  *)      die "Unsupported OS: $OS (install yt-dlp, ffmpeg and spotdl manually)" ;;
esac

# Make sure pipx's bin dir is visible for the checks below.
export PATH="$HOME/.local/bin:$PATH"

echo
have yt-dlp && ok "yt-dlp $(yt-dlp --version 2>/dev/null)"
have ffmpeg && ok "ffmpeg $(ffmpeg -version 2>/dev/null | head -1 | awk '{print $3}')"
have spotdl && ok "spotdl $(spotdl --version 2>/dev/null)" || warn "spotdl not installed (Spotify links unavailable)"
echo
if have spotdl && ! echo "$PATH" | tr ':' '\n' | grep -qx "$HOME/.local/bin"; then
  warn "Add this to your shell profile so 'spotdl' is found:  export PATH=\"\$HOME/.local/bin:\$PATH\""
  warn "Then open a new terminal (or run: pipx ensurepath && exec \$SHELL)."
fi
ok "Setup complete. Try:  ./yt-audio 'https://www.youtube.com/watch?v=...'"
