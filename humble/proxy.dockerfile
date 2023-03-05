# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# Ubuntu release versions 22.04, 20.04, and 18.04 are supported
ARG UBUNTU_RELEASE=22.04
ARG CUDA_VERSION=11.7.1
FROM docker.io/nvidia/cuda:${CUDA_VERSION}-runtime-ubuntu${UBUNTU_RELEASE}

LABEL maintainer "https://github.com/ehfd,https://github.com/danisla"

ARG UBUNTU_RELEASE
ARG CUDA_VERSION
# Make all NVIDIA GPUs visible by default
ARG NVIDIA_VISIBLE_DEVICES=all
# Use noninteractive mode to skip confirmation when installing packages
ARG DEBIAN_FRONTEND=noninteractive
# All NVIDIA driver capabilities should preferably be used, check `NVIDIA_DRIVER_CAPABILITIES` inside the container if things do not work
ENV NVIDIA_DRIVER_CAPABILITIES all
# Enable AppImage execution in a container
ENV APPIMAGE_EXTRACT_AND_RUN 1
# System defaults that should not be changed
ENV DISPLAY :0
ENV XDG_RUNTIME_DIR /tmp/runtime-user
ENV PULSE_SERVER unix:/run/pulse/native
ENV LD_LIBRARY_PATH /usr/lib/x86_64-linux-gnu:/usr/lib/i386-linux-gnu${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

# Default environment variables (password is "mypasswd")
ENV TZ UTC
ENV SIZEW 1920
ENV SIZEH 1080
ENV REFRESH 60
ENV DPI 96
ENV CDEPTH 24
ENV VGL_DISPLAY egl
ENV PASSWD mypasswd
ENV NOVNC_ENABLE false
ENV WEBRTC_ENCODER nvh264enc
ENV WEBRTC_ENABLE_RESIZE false
ENV ENABLE_AUDIO true
ENV ENABLE_BASIC_AUTH true

# Set versions for components that should be manually checked before upgrading, other component versions are automatically determined by fetching the version online
ARG VIRTUALGL_VERSION=3.0.2
ARG NOVNC_VERSION=1.3.0

ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN : "apt Proxy" \
 && { \
  echo 'Acquire::http::proxy "'${HTTP_PROXY}'";'; \
  echo 'Acquire::https::proxy "'${HTTPS_PROXY}'";'; \
    } | tee /etc/apt/apt.conf
RUN : "apt Proxy" \
 && { \
  echo 'Acquire::http::proxy "'${HTTP_PROXY}'";'; \
  echo 'Acquire::https::proxy "'${HTTPS_PROXY}'";'; \
    } | tee /etc/apt/apt.conf.d/proxy.conf

RUN echo "http_proxy=${HTTP_PROXY}" >> /etc/environment && \
    echo "https_proxy=${HTTPS_PROXY}" >> /etc/environment

# Install locales to prevent X11 errors
RUN apt-get clean && \
    apt-get update && apt-get install --no-install-recommends -y locales && \
    rm -rf /var/lib/apt/lists/* && \
    locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8


SHELL ["/bin/bash", "-c"]

# ENV NVIDIA_VISIBLE_DEVICES ${NVIDIA_VISIBLE_DEVICES:-all}
# ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

ARG UID=9001
ARG GID=9001
ARG UNAME=nvidia
ARG HOSTNAME=docker
ARG HTTP_PROXY
ARG HTTPS_PROXY

ARG NEW_HOSTNAME=${HOSTNAME}-Docker

ARG USERNAME=$UNAME
ARG HOME=/home/$USERNAME
RUN apt-get update && apt-get install --no-install-recommends -y \
        sudo && \
    rm -rf /var/lib/apt/lists/* 

RUN useradd -u $UID -m $USERNAME && \
        echo "$USERNAME:$USERNAME" | chpasswd && \
        usermod --shell /bin/bash $USERNAME && \
        usermod -aG sudo $USERNAME && \
        mkdir /etc/sudoers.d -p && \
        usermod -a -G adm,audio,cdrom,dialout,dip,fax,floppy,lp,plugdev,sudo,tape,tty,video,voice $USERNAME && \
        echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \
        chmod 0440 /etc/sudoers.d/$USERNAME && \
        usermod  --uid $UID $USERNAME && \
        groupmod --gid $GID $USERNAME && \
        chown -R $USERNAME:$USERNAME $HOME

RUN sed -i.bak -e "s%http://[^ ]\+%http://ftp.jaist.ac.jp/pub/Linux/ubuntu/%g" /etc/apt/sources.list

RUN ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" > /etc/timezone


# Install Xvfb and other important libraries or packages
RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install --no-install-recommends -y \
        software-properties-common \
        alsa-base \
        alsa-utils \
        apt-transport-https \
        apt-utils \
        build-essential \
        ca-certificates \
        cups-filters \
        cups-common \
        cups-pdf \
        curl \
        file \
        wget \
        bzip2 \
        gzip \
        p7zip-full \
        xz-utils \
        zip \
        unzip \
        zstd \
        gcc \
        git \
        jq \
        make \
        python3 \
        python3-cups \
        python3-numpy \
        mlocate \
        nano \
        vim \
        htop \
        fonts-dejavu-core \
        fonts-freefont-ttf \
        fonts-noto \
        fonts-noto-cjk \
        fonts-noto-cjk-extra \
        fonts-noto-color-emoji \
        fonts-noto-hinted \
        fonts-noto-mono \
        fonts-opensymbol \
        fonts-symbola \
        fonts-ubuntu \
        libpulse0 \
        pulseaudio \
        supervisor \
        net-tools \
        libglvnd-dev \
        libglvnd-dev:i386 \
        libgl1-mesa-dev \
        libgl1-mesa-dev:i386 \
        libegl1-mesa-dev \
        libegl1-mesa-dev:i386 \
        libgles2-mesa-dev \
        libgles2-mesa-dev:i386 \
        libglvnd0 \
        libglvnd0:i386 \
        libgl1 \
        libgl1:i386 \
        libglx0 \
        libglx0:i386 \
        libegl1 \
        libegl1:i386 \
        libgles2 \
        libgles2:i386 \
        libglu1 \
        libglu1:i386 \
        libsm6 \
        libsm6:i386 \
        vainfo \
        vdpauinfo \
        pkg-config \
        mesa-utils \
        mesa-utils-extra \
        va-driver-all \
        xserver-xorg-input-all \
        xserver-xorg-video-all \
        mesa-vulkan-drivers \
        libvulkan-dev \
        libvulkan-dev:i386 \
        libxau6 \
        libxau6:i386 \
        libxdmcp6 \
        libxdmcp6:i386 \
        libxcb1 \
        libxcb1:i386 \
        libxext6 \
        libxext6:i386 \
        libx11-6 \
        libx11-6:i386 \
        libxv1 \
        libxv1:i386 \
        libxtst6 \
        libxtst6:i386 \
        xdg-utils \
        dbus-x11 \
        libdbus-c++-1-0v5 \
        xkb-data \
        x11-xkb-utils \
        x11-xserver-utils \
        x11-utils \
        x11-apps \
        xauth \
        xbitmaps \
        xinit \
        xfonts-base \
        libxrandr-dev \
        # Install Xvfb, packages above this line should be the same between docker-nvidia-glx-desktop and docker-nvidia-egl-desktop
        xvfb && \
    # Install Vulkan utilities
    if [ "${UBUNTU_RELEASE}" \< "20.04" ]; then apt-get install --no-install-recommends -y vulkan-utils; else apt-get install --no-install-recommends -y vulkan-tools; fi && \
    rm -rf /var/lib/apt/lists/* && \
    # Configure EGL manually
    mkdir -p /usr/share/glvnd/egl_vendor.d/ && \
    echo "{\n\
    \"file_format_version\" : \"1.0.0\",\n\
    \"ICD\": {\n\
        \"library_path\": \"libEGL_nvidia.so.0\"\n\
    }\n\
}" > /usr/share/glvnd/egl_vendor.d/10_nvidia.json

# Configure Vulkan manually
RUN VULKAN_API_VERSION=$(dpkg -s libvulkan1 | grep -oP 'Version: [0-9|\.]+' | grep -oP '[0-9]+(\.[0-9]+)(\.[0-9]+)') && \
    mkdir -p /etc/vulkan/icd.d/ && \
    echo "{\n\
    \"file_format_version\" : \"1.0.0\",\n\
    \"ICD\": {\n\
        \"library_path\": \"libGLX_nvidia.so.0\",\n\
        \"api_version\" : \"${VULKAN_API_VERSION}\"\n\
    }\n\
}" > /etc/vulkan/icd.d/nvidia_icd.json

# Install VirtualGL and make libraries available for preload
ARG VIRTUALGL_URL="https://sourceforge.net/projects/virtualgl/files"
RUN curl -fsSL -O "${VIRTUALGL_URL}/virtualgl_${VIRTUALGL_VERSION}_amd64.deb" && \
    curl -fsSL -O "${VIRTUALGL_URL}/virtualgl32_${VIRTUALGL_VERSION}_amd64.deb" && \
    apt-get update && apt-get install -y --no-install-recommends ./virtualgl_${VIRTUALGL_VERSION}_amd64.deb ./virtualgl32_${VIRTUALGL_VERSION}_amd64.deb && \
    rm -f "virtualgl_${VIRTUALGL_VERSION}_amd64.deb" "virtualgl32_${VIRTUALGL_VERSION}_amd64.deb" && \
    rm -rf /var/lib/apt/lists/* && \
    chmod u+s /usr/lib/libvglfaker.so && \
    chmod u+s /usr/lib/libdlfaker.so && \
    chmod u+s /usr/lib32/libvglfaker.so && \
    chmod u+s /usr/lib32/libdlfaker.so && \
    chmod u+s /usr/lib/i386-linux-gnu/libvglfaker.so && \
    chmod u+s /usr/lib/i386-linux-gnu/libdlfaker.so

# Anything below this line should be always kept the same between docker-nvidia-glx-desktop and docker-nvidia-egl-desktop

# Install KDE and other GUI packages
ENV XDG_CURRENT_DESKTOP KDE
ENV KWIN_COMPOSE N
# Use sudoedit to change protected files instead of using sudo on kate
ENV SUDO_EDITOR kate
RUN apt-get update && apt-get install --no-install-recommends -y \
        kde-plasma-desktop \
        kwin-addons \
        kwin-x11 \
        kdeadmin \
        akregator \
        ark \
        baloo-kf5 \
        breeze-cursor-theme \
        breeze-icon-theme \
        debconf-kde-helper \
        colord-kde \
        desktop-file-utils \
        filelight \
        gwenview \
        hspell \
        kaddressbook \
        kaffeine \
        kate \
        kcalc \
        kcharselect \
        kdeconnect \
        kde-spectacle \
        kde-config-screenlocker \
        kde-config-updates \
        kdf \
        kget \
        kgpg \
        khelpcenter \
        khotkeys \
        kimageformat-plugins \
        kinfocenter \
        kio-extras \
        kleopatra \
        kmail \
        kmenuedit \
        kmix \
        knotes \
        kontact \
        kopete \
        korganizer \
        krdc \
        ktimer \
        kwalletmanager \
        librsvg2-common \
        okular \
        okular-extra-backends \
        plasma-dataengines-addons \
        plasma-discover \
        plasma-runners-addons \
        plasma-wallpapers-addons \
        plasma-widgets-addons \
        plasma-workspace-wallpapers \
        qtvirtualkeyboard-plugin \
        sonnet-plugins \
        sweeper \
        systemsettings \
        xdg-desktop-portal-kde \
        kubuntu-restricted-extras \
        kubuntu-wallpapers \
        pavucontrol-qt \
        transmission-qt && \
    apt-get install --install-recommends -y \
        libreoffice \
        libreoffice-style-breeze && \
    rm -rf /var/lib/apt/lists/* && \
    # Fix KDE startup permissions issues in containers
    cp -f /usr/lib/x86_64-linux-gnu/libexec/kf5/start_kdeinit /tmp/ && \
    rm -f /usr/lib/x86_64-linux-gnu/libexec/kf5/start_kdeinit && \
    cp -r /tmp/start_kdeinit /usr/lib/x86_64-linux-gnu/libexec/kf5/start_kdeinit && \
    rm -f /tmp/start_kdeinit

# Wine, Winetricks, Lutris, and PlayOnLinux, this process must be consistent with https://wiki.winehq.org/Ubuntu
ARG WINE_BRANCH=staging
RUN if [ "${UBUNTU_RELEASE}" \< "20.04" ]; then add-apt-repository -y ppa:cybermax-dexter/sdl2-backport; fi && \
    mkdir -pm755 /etc/apt/keyrings && curl -fsSL -o /etc/apt/keyrings/winehq-archive.key "https://dl.winehq.org/wine-builds/winehq.key" && \
    curl -fsSL -o "/etc/apt/sources.list.d/winehq-$(grep VERSION_CODENAME= /etc/os-release | cut -d= -f2).sources" "https://dl.winehq.org/wine-builds/ubuntu/dists/$(grep VERSION_CODENAME= /etc/os-release | cut -d= -f2)/winehq-$(grep VERSION_CODENAME= /etc/os-release | cut -d= -f2).sources" && \
    apt-get update && apt-get install --install-recommends -y \
        winehq-${WINE_BRANCH} && \
    apt-get install --no-install-recommends -y \
        q4wine \
        playonlinux && \
    LUTRIS_VERSION=$(curl -fsSL "https://api.github.com/repos/lutris/lutris/releases/latest" | jq -r '.tag_name' | sed 's/[^0-9\.\-]*//g') && \
    curl -fsSL -O "https://github.com/lutris/lutris/releases/download/v${LUTRIS_VERSION}/lutris_${LUTRIS_VERSION}_all.deb" && \
    apt-get install --no-install-recommends -y ./lutris_${LUTRIS_VERSION}_all.deb && rm -f "./lutris_${LUTRIS_VERSION}_all.deb" && \
    rm -rf /var/lib/apt/lists/* && \
    curl -fsSL -o /usr/bin/winetricks "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks" && \
    chmod 755 /usr/bin/winetricks && \
    curl -fsSL -o /usr/share/bash-completion/completions/winetricks "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks.bash-completion"

# Install latest selkies-gstreamer (https://github.com/selkies-project/selkies-gstreamer) build, Python application, and web application, should be consistent with selkies-gstreamer documentation
RUN apt-get update && apt-get install --no-install-recommends -y \
        build-essential \
        python3-pip \
        python3-dev \
        python3-gi \
        python3-setuptools \
        python3-wheel \
        tzdata \
        sudo \
        udev \
        xclip \
        x11-utils \
        xdotool \
        wmctrl \
        jq \
        gdebi-core \
        x11-xserver-utils \
        xserver-xorg-core \
        libopus0 \
        libgdk-pixbuf2.0-0 \
        libsrtp2-1 \
        libxdamage1 \
        libxml2-dev \
        libwebrtc-audio-processing1 \
        libcairo-gobject2 \
        pulseaudio \
        libpulse0 \
        libpangocairo-1.0-0 \
        libgirepository1.0-dev \
        libjpeg-dev \
        libvpx-dev \
        zlib1g-dev \
        x264 && \
    if [ "${UBUNTU_RELEASE}" \> "20.04" ]; then apt-get install --no-install-recommends -y xcvt; fi && \
    rm -rf /var/lib/apt/lists/* && \
    cd /opt && \
    # Automatically fetch the latest selkies-gstreamer version and install the components
    SELKIES_VERSION=$(curl -fsSL "https://api.github.com/repos/selkies-project/selkies-gstreamer/releases/latest" | jq -r '.tag_name' | sed 's/[^0-9\.\-]*//g') && \
    curl -fsSL "https://github.com/selkies-project/selkies-gstreamer/releases/download/v${SELKIES_VERSION}/selkies-gstreamer-v${SELKIES_VERSION}-ubuntu${UBUNTU_RELEASE}.tgz" | tar -zxf - && \
    curl -O -fsSL "https://github.com/selkies-project/selkies-gstreamer/releases/download/v${SELKIES_VERSION}/selkies_gstreamer-${SELKIES_VERSION}-py3-none-any.whl" && pip3 install "selkies_gstreamer-${SELKIES_VERSION}-py3-none-any.whl" && rm -f "selkies_gstreamer-${SELKIES_VERSION}-py3-none-any.whl" && \
    curl -fsSL "https://github.com/selkies-project/selkies-gstreamer/releases/download/v${SELKIES_VERSION}/selkies-gstreamer-web-v${SELKIES_VERSION}.tgz" | tar -zxf - && \
    cd /usr/local/cuda/lib64 && sudo find . -maxdepth 1 -type l -name "*libnvrtc.so.*" -exec sh -c 'ln -snf $(basename {}) libnvrtc.so' \;

# Install the noVNC web interface and the latest x11vnc for fallback
RUN apt-get update && apt-get install --no-install-recommends -y \
        autoconf \
        automake \
        autotools-dev \
        chrpath \
        debhelper \
        git \
        jq \
        python3 \
        python3-numpy \
        libc6-dev \
        libcairo2-dev \
        libjpeg-turbo8-dev \
        libssl-dev \
        libv4l-dev \
        libvncserver-dev \
        libtool-bin \
        libxdamage-dev \
        libxinerama-dev \
        libxrandr-dev \
        libxss-dev \
        libxtst-dev \
        libavahi-client-dev && \
    rm -rf /var/lib/apt/lists/* && \
    # Build the latest x11vnc source to avoid various errors
    git clone "https://github.com/LibVNC/x11vnc.git" /tmp/x11vnc && \
    cd /tmp/x11vnc && autoreconf -fi && ./configure && make install && cd / && rm -rf /tmp/* && \
    curl -fsSL "https://github.com/novnc/noVNC/archive/v${NOVNC_VERSION}.tar.gz" | tar -xzf - -C /opt && \
    mv -f "/opt/noVNC-${NOVNC_VERSION}" /opt/noVNC && \
    ln -snf /opt/noVNC/vnc.html /opt/noVNC/index.html && \
    # Use the latest Websockify source to expose noVNC
    git clone "https://github.com/novnc/websockify.git" /opt/noVNC/utils/websockify

# Add custom packages right below this comment, or use FROM in a new container and replace entrypoint.sh or supervisord.conf, and set ENTRYPOINT to /usr/bin/supervisord




# install package

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        sudo \
        less \
        apt-utils \
        tzdata \
        git \
        tmux \
        bash-completion \
        command-not-found \
        libglib2.0-0 \
        vim \
        emacs \
        ssh \
        rsync \
        python3 \
        python3-pip \
        python3-dev \
        sed \
        ca-certificates \
        wget \
        gpg \
        gpg-agent \
        gpgconf \
        gpgv \
        locales \
        unzip \
        net-tools \
        software-properties-common \
        apt-transport-https \
        lsb-release \
        autoconf \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        gnupg \
        lsb-release \
        less \
        emacs \
        tmux \
        bash-completion \
        command-not-found \
        software-properties-common \
        xdg-user-dirs \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install ROS2 Humble
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null
RUN apt-get update && apt-get install -y --no-install-recommends \
        ros-humble-desktop \
        ros-dev-tools \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install colcon and rosdep
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3-colcon-common-extensions \
        python3-rosdep \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list

RUN apt-get update && apt-get install -y --no-install-recommends \
        google-chrome-stable && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && rm /etc/apt/sources.list.d/google.list

RUN apt-get update && apt-get install -y --no-install-recommends \
        iproute2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $USERNAME

# install nodejs 18
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
        nodejs && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# initialize rosdep
RUN sudo rosdep init && \
    rosdep update

RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc && \
    echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc

# disabled beep sound
RUN echo "set bell-style none" >> ~/.inputrc

RUN sudo rm /etc/apt/apt.conf.d/docker-clean


# Copy scripts and configurations used to start the container
COPY entrypoint.sh /etc/entrypoint.sh
RUN sudo chmod 755 /etc/entrypoint.sh
COPY selkies-gstreamer-entrypoint.sh /etc/selkies-gstreamer-entrypoint.sh
RUN sudo chmod 755 /etc/selkies-gstreamer-entrypoint.sh
COPY supervisord.conf /etc/supervisord.conf
RUN sudo chmod 755 /etc/supervisord.conf

# Enable ssh
RUN sudo systemctl enable ssh

RUN sudo sed -i "s/<user>/$USERNAME/g" /etc/entrypoint.sh
RUN sudo sed -i "s/<user>/$USERNAME/g" /etc/supervisord.conf

RUN sudo chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# RUN sudo apt-get update \
#     && sudo apt-get install -y locales \
#     && sudo locale-gen ja_JP.UTF-8 \
#     && echo "export LANG=ja_JP.UTF-8" >> ~/.bashrc

# vim setting
# RUN echo '\n\
#     set fenc=utf-8\n\
#     set encoding=utf-8\n\
#     set fileencodings=iso-2022-jp,euc-jp,sjis,utf-8\n\
#     set fileformats=unix,dos,mac\n\
#     syntax on' >> /home/${USERNAME}/.vimrc

ENV TZ Asia/Tokyo
# ENV LANG ja_JP.UTF-8
# ENV LANGUAGE ja_JP:ja


EXPOSE 8080

ENV SHELL /bin/bash
ENV USER $USERNAME
WORKDIR /home/$USERNAME

ENTRYPOINT ["/usr/bin/supervisord"]