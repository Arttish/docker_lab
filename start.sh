#!/bin/bash

echo "Загрузка кода";
if [ ! -d "./src" ] 
then
    wget -O ./src.tgz https://github.com/go-gitea/gitea/archive/refs/tags/v1.22.6.tar.gz
    mkdir src && tar -xf ./src.tgz -C src --strip-components 1
    rm src.tgz
else
    echo "Код уже загружен";
fi

if [ -d "./src" ] 
then
    docker compose up
fi