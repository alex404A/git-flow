#!/bin/bash

image_version=$(git describe --tags)
code_version=$(python maintain-version-number.py)
echo building... code_version:$code_version  image_version:$image_version

git submodule update --init --recursive

# compile inside a container
docker run -it --rm -v "$PWD":/usr/src/mymaven -v "$HOME/.m2":/root/.m2 -w /usr/src/mymaven maven mvn clean package

# build
docker build --build-arg version=$code_version -t sixestates/sixdocker:6crawler-agent-$image_version -f apps/agent/Dockerfile .
docker build --build-arg version=$code_version -t sixestates/sixdocker:6crawler-link-modifier-$image_version -f apps/link-modifier/Dockerfile .
docker build --build-arg version=$code_version -t sixestates/sixdocker:6crawler-parser-$image_version -f apps/parser/Dockerfile .
docker build --build-arg version=$code_version -t sixestates/sixdocker:6crawler-service-provider-$image_version -f apps/service-provider/Dockerfile .
docker build --build-arg version=$code_version -t sixestates/sixdocker:6crawler-maintain-tool-$image_version -f apps/maintain-tool/Dockerfile .

# push
docker push sixestates/sixdocker:6crawler-agent-$image_version
docker push sixestates/sixdocker:6crawler-link-modifier-$image_version
docker push sixestates/sixdocker:6crawler-parser-$image_version
docker push sixestates/sixdocker:6crawler-service-provider-$image_version
docker push sixestates/sixdocker:6crawler-maintain-tool-$image_version
