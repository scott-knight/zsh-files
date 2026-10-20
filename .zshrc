#! /bin/zsh

# copy the contents of ~/.zshrc-copy-into-home into ~/.zshrc

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

# SPACESHIP
source $(brew --prefix)/opt/spaceship/spaceship.zsh

# BREW
eval "$(/opt/homebrew/bin/brew shellenv)"

# RBENV
export RBENV_ROOT="${HOME}/.rbenv"
export PATH="${RBENV_ROOT}/bin:${RBENV_ROOT}/shims:$PATH"
if which rbenv > /dev/null; then eval "$(${RBENV_ROOT}/bin/rbenv init - zsh)"; fi

# export Paths
export PATH="/opt/homebrew/opt/curl/bin:/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="$(brew --prefix)/opt/python/libexec/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# load variables
export RUBY_CONFIGURE_OPTS="--with-libyaml-dir=$(brew --prefix libyaml)"

if [ -f "$ZSH_FILES/.zshrc_loader" ]; then
  source "$ZSH_FILES/.zshrc_loader"
  echo "using $ZSH_FILES/.zshrc_loader"
else
  echo "not sure what happened with $ZSH_FILES/.zshrc_loader"
fi

source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
