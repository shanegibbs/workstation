FROM archlinux/base

ADD mirrorlist.pacman /etc/pacman.d/mirrorlist
RUN sed -i 's/#Color/Color/' /etc/pacman.conf
RUN pacman --noconfirm -Syu
RUN pacman --noconfirm --needed -S base base-devel sudo git

RUN pacman --noconfirm --needed -S glibc grub parted hwinfo \
  time htop zsh vim neovim tmux openssh the_silver_searcher binutils zsh \
  man bind-tools jq rsync inetutils iputils openbsd-netcat net-tools \
  cdrtools psmisc docker iptables tigervnc

RUN pacman --noconfirm --needed -S python3 python-virtualenv
RUN pacman --noconfirm --needed -S i3-gaps i3status i3blocks dmenu
RUN pacman --noconfirm --needed -S rxvt-unicode rxvt-unicode-terminfo code
RUN pacman --noconfirm --needed -S qpdfview xorg-xev

RUN pacman --noconfirm -S \
	ttf-font-awesome \
	ttf-ubuntu-font-family \
	ttf-dejavu \
	ttf-liberation \
	noto-fonts \
	noto-fonts-emoji \
	noto-fonts-extra

RUN pacman --noconfirm --needed -S firefox

#RUN sudo pacman --noconfirm --needed -S rust
#RUN sudo pacman --noconfirm --needed -S go
#RUN sudo pacman --noconfirm --needed -S docker docker-compose
#RUN sudo pacman --noconfirm --needed -S aws-cli
#RUN sudo pacman --noconfirm --needed -S kubectl
#RUN sudo pacman --noconfirm --needed -S terraform

RUN useradd -U -m yay
RUN echo "yay ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/yay
USER yay
WORKDIR /home/yay

# RUN git clone https://aur.archlinux.org/yay.git && cd yay && makepkg --noconfirm --needed -sir && cd .. && rm -rf yay .cache
# RUN yay --noconfirm --needed -S google-cloud-sdk && rm -rf .cache
# RUN yay --noconfirm --needed -S gotop-bin && rm -rf .cache
# RUN yay --noconfirm --needed -S aws-vault && rm -rf .cache
#RUN yay --noconfirm --needed -S dive && rm -rf .cache
USER root
RUN userdel -rf yay && rm /etc/sudoers.d/yay && rm -rf /home/yay

#RUN cd /usr/local/bin && curl -L "$(curl -s https://api.github.com/repos/helm/helm/releases/latest |jq -r .body |egrep -o "https:[^)]+linux-arm64.tar.gz" |head -n 1)" |tar -xz
# RUN cd /usr/local/bin && curl -L https://storage.googleapis.com/workspace-artifacts/tars/helm-v2.14.1-linux-amd64.tar.gz |tar -xz

#RUN yay --noconfirm -S google-chrome
#RUN yay --noconfirm -S i3-gaps
#RUN yay --noconfirm -S spotify

COPY ssh_config /etc/ssh/ssh_config

COPY dots /etc/skel/.shanegibbs-dots

RUN zsh -c 'git clone --recursive https://github.com/sorin-ionescu/prezto.git "/etc/skel/.zprezto" && \
	setopt EXTENDED_GLOB && \
	for rcfile in /etc/skel/.zprezto/runcoms/^README.md(.N); do \
	  ln -s "$rcfile" "/etc/skel/.${rcfile:t}" && \
	done && \
	ln -fs .shanegibbs-dots/zshrc /etc/skel/.zshrc && \
	ln -fs .shanegibbs-dots/zpreztorc /etc/skel/.zpreztorc'

RUN ln -s .shanegibbs-dots/tmux.conf /etc/skel/.tmux.conf
RUN ln -s .shanegibbs-dots/vimrc /etc/skel/.vimrc
RUN ln -s .shanegibbs-dots/vim /etc/skel/.vim
RUN ln -s .shanegibbs-dots/gitconfig /etc/skel/.gitconfig
RUN ln -s .shanegibbs-dots/gitignore /etc/skel/.gitignore

#RUN curl -L https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 >dumb-init && chmod +x dumb-init && mv dumb-init /usr/local/bin
#ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
WORKDIR /home

COPY workstation.target /etc/systemd/system
RUN systemctl set-default workstation.target
RUN systemctl enable dbus
RUN systemctl mask \
	swap.target \
	systemd-networkd \
	systemd-firstboot.service \
	systemd-timesyncd.service

STOPSIGNAL SIGRTMIN+3
ENV container=docker
COPY entry.sh /
CMD /entry.sh

ADD root /
