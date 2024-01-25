# Docker file for base Neovim image.

# Debian image as base
FROM debian:latest

ARG UID
ARG GID

# Set image locale.
ENV LANG=en_US.UTF-8
ENV TZ=Europe/Bucharest

# Lazygit variables
ARG LG="lazygit"
ARG LG_GITHUB="https://github.com/jesseduffield/lazygit/releases/download/v0.40.2/lazygit_0.40.2_Linux_x86_64.tar.gz"
ARG LG_ARCHIVE="lazygit.tar.gz"


RUN apt update && \
    apt install -y sudo && \
    [ $(getent group "$GID") ] || addgroup --gid $GID nonroot && \
    adduser --uid $UID --gid $GID --disabled-password --gecos "" nonroot && \
    echo 'nonroot ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

USER nonroot

# Update repositories and install system tools
RUN sudo apt-get update && sudo apt-get -y install git git-lfs wget curl ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config zip unzip doxygen tzdata python3 python3-pip procps fontconfig

# Configure locale
RUN sudo apt-get install -y locales && \
    sudo sed -i -e "s/# $LANG.*/$LANG UTF-8/" /etc/locale.gen && \
    sudo dpkg-reconfigure --frontend=noninteractive locales && \
    sudo update-locale LANG=$LANG
    
# Install dev tools
RUN sudo apt-get -y install fd-find fzf ripgrep tree xclip

# Create tmp directory
RUN mkdir -p ~/tmp

# Install latest node version
RUN cd ~/tmp && curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash - && sudo apt-get install -y nodejs

# Install Neovim from source.
RUN cd ~/tmp && git clone --depth 1 --branch stable https://github.com/neovim/neovim
RUN cd ~/tmp/neovim && sudo make CMAKE_BUILD_TYPE=Release && sudo make install

# Cooperate Neovim with Python 3.
RUN pip3 install pynvim --break-system-packages

# Cooperate NodeJS with Neovim.
RUN sudo npm i -g neovim

# Install nerd font
RUN wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/latest/download/0xProto.zip \
    && cd ~/.local/share/fonts && unzip 0xProto.zip && rm 0xProto.zip && sudo fc-cache -fv

# Install Lazygit from binary
RUN cd ~/tmp && curl -L -o $LG_ARCHIVE $LG_GITHUB
RUN cd ~/tmp && tar xzvf $LG_ARCHIVE && sudo mv $LG /usr/bin/

# Delete tmp directory
RUN sudo rm -rf ~/tmp

# Bash aliases
COPY ./home/ ~/

# Create directory for projects (there should be mounted from host).
RUN mkdir -p ~/workspace
RUN mkdir -p ~/.local/share/nvim
RUN mkdir -p ~/.local/state/nvim

# Avoid dubious ownership in git
RUN git config --global --add safe.directory ~/workspace

# Set default location after container startup.
WORKDIR ~/workspace

# Avoid container exit.
CMD ["tail", "-f", "/dev/null"]
