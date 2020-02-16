#!/bin/sh
# setups the auto-update
(
	crontab -l | grep -v "dot-update"
	echo "0 */2 * * * $HOME/.dotfiles/bin/dot-update > $HOME/.dotfiles/dot-update.log 2>&1"
) | crontab -
