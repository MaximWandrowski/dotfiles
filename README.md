# Dotfiles Bare Git Repository

These dotfiles are managed like [StreakyCobra][StreakyCobra] layed it out in a
post on Hacker News. SCM is handled by the hidden bare repository
`$HOME/.dotfiles` and a git alias that treats `$HOME` as its work tree.

## Starting from scratch

```bash
# setup dotfiles tracking
git init --bare $HOME/.dotfiles
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfiles config status.showUntrackedFiles no

# completion for git
[ -r /usr/share/git/completion/git-completion.bash ] && {
  source /usr/share/git/completion/git-completion.bash
}

# completion also for dotfiles alias
eval `complete -p git | sed 's/\w*$//'` dotfiles
```

## Deploying somewhere else

```bash
git clone --separate-git-dir=~/.dotfiles /path/to/repo $HOME
```

[StreakyCobra]: https://news.ycombinator.com/item?id=11071754
[Atlassian]: https://www.atlassian.com/git/tutorials/dotfiles
[DistroTube]: https://www.youtube.com/watch?v=tBoLDpTWVOM
