/usr/bin/git --git-dir=/home/jonasz/.dotfiles --work-tree=/home/jonasz pull
/usr/bin/git --git-dir=/home/jonasz/.dotfiles --work-tree=/home/jonasz add -u
/usr/bin/git --git-dir=/home/jonasz/.dotfiles --work-tree=/home/jonasz commit -m "update"
/usr/bin/git --git-dir=/home/jonasz/.dotfiles --work-tree=/home/jonasz push

/usr/bin/git --git-dir=/home/jonasz/Other --work-tree=/home/jonasz pull
/usr/bin/git --git-dir=/home/jonasz/Other --work-tree=/home/jonasz add -A
/usr/bin/git --git-dir=/home/jonasz/Other --work-tree=/home/jonasz commit -m "update"
/usr/bin/git --git-dir=/home/jonasz/Other --work-tree=/home/jonasz push

/usr/bin/pass git pull
/usr/bin/pass git push
