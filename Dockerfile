FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

RUN apt-get update && apt-get install -y \
    icedtea-netx \
    openjdk-11-jdk \
    libxrender1 \
    libxtst6 \
    libxi6 \
    libxrandr2 \
    libxcursor1 \
    libxinerama1 \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    xwayland \
    x11-apps \
    dbus \
    libdbus-java \
    && rm -rf /var/lib/apt/lists/*

# Создаем пользователя с таким же UID/GID как у хост-пользователя
ARG USERNAME=user
ARG UID=1000
ARG GID=1000

RUN groupadd -g $GID $USERNAME \
    && useradd -m -u $UID -g $GID -s /bin/bash $USERNAME

# Настраиваем разрешения для X11
RUN mkdir -p /home/$USERNAME/.java/.systemPrefs \
    && mkdir -p /home/$USERNAME/.config \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME/

USER $USERNAME
WORKDIR /home/$USERNAME

# Настраиваем Java Security
RUN mkdir -p $HOME/.java/deployment/security/ \
    && echo "deployment.security.level=MEDIUM\n\
deployment.security.validation.ocsp=false\n\
deployment.security.validation.crl=false\n\
deployment.security.mixcode=ENABLE\n\
deployment.security.askgrantdialog.show=false\n\
deployment.security.notinca.warning=false\n\
deployment.security.expired.warning=false\n\
deployment.security.jsse.hostmismatch.warning=false\n\
deployment.webjava.enabled=true" > $HOME/.java/deployment/deployment.properties

CMD ["bash"]