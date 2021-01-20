# Running nginx, node and PHP easily

### How to use this image ?

First, choose your PHP version and your node version.

Then you can pull 

```sh
docker pull docker.pkg.github.com/senorihl/docker-php-nginx-node/development:php-$PHP_VERSION-node-$NODE_VERSION
```

Where `PHP_VERSION` is one of:
- 8.0
- 7.4

And `NODE_VERSION` is one of:
- v15.6.0
- v14.15.4

The alias `latest` is for latest PHP and node version.

### Adding PHP packages

Since this image uses Ondřej Surý PPA for Ubuntu you can follow its guidelines.
You can also use PECL command line.
There is no `docker-php-ext-*` commands.

### The struggle with permission

In order to handle permission you can run your container with the environment var `DEV_UID` to your UID.

Such as follows:

```sh
docker run -e DEV_UID="$(id -u)" -d -p 80:80 -p 443:443 "docker.pkg.github.com/senorihl/docker-php-nginx-node/development:latest"
```

The `www-data` user will have your UID so no permission conflict when trying to access one file from container.

### Configuration files

You can configure 
- PHP (and fpm) here: `/etc/php/latest` (which is an symlink for `/etc/php/PHP_VERSION`).
- Nginx here: `/etc/nginx` 
- Supervisor here: `/etc/supervisor/`