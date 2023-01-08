#!/bin/bash

workdir="/home/user/temp/"
cd $workdir

install_freeofice() {
    https://www.freeoffice.com/ru/download/applications
}

install_google-chrome-stable() {
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -;
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list';
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A8580BDC82D3DC6C;
    
    install_packages+=(google-chrome-stable)
}

install_kuro() {
    kuro-desktop
}

install_code() {
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg;
    install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg;
    sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list';
    rm -f packages.microsoft.gpg;
    
    install_packages+=(code)
}

install_postgresql-14() {
    sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list';
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -;
    install_packages+=(postgresql-14)
}

install_pgadmin4() {
    curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg;
    sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update';
    install_packages+=(pgadmin4-web)
}

install_install_python3.10() {
    apt-get install libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev;

    wget https://www.python.org/ftp/python/3.10.9/Python-3.10.9.tgz;
    tar -xvf Python-3.10.9.tgz;
    cd Python-3.10.9/;
    ./configure --enable-optimizations;
    make -j 2;
    make altinstall;
}

install_poetry() {
    curl -sSL https://install.python-poetry.org | python3.10 -;
    manual_actions+=('export PATH="/home/user/.local/bin:$PATH"');
}

install_node-js() {
    curl -fsSL https://deb.nodesource.com/setup_18.x | -E bash -;
    install_packages+=(nodejs)
    add_actions=+('npm install --global yarn;')
}
