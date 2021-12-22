Sync-Dotfiles() {
    # Bash
    cp ~/.bash_aliases $DEV_ROOT/dotfiles/wsl
    cp ~/.bash_functions $DEV_ROOT/dotfiles/wsl
    cp ~/.bashrc $DEV_ROOT/dotfiles/wsl
    cp ~/.profile $DEV_ROOT/dotfiles/wsl

    # Vim
    cp ~/.vimrc $DEV_ROOT/dotfiles

    # Git
    cp ~/.gitconfig $DEV_ROOT/dotfiles/.gitconfig-template
}
