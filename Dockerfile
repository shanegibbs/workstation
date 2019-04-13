FROM archlinux/base

RUN pacman --noconfirm -Sy
RUN pacman --noconfirm --needed -S base-devel sudo git

RUN useradd -m -s /usr/sbin/zsh -U -G users,audio,input,kvm,optical,storage,video,systemd-journal shane
RUN echo "shane ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/shane
WORKDIR /home/shane
USER shane

RUN sudo pacman --noconfirm --needed -S go
RUN git clone https://aur.archlinux.org/yay.git && cd yay && makepkg --noconfirm --needed -sir && cd .. && rm -rf yay .cache

RUN sudo pacman --noconfirm --needed -S grub parted hwinfo time htop zsh vim tmux openssh the_silver_searcher binutils zsh python3 man termite-terminfo bind-tools
RUN sudo pacman --noconfirm --needed -S rust
#RUN pacman --noconfirm -S xorg-xev rxvt-unicode termite dmenu i3status code qpdfview
#RUN pacman --noconfirm -S ttf-font-awesome ttf-ubuntu-font-family ttf-dejavu ttf-liberation noto-fonts noto-fonts-emoji noto-fonts-extra

RUN sudo pacman --noconfirm --needed -S docker
RUN sudo usermod -aG docker shane

#RUN yay --noconfirm -S google-chrome
RUN yay --noconfirm --needed -S google-cloud-sdk && rm -rf .cache
RUN yay --noconfirm --needed -S gotop-bin && rm -rf .cache
RUN yay --noconfirm --needed -S dive && rm -rf .cache
#RUN yay --noconfirm -S i3-gaps
#RUN yay --noconfirm -S spotify

RUN curl https://raw.githubusercontent.com/shanegibbs/shanegibbs-dots/master/setup.sh |bash -ex
RUN sed -ie 's/^colorscheme/silent! colorscheme/g' .vimrc
RUN vim +PluginInstall +qall

RUN zsh -c 'git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto" && \
	setopt EXTENDED_GLOB && \
	for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do \
	  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}" && \
	done'

RUN rm .zpreztorc
COPY zpreztorc .zpreztorc

RUN curl -L https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 >dumb-init && chmod +x dumb-init && sudo mv dumb-init /usr/local/bin

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD ["bash", "-c", "/usr/sbin/tmux new -t workstation -s workstation -d && tail -f /dev/null"]
