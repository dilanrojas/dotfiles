### Fish configuration file

# Greeting
set fish_greeting ""

# Aliases
alias neofetch fastfetch
alias ls "lsd -l"
alias cat bat
alias tkn "cat ~/Documents/Files/GitToken.txt"
alias n nvim

alias cputemp "sensors | grep Core"
alias rich "rich --pager --theme one-dark --padding 3,10,3,10"

alias update "sudo pacman -Syu && yay -Syu"
alias i "sudo pacman -S --noconfirm"
alias s "pacman -Ss"
alias r "sudo pacman -Rns"
alias yi "yay -S --noconfirm"
alias ys "yay -Ss"
alias yr "yay -Rns"

# git
alias g git

# Systemd
alias start "sudo systemctl start"
alias startu "systemctl --user start"
alias enable "sudo systemctl enable"
alias enableu "systemctl --user enable"
alias stop "sudo systemctl stop"
alias stopu "systemctl --user stop"
alias disable "sudo systemctl disable"
alias disableu "systemctl --user disable"
alias sstatus "systemctl status"
alias sstatusu "systemctl --user status"

alias mount "udisksctl mount -b"
alias umount "udisksctl unmount -b"

# Prompt
starship init fish | source

# pnpm
set -gx PNPM_HOME "/home/jwd/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

set -gx PATH $HOME/.local/bin $PATH
set -Ux QT_QPA_PLATFORMTHEME qt6ct
set -Ux _JAVA_AWT_WM_NONREPARENTING true
set -Ux _JAVA_OPTIONS "-Dawt.useSystemAAFontSettings=lcd -Dswing.aatext=true"
