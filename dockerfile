FROM node:16
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

WORKDIR /var/www/html

# dependencies

RUN apt-get update
RUN apt-get install -y \
    build-essential \
    locales \
    libzip-dev zip unzip \
    vim \
    git \
    libonig-dev \
    curl \
    cron \
    libcurl4-openssl-dev openssl pkg-config libssl-dev ca-certificates

# nodejs
ENV NODE_VERSION_MAJOR=16
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_VERSION_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update && apt-get install nodejs -y
RUN npm install -g --force yarn

# clear
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# golang
ENV GOLANG_VERSION=1.20.2
RUN curl -s https://dl.google.com/go/go${GOLANG_VERSION}.linux-amd64.tar.gz | tar -xz -C /root
RUN export PATH=$PATH:/root/go/bin
RUN source ~/.profile
ENV PATH $PATH:/root/go/bin
