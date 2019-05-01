FROM archlinux/base

RUN sed -i 's/#Color/Color/' /etc/pacman.conf
RUN pacman --noconfirm -Sy
RUN pacman --noconfirm --needed -S base-devel sudo git

RUN sudo pacman --noconfirm --needed -S glibc grub parted hwinfo time htop zsh vim \
	tmux openssh the_silver_searcher binutils zsh python3 python-virtualenv man \
	termite-terminfo bind-tools jq rsync packer inetutils iputils openbsd-netcat \
	net-tools cdrtools
RUN sudo pacman --noconfirm --needed -S rust
RUN sudo pacman --noconfirm --needed -S go
RUN sudo pacman --noconfirm --needed -S docker
RUN sudo pacman --noconfirm --needed -S aws-cli
RUN sudo pacman --noconfirm --needed -S kubectl
RUN sudo pacman --noconfirm --needed -S terraform

RUN useradd -U -m yay
RUN echo "yay ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/yay
USER yay
WORKDIR /home/yay

RUN git clone https://aur.archlinux.org/yay.git && cd yay && makepkg --noconfirm --needed -sir && cd .. && rm -rf yay .cache
RUN yay --noconfirm --needed -S google-cloud-sdk && rm -rf .cache
RUN yay --noconfirm --needed -S gotop-bin && rm -rf .cache
RUN yay --noconfirm --needed -S kubernetes-helm && rm -rf .cache
RUN yay --noconfirm --needed -S dive && rm -rf .cache
USER root
RUN userdel -rf yay && rm /etc/sudoers.d/yay && rm -rf /home/yay

#RUN pacman --noconfirm -S xorg-xev rxvt-unicode termite dmenu i3status code qpdfview
#RUN pacman --noconfirm -S ttf-font-awesome ttf-ubuntu-font-family ttf-dejavu ttf-liberation noto-fonts noto-fonts-emoji noto-fonts-extra
#RUN yay --noconfirm -S google-chrome
#RUN yay --noconfirm -S i3-gaps
#RUN yay --noconfirm -S spotify

COPY ssh_config /etc/ssh/ssh_config

#RUN useradd -m -s /usr/sbin/zsh -U -G users,audio,input,kvm,optical,storage,video,systemd-journal sgibbs
#RUN echo "sgibbs ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/user
#WORKDIR /home/sgibbs
#USER sgibbs

COPY dots /etc/skel/.shanegibbs-dots
#RUN sudo chown sgibbs:sgibbs -R .shanegibbs-dots && ./.shanegibbs-dots/setup.sh

RUN zsh -c 'git clone --recursive https://github.com/sorin-ionescu/prezto.git "/etc/skel/.zprezto" && \
	setopt EXTENDED_GLOB && \
	for rcfile in /etc/skel/.zprezto/runcoms/^README.md(.N); do \
	  ln -s "$rcfile" "/etc/skel/.${rcfile:t}" && \
	done && \
	ln -fs .shanegibbs-dots/zshrc /etc/skel/.zshrc && \
	ln -fs .shanegibbs-dots/zpreztorc /etc/skel/.zpreztorc'

RUN ln -s .shanegibbs-dots/tmux.conf /etc/skel/.tmux.conf

#USER root
RUN curl -L https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 >dumb-init && chmod +x dumb-init && mv dumb-init /usr/local/bin
ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
COPY entry.sh /
CMD /entry.sh
