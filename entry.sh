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

#cp "/home/$NEW_USERNAME/.shanegibbs-dots/tmux.conf" /workstation/

for d in ssh aws config kube gnupg
do
	P="/workstation/$d"
	mkdir -p "$P"
	chown "$NEW_UID:$NEW_GID" "$P"
done

sudo -u "$NEW_USERNAME" tmux -S /workstation/tmux.socket new -t workstation -s workstation -d

echo tmux running
sleep infinity
