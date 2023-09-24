ARG uid=1000
ARG gid=1000
ARG user=ruby
ARG group=ruby
ARG home=/home/ruby

FROM debian:bullseye

USER root
ARG gid
ARG uid
ARG user
ARG group
ARG home

#
# Create working user.
#
ENV HOME=$home
USER root
RUN groupadd -g $gid $group && \
    useradd -u $uid -g $gid -s /bin/bash -m $user -d $home

USER root
RUN apt update && \
    apt install -y curl git locales vim wget && \
    apt clean && rm -rf /var/lib/apt/lists/*

#
# Set default locale.
#
USER root
RUN apt update && \
    apt install -y locales && \
    apt clean && rm -rf /var/lib/apt/lists/*
RUN locale-gen en_US.utf8 && \
    localedef -f UTF-8 -i en_US en_US.utf8

USER $user

#
# Install ruby2.7 and mruby2.1.
#
# * refs: https://github.com/rbenv/rbenv#basic-github-checkout
# * refs: https://github.com/rbenv/ruby-build#readme
#
USER root
RUN apt update && \
    apt install -y curl git locales vim wget && \
    apt install -y autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev && \
    apt clean && rm -rf /var/lib/apt/lists/*

USER $user
ENV RBENV_ROOT=$HOME/.rbenv
RUN git clone --depth 1 https://github.com/rbenv/rbenv.git "$RBENV_ROOT" && \
    echo 'export RBENV_ROOT="$HOME/.rbenv"' >> ~/.bashrc && \
    echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(rbenv init - bash)"' >> ~/.bashrc
ENV PATH=$RBENV_ROOT/bin:$PATH
ENV PATH=$RBENV_ROOT/shims:$PATH

RUN mkdir -p "$(rbenv root)"/plugins && \
    git clone --depth 1 https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

RUN rbenv install 2.7.0 && \
    rbenv global 2.7.0

RUN rbenv install mruby-2.1.0

#
# Install mkspiffs.
#
# refs: https://github.com/gfd-dennou-club/mrubyc-esp32/wiki/Users_%E7%92%B0%E5%A2%83%E6%A7%8B%E7%AF%89
#
USER root
RUN git clone --recursive --depth 1 https://github.com/igrr/mkspiffs /usr/local/src/mkspiffs && \
    cd /usr/local/src/mkspiffs && \
    ./build_all_configs.sh --esp-idf && \
    cp ./mkspiffs /usr/local/bin/
RUN usermod -a -G sudo $user && \
    usermod -a -G dialout $user

USER $user

#
# Install ESP-IDF release/v4.2.
#
# refs: https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/linux-macos-setup.html
#
USER root
RUN apt update && \
    apt install -y git wget flex bison gperf python3 python3-venv cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0 && \
    apt install -y python3-pip && \
    apt clean && rm -rf /var/lib/apt/lists/*

USER $user

# Install virtualenv with `break-system-packages`
#
# refs: https://github.com/matsudai/mrubyc-builder/issues/1
RUN /usr/bin/python3 -m pip install --user virtualenv --break-system-packages

RUN mkdir -p ~/esp && \
    cd ~/esp && \
    git clone --recursive --shallow-submodules --branch release/v4.2 --depth 1 https://github.com/espressif/esp-idf.git && \
    cd ~/esp/esp-idf && \
    ./install.sh all

RUN echo 'alias get_idf='"'"'. $HOME/esp/esp-idf/export.sh'"'" >> ~/.bashrc && \
    echo 'get_idf' >> ~/.bashrc

#
# WSL settings.
#
# * Default user.
# * Start directory.
#
# refs: https://docs.microsoft.com/ja-jp/windows/wsl/wsl-config
#
USER root
RUN echo "[user]\ndefault=$user\n" > /etc/wsl.conf

USER $user

WORKDIR $HOME
RUN echo 'cd $HOME' >> ~/.bashrc
