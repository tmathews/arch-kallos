# Start niri on TTY1 login (no display manager). .profile is sourced first by
# .bash_profile, so the Wayland + fcitx5 env above is inherited by niri here.
if [[ -z $DISPLAY && $(tty) == /dev/tty1 ]]; then
	ts=$(date +%Y%m%d%H%M%S)
	exec niri --session > "/tmp/niri-$ts.log" 2>&1
fi