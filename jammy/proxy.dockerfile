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
ARG VIRTUALGL_VERSION=3.1
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
    
ARG IN_LOCALE="JP"
ARG IN_TZ="Asia/Tokyo"
ARG IN_LANG="ja_JP.UTF-8"
ARG IN_LANGUAGE="ja_JP:ja"

RUN sed -i.bak -e "s%http://[^ ]\+%http://ftp.riken.go.jp/Linux/ubuntu/%g" /etc/apt/sources.list

# Install locales to prevent X11 errors
RUN apt update && apt install -y locales
RUN locale-gen en_US.UTF-8

ENV TZ UTC
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8


SHELL ["/bin/bash", "-c"]


ARG UID=9001
ARG GID=9001
ARG UNAME=nvidia
ARG HOSTNAME=docker

ARG NEW_HOSTNAME=${HOSTNAME}-Docker

ARG USERNAME=$UNAME
ARG HOME=/home/$USERNAME
RUN apt update && apt install --no-install-recommends -y sudo 

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

RUN ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" > /etc/timezone


# Install Xvfb and other important libraries or packages
RUN dpkg --add-architecture i386 && \
    apt update && apt install --no-install-recommends -y \
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
    if [ "${UBUNTU_RELEASE}" \< "20.04" ]; then apt install --no-install-recommends -y vulkan-utils; else apt install --no-install-recommends -y vulkan-tools; fi && \
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
    apt update && apt install -y --no-install-recommends ./virtualgl_${VIRTUALGL_VERSION}_amd64.deb ./virtualgl32_${VIRTUALGL_VERSION}_amd64.deb && \
    rm -f "virtualgl_${VIRTUALGL_VERSION}_amd64.deb" "virtualgl32_${VIRTUALGL_VERSION}_amd64.deb" && \
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
RUN apt update && apt install --no-install-recommends -y \
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
    transmission-qt \
    libreoffice \
    libreoffice-style-breeze && \
    # Fix KDE startup permissions issues in containers
    cp -f /usr/lib/x86_64-linux-gnu/libexec/kf5/start_kdeinit /tmp/ && \
    rm -f /usr/lib/x86_64-linux-gnu/libexec/kf5/start_kdeinit && \
    cp -r /tmp/start_kdeinit /usr/lib/x86_64-linux-gnu/libexec/kf5/start_kdeinit && \
    rm -f /tmp/start_kdeinit

RUN add-apt-repository ppa:mozillateam/ppa

RUN { \
      echo 'Package: firefox*'; \
      echo 'Pin: release o=LP-PPA-mozillateam'; \
      echo 'Pin-Priority: 1001'; \
      echo ' '; \
      echo 'Package: firefox*'; \
      echo 'Pin: release o=Ubuntu*'; \
      echo 'Pin-Priority: -1'; \
    } > /etc/apt/preferences.d/99mozilla-firefox

RUN apt -y update \
 && apt install -y firefox

# Wine, Winetricks, Lutris, and PlayOnLinux, this process must be consistent with https://wiki.winehq.org/Ubuntu
ARG WINE_BRANCH=staging
RUN if [ "${UBUNTU_RELEASE}" \< "20.04" ]; then add-apt-repository -y ppa:cybermax-dexter/sdl2-backport; fi && \
    mkdir -pm755 /etc/apt/keyrings && curl -fsSL -o /etc/apt/keyrings/winehq-archive.key "https://dl.winehq.org/wine-builds/winehq.key" && \
    curl -fsSL -o "/etc/apt/sources.list.d/winehq-$(grep VERSION_CODENAME= /etc/os-release | cut -d= -f2).sources" "https://dl.winehq.org/wine-builds/ubuntu/dists/$(grep VERSION_CODENAME= /etc/os-release | cut -d= -f2)/winehq-$(grep VERSION_CODENAME= /etc/os-release | cut -d= -f2).sources" && \
    apt update && apt install --install-recommends -y \
    winehq-${WINE_BRANCH} && \
    apt install --no-install-recommends -y \
    q4wine \
    playonlinux && \
    LUTRIS_VERSION=$(curl -fsSL "https://api.github.com/repos/lutris/lutris/releases/latest" | jq -r '.tag_name' | sed 's/[^0-9\.\-]*//g') && \
    curl -fsSL -O "https://github.com/lutris/lutris/releases/download/v${LUTRIS_VERSION}/lutris_${LUTRIS_VERSION}_all.deb" && \
    apt install --no-install-recommends -y ./lutris_${LUTRIS_VERSION}_all.deb && rm -f "./lutris_${LUTRIS_VERSION}_all.deb" && \
    curl -fsSL -o /usr/bin/winetricks "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks" && \
    chmod 755 /usr/bin/winetricks && \
    curl -fsSL -o /usr/share/bash-completion/completions/winetricks "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks.bash-completion"

