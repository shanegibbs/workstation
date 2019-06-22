#!/bin/bash -eux

# for some reason this doesn't go away
rm -rf /home/yay

if [ -e /var/run/docker.sock ]
then
  groupdel docker
  groupadd -g "$(stat -c '%g' /var/run/docker.sock)" docker
else
  mkdir /etc/systemd/system/workstation.target.wants
  ln -s /usr/lib/systemd/system/docker.service /etc/systemd/system/workstation.target.wants
fi

NEW_UID="${NEW_UID:-1500}"
NEW_GID="${NEW_GID:-1500}"
NEW_USERNAME="${NEW_USERNAME:-shane}"
NEW_GROUP="${NEW_GROUP:-shane}"

if [ -e /workstation ]
then
  NEW_UID="$(stat -c '%u' /workstation)"
  NEW_GID="$(stat -c '%g' /workstation)"
  NEW_USERNAME="$(cat /workstation/username)"
  NEW_GROUP="domain-users"
fi

groupadd -g "$NEW_GID" "$NEW_GROUP"
useradd -m -s /usr/sbin/zsh -G users,audio,input,kvm,optical,storage,video,systemd-journal,docker \
	-u "$NEW_UID" -g "$NEW_GID"  \
	"$NEW_USERNAME"

echo "$NEW_USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/user

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

# sudo -u "$NEW_USERNAME" bash -c "ssh-agent -a /home/$NEW_USERNAME/.ssh-agent.socket & exec tmux -S /workstation/tmux.socket new -t workstation -s workstation -d"
#echo tmux running

#sleep infinity
exec /usr/lib/systemd/systemd --system --show-status=on
