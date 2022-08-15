# my dotfiles

> "you are your dotfiles" -Tony Soprano

I have this repo cloned to `$HOME/.dotfiles` on all my machines and use [gnu
stow][stow] to manage them.

These are my base dotfiles. I also have some 'environment-specific'
dotfiles/configs based on the machine I'm using (e.g. for work). I handle this
by having a seperate, private repo cloned to `$HOME/.local` which is
hooked-in/referenced by files in this repo. For instance, at the bottom of
[.zshrc](./.zshrc).


[stow]: https://www.gnu.org/software/stow/

