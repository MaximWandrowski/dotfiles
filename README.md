# Dotfiles Bare Git Repository

These dotfiles are managed like originally described in an [Hacker News][HN]
thread and then further described by [Atlassian][AT] and [DistroTube][DT]. SCM
is handled by the hidden bare repository `$HOME/.dotfiles` and a git alias that
treats `$HOME` as its work tree.

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
git clone --bare https://github.com/MaximWandrowski/dotfiles $HOME/.dotfiles
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfiles config --local status.showUntrackedFiles no
dotfiles checkout
```

[HN]: https://news.ycombinator.com/item?id=11071754
[AT]: https://www.atlassian.com/git/tutorials/dotfiles
[DT]: https://www.youtube.com/watch?v=tBoLDpTWVOM