# Install latest selkies-gstreamer (https://github.com/selkies-project/selkies-gstreamer) build, Python application, and web application, should be consistent with selkies-gstreamer documentation
RUN apt update && apt install --no-install-recommends -y \
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
    if [ "${UBUNTU_RELEASE}" \> "20.04" ]; then apt install --no-install-recommends -y xcvt; fi && \
    cd /opt && \
    # Automatically fetch the latest selkies-gstreamer version and install the components
    SELKIES_VERSION=$(curl -fsSL "https://api.github.com/repos/selkies-project/selkies-gstreamer/releases/latest" | jq -r '.tag_name' | sed 's/[^0-9\.\-]*//g') && \
    curl -fsSL "https://github.com/selkies-project/selkies-gstreamer/releases/download/v${SELKIES_VERSION}/selkies-gstreamer-v${SELKIES_VERSION}-ubuntu${UBUNTU_RELEASE}.tgz" | tar -zxf - && \
    curl -O -fsSL "https://github.com/selkies-project/selkies-gstreamer/releases/download/v${SELKIES_VERSION}/selkies_gstreamer-${SELKIES_VERSION}-py3-none-any.whl" && pip3 install "selkies_gstreamer-${SELKIES_VERSION}-py3-none-any.whl" && rm -f "selkies_gstreamer-${SELKIES_VERSION}-py3-none-any.whl" && \
    curl -fsSL "https://github.com/selkies-project/selkies-gstreamer/releases/download/v${SELKIES_VERSION}/selkies-gstreamer-web-v${SELKIES_VERSION}.tgz" | tar -zxf - && \
    cd /usr/local/cuda/lib64 && sudo find . -maxdepth 1 -type l -name "*libnvrtc.so.*" -exec sh -c 'ln -snf $(basename {}) libnvrtc.so' \;

