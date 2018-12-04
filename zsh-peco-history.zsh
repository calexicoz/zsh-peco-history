# zsh-peco-history 0.9.0
#
# Search shell history with peco when pressing ctrl+r.
# https://github.com/jimeh/zsh-peco-history
#
# Requirements:
#  - peco: https://github.com/peco/peco
#  - tac, or tail with support for -r option
#  - perl, awk, or uniq for if de-duplication is turned on
#
# Based on: https://github.com/mooz/percol#zsh-history-search

if (( $+commands[peco] )); then
  function peco_select_history() {
    local parse_cmd

    if (( $+commands[gtac] )); then
      parse_cmd="gtac"
    elif (( $+commands[tac] )); then
      parse_cmd="tac"
    else
      parse_cmd="tail -r"
    fi

    if [ -n "$ZSH_PECO_HISTORY_DEDUP" ]; then
      if (( $+commands[perl] )); then
        parse_cmd="$parse_cmd | perl -ne 'print unless \$seen{\$_}++'"
      elif (( $+commands[awk] )); then
        parse_cmd="$parse_cmd | awk '!seen[\$0]++'"
      else
        parse_cmd="$parse_cmd | uniq"
      fi
    fi

    BUFFER=$(fc -l -n 1 | eval $parse_cmd | \
               peco --layout=bottom-up --query "$LBUFFER")

    CURSOR=$#BUFFER # move cursor
    zle -R -c       # refresh
  }

  zle -N peco_select_history
  bindkey '^R' peco_select_history
fi
