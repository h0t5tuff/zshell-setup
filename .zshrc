# ╭───────────────────────────────────────╮
# │       🧠 Prompt & Git                 │
# ╰───────────────────────────────────────╯
parse_git_status() {
  git rev-parse --is-inside-work-tree &>/dev/null || return
  local branch dirty ahead behind
  branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  [[ -z $(git status --porcelain 2>/dev/null) ]] && dirty="✓" || dirty="✗"
  if git rev-parse @{u} &>/dev/null; then
    read -r behind ahead <<<"$(git rev-list --left-right --count @{u}...HEAD 2>/dev/null)"
    ((ahead)) && ahead="↑$ahead" || ahead=""
    ((behind)) && behind="↓$behind" || behind=""
  else
    ahead=""
    behind=""
  fi
  echo "%F{blue}[$branch $dirty$ahead$behind]%f"
}
setopt prompt_subst
PROMPT='${ENV_FLAVOR} %F{green}τενΣΩρ%f %F{green}%~%f %F{magenta}$(parse_git_status)%f '

# ╭───────────────────────────────╮
# │          ⚡ Aliases            │
# ╰───────────────────────────────╯
alias dds='ls -hFGlast -tr; \
  echo -n "Size: "; du -sh . | cut -f1; \
  echo -n " Entries (curr): "; find . -mindepth 1 -maxdepth 1 | wc -l; \
  echo -n " Entries (all): "; find . -mindepth 1 | wc -l'
alias z='source ~/.zshrc || echo "shit"'
alias werb='brew update && brew upgrade && brew autoremove && brew cleanup && brew doctor'
alias vscodefix='echo "Run: Cmd+Shift+P → Shell Command: Install `code` in PATH"'

# DAQ
alias daq='ssh -X daq'
cpycaen() { scp daq:~/ROOT/bacon2Data/compiled/caenData/"$1" . }
cpygold() { scp daq:~/ROOT/bacon2Data/compiledGold/"$1" . }
cpybm() { scp "$1" daq:/home/bacon/BaconMonitor/ }

# Convenience: ROOT browser helper (left independent of env switching)
r() {
  if [[ ! -f "$1" ]]; then
    echo "eeestupidooo"
    return 1
  fi
  root -l "$1" -e 'new TBrowser();'
}

# ╭───────────────────────────────╮
# │      ✅ zsh PATH handling      │
# ╰───────────────────────────────╯
# Use zsh path array; keep entries unique automatically.
typeset -gU path

# ╭───────────────────────────────╮
# │       🔁 Env Reset Logic      │
# ╰───────────────────────────────╯
reset_env_paths() {
  local -a newpath
  local p

  # Remove Homebrew prefixes from current PATH array (both ARM + Intel)
  for p in $path; do
    [[ "$p" == /opt/homebrew* || "$p" == /usr/local* ]] && continue
    newpath+=("$p")
  done

  # Force a stable system baseline first
  path=(/usr/bin /bin /usr/sbin /sbin $newpath)

  # Clear common build flags that toolchains like to poison
  export LDFLAGS=""
  export CPPFLAGS=""
  export PKG_CONFIG_PATH=""
}

# ╭───────────────────────────────╮
# │       🍎 AppleSilicon         │
# ╰───────────────────────────────╯
arm64() {
  reset_env_paths
  export ENV_FLAVOR="💻"

  # Homebrew (ARM)
  eval "$(/opt/homebrew/bin/brew shellenv)"

  # Prefer python@3.12 for python3 (needs libexec/bin for python3 shim)
  path=(/opt/homebrew/opt/python@3.12/libexec/bin /opt/homebrew/opt/python@3.12/bin $path)

  # User tools
  path=("$HOME/.local/bin" $path)

  # ROOT (leave alone: use your existing thisroot.sh style)
  pushd /opt/homebrew > /dev/null
  . bin/thisroot.sh
  popd > /dev/null

  # HDF5 tooling
  path=(/opt/homebrew/opt/hdf5/bin $path)

  # Ensure PATH uniqueness after vendor scripts mutate it
  typeset -gU path
}

# ╭───────────────────────────────╮
# │           💽 Intel            │
# ╰───────────────────────────────╯
amd64() {
  reset_env_paths
  export ENV_FLAVOR="🖥️"

  # Homebrew (Intel)
  eval "$(/usr/local/bin/brew shellenv)"

  # User tools
  path=("$HOME/.local/bin" $path)

  typeset -gU path
}

