# Docker file for base Neovim image.
#
# Debian image as base
FROM debian:latest

# Expose some ports to host by default.
EXPOSE 8080 8081 8082 8083 8084 8085

# Set image locale.
ENV LANG=en_US.UTF-8
ENV TZ=Europe/Bucharest

# Lazygit variables
ARG LG='lazygit'
ARG LG_GITHUB='https://github.com/jesseduffield/lazygit/releases/download/v0.40.2/lazygit_0.40.2_Linux_x86_64.tar.gz'
ARG LG_ARCHIVE='lazygit.tar.gz'

# Update repositories and install software for building Neovim from source.
RUN apt-get update && apt-get -y install git git-lfs wget curl ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config zip unzip doxygen tzdata python3 python3-pip procps

# Configure locale
RUN apt-get install -y locales && \
    sed -i -e "s/# $LANG.*/$LANG UTF-8/" /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=$LANG
    
# Install tools
RUN apt-get -y install fd-find fzf ripgrep tree xclip

# Create tmp directory
RUN mkdir -p /root/tmp

# Install latest node version
RUN cd /root/tmp && curl -fsSL https://deb.nodesource.com/setup_current.x | bash && apt-get install -y nodejs

# Install Neovim from source.
RUN cd /root/tmp && git clone --depth 1 --branch stable https://github.com/neovim/neovim
RUN cd /root/tmp/neovim && make CMAKE_BUILD_TYPE=Release && make install

# Cooperate Neovim with Python 3.
RUN pip3 install pynvim --break-system-packages

# Cooperate NodeJS with Neovim.
RUN npm i -g neovim

# Create directory for Neovim configuration files.
RUN mkdir -p /root/.config/nvim

# Install Lazygit from binary
RUN cd /root/tmp && curl -L -o $LG_ARCHIVE $LG_GITHUB
RUN cd /root/tmp && tar xzvf $LG_ARCHIVE && mv $LG /usr/bin/

# Delete tmp directory
RUN rm -rf /root/tmp

# Bash aliases
COPY ./home/ /root/

# Create directory for projects (there should be mounted from host).
RUN mkdir -p /root/workspace

# Avoid dubious ownership in git
RUN git config --global --add safe.directory /root/workspace

# Set default location after container startup.
WORKDIR /root/workspace

# Avoid container exit.
CMD ["tail", "-f", "/dev/null"]
