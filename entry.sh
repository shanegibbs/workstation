#!/bin/bash -eu

# for some reason this doesn't go away
rm -rf /home/yay

NEW_UID="$(stat -c '%u' /workstation)"
NEW_GID="$(stat -c '%g' /workstation)"
NEW_USERNAME="$(cat /workstation/username)"

groupadd -g "$NEW_GID" "$NEW_USERNAME"
useradd -m -s /usr/sbin/zsh -G users,audio,input,kvm,optical,storage,video,systemd-journal \
	-u "$NEW_UID" -g "$NEW_GID"  \
	"$NEW_USERNAME"

echo "$NEW_USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/user

groupdel docker
groupadd -g "$(stat -c '%g' /var/run/docker.sock)" docker
usermod -aG docker "$NEW_USERNAME"

for d in $(ls /workstation/dots)
do
	P="/workstation/dots/$d"
	ln -s "$P" "/home/$NEW_USERNAME/.$d"
done

for d in dev local
do
	source_dir="/workstation/$d"
	if [ -e "$source_dir" ]
	then
		ln -s "$source_dir" "/home/$NEW_USERNAME/$d"
	fi
done

sudo -u "$NEW_USERNAME" bash -c "ssh-agent -a /home/$NEW_USERNAME/.ssh-agent.socket & exec tmux -S /workstation/tmux.socket new -t workstation -s workstation -d"

echo tmux running
sleep infinity
