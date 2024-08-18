#!/usr/bin/env bash

# Copyright (c) 2024-08-01 xulinchun <xulinchun0806@outlook.com>
#
# This file is part of LMD.
#
# LMD is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2.1 of the License, or
# (at your option) any later version.
#
# LMD is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with LMD.  If not, see <http://www.gnu.org/licenses/>.
#==============================================================================

export TMOUT=0
umask 022

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'

# 获取安装包
if [[ $(uname -m) = 'x86_64' ]]; then
  DockerUrl="https://mirror.sjtu.edu.cn/docker-ce/linux/static/stable/x86_64/docker-26.1.4.tgz"
  DockerComposeUrl="https://github.com/docker/compose/releases/download/v2.27.3/docker-compose-linux-x86_64"
elif [[ $(uname -m) = 'aarch64' ]]; then
  DockerUrl="https://mirror.sjtu.edu.cn/docker-ce/linux/static/stable/aarch64/docker-26.1.4.tgz"
  DockerComposeUrl="https://github.com/docker/compose/releases/download/v2.27.3/docker-compose-linux-aarch64"
fi

DockerName=$(echo $DockerUrl | awk -F '/' '{print $NF}')
DockerComposeName=$(echo $DockerComposeUrl | awk -F '/' '{print $NF}')

wget -c -q -O /tmp/lmd/$DockerName $DockerUrl
wget -c -q -O /tmp/lmd/$DockerComposeName $DockerComposeUrl

# 安装
tar -xvf /tmp/lmd/$DockerName -C /tmp/lmd/
yes|cp -a /tmp/lmd/$DockerComposeName /tmp/lmd/docker/docker-compose
chmod -R 0755 /tmp/lmd/docker
chown -R root:root /tmp/lmd/docker
yes|cp -a /tmp/lmd/docker/* /usr/bin/

# 配置 systemd
yes|cp -a /tmp/lmd/config/docker.service /usr/lib/systemd/system/docker.service
chmod 0644 /usr/lib/systemd/system/docker.service

# 创建 docker 组
groupadd -f docker

# 配置 docker
mkdir -p /etc/docker
yes|cp -a /tmp/lmd/config/docker.json /etc/docker/daemon.json
chmod 0644 /etc/docker/daemon.json

# 配置 docker.socket 权限
chmod 0666 /var/run/docker.sock

# 刷新
systemctl daemon-reload