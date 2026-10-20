# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# SPACESHIP_USER_SHOW=always
# SPACESHIP_DIR_TRUNC_PREFIX=../
SPACESHIP_TIME_COLOR=blue
SPACESHIP_TIME_SHOW=true
SPACESHIP_DIR_TRUNC=0
SPACESHIP_PACKAGE_SHOW=false
SPACESHIP_DIR_TRUNC_REPO=true
SPACESHIP_RUBY_SHOW=true
SPACESHIP_NODE_SHOW=true
SPACESHIP_BATTERY_SHOW=false
SPACESHIP_PROMPT_ASYNC=false

# BREW
eval "$(/opt/homebrew/bin/brew shellenv)"
HOMEBREW_CASK_OPTS="--no-quarantine"
export PODMAN=/opt/homebrew/bin/podman

# DB client PATH / mysql-client gem flags: see zsh_fn_base_helpers / LOCAL_ENV in $ZSH_FILES/.zsh_functions
#   .zsh_mysql57     (Podman MySQL 5.7) — LOCAL_ENV=rk
#   .zsh_mariadb10-5 (brew MariaDB 10.5) — LOCAL_ENV=rk (skipped by default)

# export Paths
export PATH="/opt/homebrew/opt/curl/bin:/opt/homebrew/opt/ruby/bin:$PATH"
# export PATH="/opt/homebrew/opt/mysql@8.4/bin:$PATH"
export PATH="$(brew --prefix)/opt/python/libexec/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Memcached
# /opt/homebrew/opt/memcached/bin/memcached -l localhost

# RBENV
export RBENV_ROOT="${HOME}/.rbenv"
export PATH="${RBENV_ROOT}/bin:${RBENV_ROOT}/shims:$PATH"
if which rbenv > /dev/null; then eval "$(${RBENV_ROOT}/bin/rbenv init - zsh)"; fi

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/sknight/.lmstudio/bin"
# End of LM Studio CLI section

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

autoload -U add-zsh-hook
load-nvmrc() {
  local nvmrc_path
  nvmrc_path="$(nvm_find_nvmrc)"
  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version
    nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")
    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
      nvm use
    fi
  elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# Sourced from $ZSH_FILES (set by ~/.zshrc). .zshrc_envs already loaded from $HOME.
zsh_core_helpers=(
  .zsh_alias_list
  .zsh_functions
)

for _zsh_core in "${zsh_core_helpers[@]}"; do
  _zsh_core_path="$ZSH_FILES/$_zsh_core"
  if [ -f "$_zsh_core_path" ]; then
    source "$_zsh_core_path"
    echo "using ${_zsh_core_path}"
  else
    echo "not sure what happened with ${_zsh_core_path}"
  fi
done
unset _zsh_core _zsh_core_path

source $(brew --prefix)/opt/spaceship/spaceship.zsh
source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