# Install the noVNC web interface and the latest x11vnc for fallback
RUN apt update && apt install --no-install-recommends -y \
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
    # Build the latest x11vnc source to avoid various errors
    git clone "https://github.com/LibVNC/x11vnc.git" /tmp/x11vnc && \
    cd /tmp/x11vnc && autoreconf -fi && ./configure && make install && cd / && rm -rf /tmp/* && \
    curl -fsSL "https://github.com/novnc/noVNC/archive/v${NOVNC_VERSION}.tar.gz" | tar -xzf - -C /opt && \
    mv -f "/opt/noVNC-${NOVNC_VERSION}" /opt/noVNC && \
    ln -snf /opt/noVNC/vnc.html /opt/noVNC/index.html && \
    # Use the latest Websockify source to expose noVNC
    git clone "https://github.com/novnc/websockify.git" /opt/noVNC/utils/websockify

# install package
RUN apt update && apt install -y --no-install-recommends \
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
    gnupg \
    lsb-release \
    less \
    emacs \
    tmux \
    bash-completion \
    command-not-found \
    software-properties-common \
    xdg-user-dirs \
    iproute2 \
    init \
    systemd \
    locales \
    net-tools \
    iputils-ping \
    curl \
    wget \
    telnet \
    less \
    vim \
    sudo \
    tzdata \
    locales \
    g++ \
    cmake \
    libdbus-1-dev 

RUN if [ "${IN_LOCALE}" = "JP" ]; then \
    apt update &&\
    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends  -y \
    language-pack-ja-base \
    language-pack-ja \
    fcitx-mozc \
    fcitx-libs-dev \
    fcitx-module-dbus \
    kde-config-fcitx \
    fcitx \
    fcitx-frontend-gtk2 \
    fcitx-frontend-gtk3 \
    fcitx-frontend-qt5 \
    fcitx-ui-classic \
    mozc-utils-gui \
    && locale-gen ja_JP.UTF-8 \
    && dbus-launch --sh-syntax --exit-with-session > /dev/null \
    ; \
    fi

ENV TZ ${IN_TZ}
ENV LANG ${IN_LANG}
ENV LANGUAGE ${IN_LANGUAGE}


# install ROS2 Humble
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null
RUN apt update && apt install -y --no-install-recommends \
    ros-humble-desktop \
    ros-dev-tools

# install colcon and rosdep
RUN apt update && apt install -y --no-install-recommends \
    python3-colcon-common-extensions \
    python3-rosdep

# install Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list

RUN apt update && apt install -y --no-install-recommends \
    google-chrome-stable && rm /etc/apt/sources.list.d/google.list


# install nodejs 18
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt update && apt install -y --no-install-recommends nodejs

USER $USERNAME
RUN mkdir /home/${USERNAME}/.config/
RUN touch /home/${USERNAME}/.config/user-dirs.dirs
RUN if [ "${IN_LOCALE}" = "JP" ]; then \
    { \
    echo 'XDG_DESKTOP_DIR="$HOME/Desktop"'; \
    echo 'XDG_DOWNLOAD_DIR="$HOME/Downloads"'; \
    echo 'XDG_TEMPLATES_DIR="$HOME/Templates"'; \
    echo 'XDG_PUBLICSHARE_DIR="$HOME/Public"'; \
    echo 'XDG_DOCUMENTS_DIR="$HOME/Documents"'; \
    echo 'XDG_MUSIC_DIR="$HOME/Music"'; \
    echo 'XDG_PICTURES_DIR="$HOME/Pictures"'; \
    echo 'XDG_VIDEOS_DIR="$HOME/Videos"'; \
    } > /home/${USERNAME}/.config/user-dirs.dirs \
    ; \
    fi
RUN mkdir /home/${USERNAME}/Desktop/
RUN mkdir /home/${USERNAME}/Downloads/
RUN mkdir /home/${USERNAME}/Templates/
RUN mkdir /home/${USERNAME}/Public/
RUN mkdir /home/${USERNAME}/Documents/
RUN mkdir /home/${USERNAME}/Music/
RUN mkdir /home/${USERNAME}/Videos/

# disabled beep sound
RUN echo "set bell-style none" >> ~/.inputrc

RUN mkdir /home/${USERNAME}/Desktop
RUN touch /home/${USERNAME}/Desktop/home.desktop
RUN touch /home/${USERNAME}/Desktop/trash.desktop

# Make Desktop Icons
RUN { \
    echo "[Desktop Entry]"; \
    echo "Encoding=UTF-8"; \
    echo "Name=Home"; \
    echo "GenericName=Personal Files"; \
    echo "URL[$e]=$HOME"; \
    echo "Icon=user-home"; \
    echo "Type=Link"; \
    } > /home/${USERNAME}/Desktop/home.desktop

RUN { \
    echo "[Desktop Entry]"; \
    echo "Name=Trash"; \
    echo "Comment=Contains removed files"; \
    echo "Icon=user-trash-full"; \
    echo "EmptyIcon=user-trash"; \
    echo "URL=trash:/"; \
    echo "Type=Link"; \
    } > /home/${USERNAME}/Desktop/trash.desktop

# initialize rosdep
RUN sudo rosdep init && \
    rosdep update

RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc && \
    echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc

RUN echo "export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH" >> ~/.bashrc

USER root

RUN usermod -a -G adm,audio,cdrom,dialout,dip,fax,floppy,input,lp,lpadmin,plugdev,pulse-access,scanner,sudo,tape,tty,video,voice $USERNAME

# Copy scripts and configurations used to start the container
COPY entrypoint.sh /etc/entrypoint.sh
RUN chmod 755 /etc/entrypoint.sh
COPY selkies-gstreamer-entrypoint.sh /etc/selkies-gstreamer-entrypoint.sh
RUN chmod 755 /etc/selkies-gstreamer-entrypoint.sh
COPY supervisord.conf /etc/supervisord.conf
RUN chmod 755 /etc/supervisord.conf

# Enable ssh
RUN systemctl enable ssh

RUN sed -i "s/<user>/$USERNAME/g" /etc/entrypoint.sh
RUN sed -i "s/<user>/$USERNAME/g" /etc/supervisord.conf

RUN chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

RUN apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN rm /etc/apt/apt.conf.d/docker-clean

EXPOSE 8080

ENV SHELL /bin/bash
ENV USER $USERNAME
WORKDIR /home/$USERNAME

ENTRYPOINT ["/usr/bin/supervisord"]
