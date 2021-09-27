# HAPCert
HAProxy and Certbot work together to bring semi-automatic certificate handling to web applications in a Docker environment.

- [HAPCert](#hapcert)
  - [Docker](#docker)
  - [HAProxy](#haproxy)
    - [Configuration](#configuration)
  - [Certbot](#certbot)
    - [Configuration](#configuration-1)
  - [Useful links](#useful-links)

## Docker
For the first deployment it is crucial to create the `hapnet` network and the `certificates` volume:
```shell
docker network create hapnet
docker volume create --name=certificates
```

Deploy the composition with:
```shell
docker-compose up --build -d
docker-compose logs -f
```

## HAProxy
* [HAProxy Docker Image](https://hub.docker.com/_/haproxy)
* [HAProxy for Docker containers](https://www.davole.com/2017/haproxy-for-docker-containers/)

### Configuration
* Configure [init-addr](https://cbonte.github.io/haproxy-dconv/2.0/configuration.html#5.2-init-addr) to avoid errors if no server in the `letsencrypt` backend is up.
* Configure `ACL`s in the `https` frontend that correspond to the domains
* Set up a `backend` for each domain (`server <server-name> <container-name>:<container-port> check inter 10s resolvers docker`)
* Route traffic to backends using `use_backend` and the corresponding `ACL`s

## Certbot
* [Certbot Docker Image](https://hub.docker.com/r/certbot/certbot)
* [Certbot Documentation](https://certbot.eff.org/docs/)
* [Nginx and Let’s Encrypt with Docker](https://medium.com/@pentacent/nginx-and-lets-encrypt-with-docker-in-less-than-5-minutes-b4b8a60d3a71)

The certbot container is configured in such a way that it executes the `certificator.sh` script every 12 hours (as suggested by _Let's Encrypt_), creating new certificates or renewing the certificates which are about to expire. `certificator.sh` fetches the list of [domain-scripts](#configuration-1) to know for which domains certificates need to be created/renewed.

### Configuration
In order to add new domains to HAPCert a new domain script needs to be added. Domain scripts contain the certbot command to request a new certificate from Let's Encrypt.

Domain script for `example.com` (`./scripts/domains/example.com.sh`):
```bash
#!/bin/bash

NAME="example.com"
EMAIL="info@example.com"

# Request new certificates
certbot certonly --standalone \
  --non-interactive --agree-tos --email $EMAIL --http-01-port=380 \
  --cert-name $NAME \
  -d example.com -d www.example.com
```

## Useful links
* [LetsEncrypt with HAProxy](https://serversforhackers.com/c/letsencrypt-with-haproxy)
* [Dynamic SSL Certificate Storage](https://www.haproxy.com/blog/dynamic-ssl-certificate-storage-in-haproxy/)
