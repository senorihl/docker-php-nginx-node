#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

DEFAULT_PHP_VERSION=8.0
PHP_VERSION=${PHP_VERSION:=$DEFAULT_PHP_VERSION}
DEFAULT_NODE_VERSION=$(node -v)
NODE_VERSION=${NODE_VERSION:=$DEFAULT_NODE_VERSION}
DEFAULT_IMAGE_VERSION=php-${PHP_VERSION}-node-${NODE_VERSION:1}
DOCKER_IMAGE_VERSION=${DOCKER_IMAGE_VERSION:=$DEFAULT_IMAGE_VERSION}
DOCKER_IMAGE_NAME='development'
DOCKER_IMAGE="docker.pkg.github.com/senorihl/docker-php-nginx-node/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}"

case $1 in
  build)
    docker build \
      -t "${DOCKER_IMAGE}" \
      --build-arg "NODE_VERSION=${NODE_VERSION}" \
      --build-arg "PHP_VERSION=${PHP_VERSION}" \
      .
  ;;
  start)
    docker run -e DEV_UID="$(id -u)" -e DEV_GID="$(id -g)" -d -p 80:80 -p 443:443 --name="travis_test_container" "${DOCKER_IMAGE}"
  ;;
  test)
    curl -sL -w "%{http_code}\\n" "http://127.0.0.1/" -o /dev/null && \
    curl -s http://127.0.0.1/ | grep "phpinfo\(\)"
  ;;
  root)
    docker exec -it travis_test_container "/bin/bash"
  ;;
  www-data)
    docker exec -u www-data -it travis_test_container "/bin/bash"
  ;;
  push)
    docker push "${DOCKER_IMAGE}"
  ;;
  "") echo "Missing action build | test | push" && exit 1
  ;;
  *) echo "Invalid action $1" >&2 && exit 1
  ;;
esac
