FROM ubuntu:20.04

#use help to debug and finding whats wrong with my Dockerfile not working properly on heroku
# https://github.com/ivang7/heroku-vscode
RUN apt-get update \
 && apt-get upgrade -y
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Moscow
RUN apt-get install -y tzdata && \
    apt-get install -y \
    curl \
    wget \
    python3 \
    gcc \ 
    python3-pip \
    gnupg \
    dumb-init \
    htop \
    locales \
    man \
    nano \
    git \
    procps \
    ssh \
    default-jre \
    default-jdk \
    sudo \
    vim \
   rclone \
   php \
   fuse \
    && rm -rf /var/lib/apt/lists/*
    
    
ENV NODE_VERSION=14.8.0
RUN apt install -y curl
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"


  RUN sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen \
  && locale-gen
ENV LANG=en_US.UTF-8

RUN chsh -s /bin/bash
ENV SHELL=/bin/bash

RUN adduser --gecos '' --disabled-password coder && \
  echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

RUN curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.4/fixuid-0.4-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: coder\ngroup: coder\n" > /etc/fixuid/config.yml
    
RUN cd /tmp && \
  curl -L --silent \
  `curl --silent "https://api.github.com/repos/cdr/code-server/releases" \
    | grep '"browser_download_url":' \
    | grep "linux-x86_64" \
    | sed -E 's/.*"([^"]+)".*/\1/' \
    | head -n1 \
  `| tar -xzf - && \
  mv code-server* /usr/local/lib/code-server && \
  ln -s /usr/local/lib/code-server/code-server /usr/local/bin/code-server

ENV PORT=8080
EXPOSE 8080
USER coder
WORKDIR /home/coder
COPY run.sh /home/coder
COPY permission.sh /home/coder

RUN chmod u+x permission.sh

RUN code-server --install-extension liximomo.sftp --force
RUN code-server --install-extension zhuangtongfa.Material-theme --force
RUN code-server --install-extension vscjava.vscode-java-pack --force
RUN code-server --install-extension ms-vscode.cpptools --force
RUN code-server --install-extension waderyan.nodejs-extension-pack --force
RUN code-server --install-extension felixfbecker.php-pack --force
RUN code-server --install-extension felixfbecker.php-pack --force
RUN code-server --install-extension redhat.vscode-yaml --force
RUN code-server --install-extension redhat.vscode-xml --force

RUN mkdir -p /home/coder/.vscode
COPY sftp.json /home/coder/.vscode

CMD bash /home/coder/run.sh ; /usr/local/bin/code-server --host 0.0.0.0 --port $PORT /home/coder
