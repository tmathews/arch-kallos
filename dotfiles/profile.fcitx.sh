export EDITOR=nvim
export HISTSIZE=
export HISTCONTROL=ignoreboth:erasedups
# Wayland desktop + fcitx5 input method.
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
# Input method (fcitx5). Under Wayland these mainly cover XWayland/legacy apps;
# native Wayland apps use the text-input protocol directly. (Was =wayland when
# this machine used the Wayland-native anthywl IME.)
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export SDL_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
