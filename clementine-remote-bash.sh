# This file is part of clementine-remote-bash
# https://github.com/mgafner/clementine-remote-bash
#                                                                                
# clementine-remote-bash is free software: you can redistribute it and/or modify                 
# it under the terms of the GNU General Public License as published by            
# the Free Software Foundation, either version 3 of the License, or               
# (at your option) any later version.                                             
#                                                                                
# clementine-remote-bash is distributed in the hope that it will be useful,                      
# but WITHOUT ANY WARRANTY; without even the implied warranty of                  
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                   
# GNU General Public License for more details.                                    
#                                                                                
# You should have received a copy of the GNU General Public License               
# along with this code. If not, see <http://www.gnu.org/licenses/>.

SIGINT=2
DBUSBASE="org.mpris.MediaPlayer2.clementine /org/mpris/MediaPlayer2"

# Functions --------------------------------------------------------------------

# ------------------------------------------------------------------------------
control_c()
# ------------------------------------------------------------------------------
#
# Description:  run if user hits control-c
#
# Parameter  :  none
#
# Output     :  logging
#
{
if [ $DEBUG -ge 3 ]; then set -x
fi

echo ""
}

# ------------------------------------------------------------------------------
usage()
# ------------------------------------------------------------------------------
#
# Description:  shows help text
# 
# Parameter  :  none
#
# Output     :  shows help text
#
{
cat << EOF

usage: $(basename $0) -g <info-to-get> 

OPTIONS:
  -c    command
	
	commands can be:
	  play
	  pause

  -g    get info
  -h    list all commands

examples:

  $(basename $0) -c play
  $(basename $0) -g title
  $(basename $0) -g status

EOF
return 0
}

# ------------------------------------------------------------------------------
run-cmd()
# ------------------------------------------------------------------------------
{
  case $1 in
    play)
	qdbus $DBUSBASE org.mpris.MediaPlayer2.Player.Play
      ;;
    pause)
        qdbus $DBUSBASE org.mpris.MediaPlayer2.Player.Pause 
      ;;
    *)
        echo "command $1 not known or not implemented"
        exit 1
      ;;
  esac
  return
}

# ------------------------------------------------------------------------------
get-info()
# ------------------------------------------------------------------------------
{
  case $1 in
    artist)
        qdbus $DBUSBASE org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Player Metadata | grep artist | awk '{$1=""; print substr($0,2)}'
      ;;
    metadata)
        qdbus $DBUSBASE org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Player Metadata
      ;;
    status)
        qdbus $DBUSBASE org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Player PlaybackStatus
      ;;
    title)
        qdbus $DBUSBASE org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Player Metadata | grep title | awk '{$1=""; print substr($0,2)}'
      ;;
    *)
        echo "command $1 not known or not implemented"
        exit 1
      ;;
  esac
  return
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

# trap keyboard interrupt (control-c)
trap control_c $SIGINT


# When you need an argument that needs a value, you put the ":" right after 
# the argument in the optstring. If your var is just a flag, withou any 
# additional argument, just leave the var, without the ":" following it.
#
# please keep letters in alphabetic order
#
while getopts ":c:g:hs:" OPTION
do
  case $OPTION in
    c)
      GETOPTS_COMMAND="$OPTARG"
      run-cmd "$GETOPTS_COMMAND"
      ;; 
    g)
      GETOPTS_COMMAND="$OPTARG"
      get-info "$GETOPTS_COMMAND"
      ;;
    h)
      usage
      exit 1
      ;;
    \?)
      usage
      exit 1
      ;;
    :)
      echo -e "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

