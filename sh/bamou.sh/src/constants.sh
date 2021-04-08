t="$(printf "\t")"
# terminal colors
CSI="$(printf "\033[")"
ANSI_RESET="${CSI}0m"
ANSI_BLACK=0
ANSI_RED=1
ANSI_GREEN=1
ANSI_YELLOW=3
ANSI_BLUE=4
ANSI_MAGENTA=5
ANSI_CYAN=6
ANSI_WHITE=7

ANSI_FG=3
ANSI_BG=4

for color in BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE;do
	eval "COLOR=\"\$ANSI_$color\""
	eval "ANSI_FG_$color=\"$CSI$ANSI_FG${COLOR}m\""
	eval "ANSI_BG_$color=\"$CSI$ANSI_BG${COLOR}m\""
	unset COLOR
done
