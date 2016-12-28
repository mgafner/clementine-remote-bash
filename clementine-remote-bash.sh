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
          playlist
          playlists

  -g    get info
  -h    list all commands
  -p    set playlist

examples:

  $(basename $0) -c play
  $(basename $0) -g title
  $(basename $0) -g status
  $(basename $0) -g playlists
  $(basename $0) -p <some-playlist>

EOF
return 0
}

# ------------------------------------------------------------------------------
runcmd()
# ------------------------------------------------------------------------------
{
  case $1 in
    next)
        qdbus $DBUSBASE org.mpris.MediaPlayer2.Player.Next 
      ;;
    pause)
        qdbus $DBUSBASE org.mpris.MediaPlayer2.Player.Pause 
      ;;
    play)
	qdbus $DBUSBASE org.mpris.MediaPlayer2.Player.Play
      ;;
    playpause)
	qdbus $DBUSBASE org.mpris.MediaPlayer2.Player.PlayPause
      ;;
    prev)
	qdbus $DBUSBASE org.mpris.MediaPlayer2.Player.Previous
      ;;
    shuffle)
        shuffle
      ;;
    *)
        echo "command $1 not known or not implemented"
        exit 1
      ;;
  esac
  return
}

# ------------------------------------------------------------------------------
setplaylist()
# ------------------------------------------------------------------------------
# $1 = Playlist name
{
  playlistobject=`$0 -g playlists | grep "$1" | awk '{print $1}'`
  if [ ! -z "$playlistobject" ]; then
    shuffle
    qdbus $DBUSBASE org.mpris.MediaPlayer2.Playlists.ActivatePlaylist $playlistobject
  fi
}

# ------------------------------------------------------------------------------
setvolume()
# ------------------------------------------------------------------------------
{
  qdbus $DBUSBASE org.freedesktop.DBus.Properties.Set org.mpris.MediaPlayer2.Player Volume $1
}

# ------------------------------------------------------------------------------
shuffle()
# ------------------------------------------------------------------------------
{
  qdbus $DBUSBASE org.freedesktop.DBus.Properties.Set org.mpris.MediaPlayer2.Player Shuffle false
  sleep 1
  qdbus $DBUSBASE org.freedesktop.DBus.Properties.Set org.mpris.MediaPlayer2.Player Shuffle true
}

# ------------------------------------------------------------------------------
getinfo()
# ------------------------------------------------------------------------------
{
  case $1 in
    albumart)
        qdbus $DBUSBASE org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Player Metadata | awk '/artUrl:/{$1=""; print substr($0,2)}'
      ;;
    artist)
        qdbus $DBUSBASE org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Player Metadata | awk '/artist:/{$1=""; print substr($0,2)}'
      ;;
    comment)
        qdbus $DBUSBASE org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Player Metadata | awk '/comment:/{$1=""; print substr($0,2)}'
      ;;
    lastplayed)
        qdbus $DBUSBASE org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Player Metadata | awk '/contentCreated:/{$1=""; print substr($0,2)}' | sed 's/T/ /g'
      ;;
    metadata)
        qdbus $DBUSBASE org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Player Metadata
      ;;
    playcount)
        qdbus $DBUSBASE org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Player Metadata | awk '/useCount:/{$1=""; print substr($0,2)}'
      ;;
    playlist)
        qdbus --literal org.mpris.MediaPlayer2.clementine /org/mpris/MediaPlayer2  \
          org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Playlists ActivePlaylist \
          | awk '{ print $8 "\t" $9 }' \
          | sed 's/]//g;s/"//g;s/,//g'
      ;;        
    playlists)
        dbus-send --type=method_call --print-reply \
          --dest=org.mpris.MediaPlayer2.clementine \
          /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Playlists.GetPlaylists \
          uint32:1 uint32:50 string:Alphabetical boolean:false  \
          | grep -Ev 'method|array|struct|}|string ""|]' \
          | sed 'N;s/\n/ /' \
          | sed 's/"//g' \
          | awk '{ print $3 "\t" $5 }'
      ;;
    position)
        qdbus $DBUSBASE org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Player Position
      ;;
    rating)
        qdbus $DBUSBASE org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Player Metadata | awk '/autoRating:/{$1=""; print substr($0,2)}'
      ;;
    shuffle)
        qdbus $DBUSBASE org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Player Shuffle
      ;;
    status)
        qdbus $DBUSBASE org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Player PlaybackStatus
      ;;
    title)
        qdbus $DBUSBASE org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Player Metadata | awk '/title:/{$1=""; print substr($0,2)}'
      ;;
    volume)
        qdbus $DBUSBASE org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Player Volume
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
while getopts ":c:g:hp:s:v:" OPTION
do
  case $OPTION in
    c)
      runcmd "$OPTARG"
      ;; 
    g)
      getinfo "$OPTARG"
      ;;
    h)
      usage
      exit 1
      ;;
    p)
      setplaylist "$OPTARG"
      ;;
    v)
      setvolume "$OPTARG"
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

