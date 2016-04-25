---
title: Nested Tmux
description: A nested Tmux configuration
header: A nested Tmux configuration
subheader: A more efficient Tmux for engineers that live in SSH
date: 1/1/70
icon: columns
layout: ramblings/post.html
lunr: true
code: true
---
Tmux is a terminal multiplexer that has almost completely replaced the "screen" in the sysadmins toolkit, if you are not aware
of what a terminal multiplexer is or you have not come across screen before there's a great introduction at <a href="http://www.morannon.org/2015/03/tmux-terminal-multiplexer/" target="_blank">morannon.org</a>.

In it's stock configuration it is very powerful but if you're willing to sidestep a warning that comes with the stock install you will
quickly find that it will change the way you interact with the terminal. Follow the steps below and start thinking in portals...

```bash
> cat ~/.tmux/global.conf
set-option -g status on
set-option -g prefix C-b
bind-key b send-prefix

> cat ~/.tmux/outer.conf
source-file ~/.tmux/global.conf
set-option -g status-position top
set-option -g status-bg blue

> cat ~/.tmux/inner.conf
source-file ~/.tmux/global.conf
set-option -g status-position bottom
set-option -g status-bg red
```
<br/>

The steps above are all that's required to get started however if you edit your shell's configuration to combine it
with the modification above you will never need to spawn the sessions manually.

The steps are provided for zsh but they should be fairly simple to adapt to bash, see http://unix.stackexchange.com/questions/26676/how-to-check-if-a-shell-is-login-interactive-batch/26782#26782 for more information

```bash
> tail ~/.zlogin
if [[ -o login ]] && [[ -o interactive ]]
then
	if /usr/bin/tmux -S ~/.tmux/outer.sock has-session
	then
		/usr/bin/tmux -S ~/.tmux/outer.sock -2u attach-session -d
	else
		/usr/bin/tmux -S ~/.tmux/outer.sock -2u -f ~/.tmux/outer.conf
	fi
fi

> tail ~/.zshrc
if [[ ! -o login ]] && [[ -o interactive ]]
then
    if env | egrep "^TMUX=" | grep -q "outer\.sock"
	then
		unset TMUX; /usr/bin/tmux -S ~/.tmux/inner.sock -2u -f /root/.tmux/inner.conf
		exit 0
	fi
fi
```
<br/>

If you've followed the steps above and $DIETY has smiled upon you then you should have setup where SSHing into
a server puts you into a master tmux session automatically (spawning if required) and every time you open a new
tmux window in the master session it will spawn a new child tmux session and join you into it.
To send tmux key strokes to the nested session press your tmux prefix (ctrl+b) and then the prefix again (ctrl+b then b).

You can see a more complex setup with other modifications to the stock tmux configuration in my [dotfiles](//github.com/permosegaard/dotfiles)

Combine the above setup with my [consoler](//github.com/permosegaard/consoler) project and you can have a *very*
efficient remote workstation but I'll leave describing that for another time.

If you have any questions or have improvements on the above setup you can email me at permosegaard@googlemail.com or open issues/pull requests against the dotfiles repo at github which is linked above.
