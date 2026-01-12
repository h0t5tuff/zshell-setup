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
#ROOT
r() {
  if [[ ! -f "$1" ]]; then
    echo "eeestupidooo"
    return 1
  fi
  root -l "$1" -e 'new TBrowser();'
}
# DAQ
alias daq='ssh -X daq'
cpycaen() { scp daq:~/ROOT/bacon2Data/compiled/caenData/"$1" . }
cpygold() { scp daq:~/ROOT/bacon2Data/compiledGold/"$1" . }
cpybm() { scp "$1" daq:/home/bacon/BaconMonitor/ }

# ╭───────────────────────────────╮
# │      ✅ zsh PATH handling     │
# ╰───────────────────────────────╯
typeset -gU path

# ╭───────────────────────────────╮
# │       🔁 Env Reset Logic      │
# ╰───────────────────────────────╯
reset_env_paths() {
  local -a newpath
  local p
  for p in $path; do
    [[ "$p" == /opt/homebrew* || "$p" == /usr/local* ]] && continue
    newpath+=("$p")
  done
  path=(/usr/bin /bin /usr/sbin /sbin $newpath)
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

  # Homebrew
  eval "$(/opt/homebrew/bin/brew shellenv)"

  # Python
  path=(/opt/homebrew/opt/python@3.12/libexec/bin /opt/homebrew/opt/python@3.12/bin $path)
  export Python3_EXECUTABLE="/opt/homebrew/opt/python@3.12/bin/python3.12"

  # User
  path=("$HOME/.local/bin" $path)

  # ROOT
  pushd /opt/homebrew > /dev/null
  . bin/thisroot.sh
  popd > /dev/null
  export ROOT_DIR="/opt/homebrew/opt/root/share/root/cmake"

  # Ensure PATH uniqueness
  typeset -gU path
}

# ╭───────────────────────────────╮
# │           💽 Intel            │
# ╰───────────────────────────────╯
amd64() {
  reset_env_paths
  export ENV_FLAVOR="🖥️"

  # Homebrew
  eval "$(/usr/local/bin/brew shellenv)"

  # User
  path=("$HOME/.local/bin" $path)

  # Ensure PATH uniqueness
  typeset -gU path
}

# ╭───────────────────────────────╮
# │         🧬 Pipx               │
# ╰───────────────────────────────╯
##export PIPX_DEFAULT_PYTHON="/opt/homebrew/opt/python@3.12/libexec/bin/python"
export PIPX_DEFAULT_PYTHON=/opt/homebrew/opt/python@3.12/bin/python3.12
alias venv="source ~/venvs/myenv/bin/activate"
alias jn='pipx run notebook'

# ╭───────────────────────────────╮
# │     🧬 Geant4                 │
# ╰───────────────────────────────╯
export GEANT4_BASE="$HOME/GEANT4/install-11.4"
if [[ -f "$GEANT4_BASE/bin/geant4.sh" ]]; then
  source "$GEANT4_BASE/bin/geant4.sh"
fi
export Geant4_DIR="$GEANT4_BASE/lib/cmake/Geant4"
path=("$GEANT4_BASE/bin" $path)
#export G4VIS_DEFAULT_DRIVER=OGLSQt
export G4VIS_DEFAULT_DRIVER=OGLIQt

# ╭───────────────────────────────╮
# │         🧬 HDF5               │
# ╰───────────────────────────────╯
export HDF5_ROOT="$HOME/HDF5/install"
export HDF5_DIR="$HDF5_ROOT/cmake"
path=("$HDF5_ROOT/bin" $path)
export CMAKE_PREFIX_PATH="$HDF5_ROOT:${CMAKE_PREFIX_PATH:-}"
export PKG_CONFIG_PATH="$HDF5_ROOT/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
export DYLD_LIBRARY_PATH="$HDF5_ROOT/lib:${DYLD_LIBRARY_PATH:-}"

# ╭───────────────────────────────╮
# │       🧬 remage               │
# ╰───────────────────────────────╯
export REMAGE_HOME="$HOME/REMAGE"
export REMAGE_PREFIX="$REMAGE_HOME/install/remage"
path=("$REMAGE_PREFIX/bin" $path)
export CMAKE_PREFIX_PATH="$REMAGE_PREFIX/lib/cmake:${CMAKE_PREFIX_PATH:-}"

# ╭───────────────────────────────╮
# │     🧬 BxDecay0               │
# ╰───────────────────────────────╯
export BXDECAY0_HOME="$HOME/BXDECAY0"
export BXDECAY0_PREFIX="$BXDECAY0_HOME/install"
export CMAKE_PREFIX_PATH="$BXDECAY0_PREFIX:${CMAKE_PREFIX_PATH:-}"
export PKG_CONFIG_PATH="$BXDECAY0_PREFIX/lib/pkgconfig:${PKG_CONFIG_PATH:-}"

# ╭───────────────────────────────╮
# │   🧬 Default Env (interactive)│
# ╰───────────────────────────────╯
export DYLD_FALLBACK_LIBRARY_PATH="$HDF5_ROOT/lib:$GEANT4_BASE/lib:$BXDECAY0_PREFIX/lib:$REMAGE_PREFIX/lib:${DYLD_FALLBACK_LIBRARY_PATH:-}"
if [[ -o interactive ]]; then
  arm64 
fi






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
