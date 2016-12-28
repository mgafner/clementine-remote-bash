# clementine-remote-bash
Bash script for remote control of clementine music player

## About Clementine
Clementine is a modern music player and library organizer for Windows, Linux and Mac OS X.

   * Website: http://www.clementine-player.org/
   * Github: https://github.com/clementine-player/Clementine
   * Buildbot: http://buildbot.clementine-player.org/grid
   * Latest developer builds: http://builds.clementine-player.org/

## About Clementine Remote Bash
clementine-remote enables you to remote control Clementine from a bash terminal on the same computer clementine is running on. This is useful for automation tasks. 

(first idea for the script was to remote control clementine over the network. But this needs more investigation in the protocol buffer on command line. So for this time now we control with dbus-commands.)

## Installation
#### Prerequisites
   * qdbus

#### Prerequisites (for network remote control, not yet implemented)
   * protoc protobuf-compiler
   * curl

#### Debian / Ubuntu
```
sudo apt-get install qdbus
```

## Usage
```
usage: clementine-remote-bash.sh -g <info-to-get> 

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

  clementine-remote-bash.sh -c play
  clementine-remote-bash.sh -g title
  clementine-remote-bash.sh -g status
  clementine-remote-bash.sh -g playlists
  clementine-remote-bash.sh -p <some-playlist>
```

## Useful links and background info
### about dbus
   * [Controlling Clementine from command line with DBus and MPRIS](https://github.com/clementine-player/Clementine/wiki/Controlling-Clementine-from-the-commandline-with-DBus-and-MPRIS)
   * [How to activate a playlist](https://gist.github.com/biboudis/7550240)
   
### about protocol buffers
   * [Android Remote, another remote control for Clementine](https://github.com/clementine-player/Android-Remote)
   * [Developer Documentation for Android Remote](https://github.com/clementine-player/Android-Remote/wiki/Developer-Documentation)
   * [Clementine Remote Control Messages](https://github.com/clementine-player/Android-Remote/blob/master/app/src/main/java/de/qspool/clementineremote/backend/pb/remotecontrolmessages.proto)
   * [Protocol Buffers - Google Developer Site](https://developers.google.com/protocol-buffers/)
   * [Protocol Buffers - Google's data interchange format on Github](https://github.com/google/protobuf)
   * [Debian Package: protobuf-compiler](https://packages.debian.org/en/testing/protobuf-compiler)


## Playground, Testing
Testing code for an initial connection to Clementine (does not work yet):
```
mgafner@puzzle:~$ printf "auth_code: 12345\nsend_playlist_songs: 0\ndownloader: 0" \
| protoc --encode=pb.remote.RequestConnect remotecontrolmessages.proto \
| curl -H 'content-type:application/x-google-protobuf' --data-binary @- http://192.168.1.7:5500 \
| protoc --decode=pb.remote.Message remotecontrolmessages.proto

  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100     7    0     0  100     7      0    129 --:--:-- --:--:-- --:--:--   132
curl: (52) Empty reply from server
```

## License
clementine-remote-bash is free software, available under the [GNU General Public License, Version 3](http://www.gnu.org/licenses/gpl.html).