# ╭───────────────────────────────╮
# │     🧬 Python & Pipx          │
# ╰───────────────────────────────╯
export PIPX_DEFAULT_PYTHON="/opt/homebrew/opt/python@3.12/libexec/bin/python"
alias venv="source ~/venvs/myenv/bin/activate"
alias jn='pipx run notebook'

# ╭───────────────────────────────╮
# │     🧬 Geant4                 │
# ╰───────────────────────────────╯
geant4() {
  # Clear common dataset vars to reduce cross-config leakage
  unset G4DATA G4INSTALL G4LEVELGAMMADATA G4NEUTRONHPDATA G4LEDATA G4RADIOACTIVEDATA \
        G4ABLADATA G4ENSDFSTATEDATA G4INCLDATA G4PARTICLEXSDATA G4PIIDATA \
        G4REALSURFACEDATA G4SAIDXSDATA G4PROTONHPDATA 2>/dev/null

  case "$1" in
    11.4)           export GEANT4_BASE="$HOME/GEANT4/install-11.4" ;;
    11.4-hdf5-st)   export GEANT4_BASE="$HOME/GEANT4/install-11.4-HDF5-xMTx" ;;
    *)
      echo "❌ Unknown Geant4 configuration: $1"
      echo "Available: 11.4 | 11.4-hdf5-st"
      return 1
      ;;
  esac

  export Geant4_DIR="$GEANT4_BASE/lib/cmake/Geant4"

  if [[ -f "$GEANT4_BASE/bin/geant4.sh" ]]; then
    source "$GEANT4_BASE/bin/geant4.sh"
  fi

  # Runtime dylib fallback (only if you rely on it)
  export DYLD_FALLBACK_LIBRARY_PATH="$GEANT4_BASE/lib:$GEANT4_BASE/lib64:${DYLD_FALLBACK_LIBRARY_PATH:-}"

  # Ensure Geant4 tools are discoverable
  path=("$GEANT4_BASE/bin" $path)
  typeset -gU path

  echo "⨷"
}

# ╭───────────────────────────────╮
# │       🧬 remage               │
# ╰───────────────────────────────╯
export REMAGE_PREFIX="$HOME/opt/remage"
path=("$REMAGE_PREFIX/bin" $path)
export CMAKE_PREFIX_PATH="$REMAGE_PREFIX/lib/cmake:${CMAKE_PREFIX_PATH:-}"
export DYLD_FALLBACK_LIBRARY_PATH="$REMAGE_PREFIX/lib:${DYLD_FALLBACK_LIBRARY_PATH:-}"

# ╭───────────────────────────────╮
# │     🧬 BxDecay0               │
# ╰───────────────────────────────╯
bxdecay0() {
  local version="${1:-1.2.1}"
  export BXDECAY0_PREFIX="$HOME/opt/bxdecay0/$version"

  export PKG_CONFIG_PATH="$BXDECAY0_PREFIX/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
  export CMAKE_PREFIX_PATH="$BXDECAY0_PREFIX:${CMAKE_PREFIX_PATH:-}"
  export DYLD_FALLBACK_LIBRARY_PATH="$BXDECAY0_PREFIX/lib:${DYLD_FALLBACK_LIBRARY_PATH:-}"

  echo "☢️"
}

# ╭───────────────────-----------────────────╮
# │         🧱 ROOT sim: bacon2Data          │
# ╰──────────────────────-----------─────────╯
export BOBJ="$HOME/ROOT/bacon2Data/bobj"
export COMPILED="$HOME/ROOT/bacon2Data/compiled"
path=("$BOBJ" "$COMPILED" $path)
typeset -gU path

# ╭───────────────────────────----------────-╮
# │☢️ GEANT4 sim: BACONCALIBRATIONSIMULATION │
# ╰───────────────────────────────-----------╯
stl() {
  echo "✔ Set BACONCALIBRATIONSIMULATION"
}

# ╭───────────────────────────────╮
# │   🧬 Default Env (interactive)│
# ╰───────────────────────────────╯
if [[ -o interactive ]]; then
  arm64 
  geant4 11.4
  bxdecay0 1.2.1
fi