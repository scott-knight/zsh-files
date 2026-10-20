# After rbenv-gemset: .ruby-gemset (GEM_HOME set) is the flag.
# Load the RubyGems filter so core contributes default gems + Gemfile.lock
# names only. Junk in the core gemdir stays on disk but is not visible.

[[ -z ${GEM_HOME:-} ]] && return

_filter_rb="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)/lib/gemset_core_filter.rb"
[[ -f $_filter_rb ]] || return

case " ${RUBYOPT-} " in
  *" -r${_filter_rb} "*|*" -r${_filter_rb}"*) ;;
  *)
    if [[ -n ${RUBYOPT-} ]]; then
      export RUBYOPT="-r${_filter_rb} ${RUBYOPT}"
    else
      export RUBYOPT="-r${_filter_rb}"
    fi
    ;;
esac
unset _filter_rb
