# Inception

### This project has been created as part of the 42 curriculum by israetor

## Description

### Project Overview

**Inception** is a system administration and Docker infrastructure project developed as part of the 42 curriculum.

The goal of the project is to build a complete web infrastructure using **Docker Compose**, where each service runs inside its own dedicated container.

Instead of installing all applications directly on the host machine, each service is isolated in its own container while communicating with the other services through a dedicated Docker network.

The project implements a complete infrastructure composed of:

### Mandatory services

* **NGINX** — HTTPS reverse proxy and main entry point.
* **WordPress** — Content Management System and web application.
* **MariaDB** — Relational database used by WordPress.

### Bonus services

* **Redis** — In-memory cache.
* **Adminer** — Web-based MariaDB administration interface.
* **VSFTPD** — FTP server for file management.
* **Static Website** — Independent static website served from its own container.
* **Glances** — Web-based system and Docker monitoring tool.

---

## Architecture

The main request flow is:

```text
                         Internet
                            │
                         HTTPS :443
                            │
                            ▼
                      ┌───────────┐
                      │   NGINX   │
                      │ TLS 1.3  │
                      └─────┬─────┘
                            │
             ┌──────────────┼──────────────┐
             │              │              │
             ▼              ▼              ▼
        WordPress       Adminer         Website
             │
             ▼
          MariaDB

        Bonus services:
             │
       ┌─────┴─────┐
       ▼           ▼
     Redis       Glances

       VSFTPD
          │
          ▼
   Shared WordPress files
```

All services communicate through the Docker network using Docker's internal DNS and service names.

For example:

```text
nginx → wordpress:9000
nginx → adminer:8080
nginx → website:80
nginx → glances:61208
wordpress → mariadb:3306
```

---

## Dockerfiles

Each service has its own Dockerfile.

A Dockerfile defines **how the image for a service is created**.

The Dockerfiles are responsible for:

* Selecting the base image.
* Installing required packages.
* Installing service dependencies.
* Creating users and directories when necessary.
* Copying configuration files.
* Setting permissions.
* Configuring the service.
* Defining the command used to start the service.

The project follows the principle of **one service per container**.

### NGINX Dockerfile

The NGINX Dockerfile:

* Installs NGINX.
* Installs OpenSSL.
* Copies the NGINX configuration.
* Provides the TLS environment.
* Starts NGINX.

### WordPress Dockerfile

The WordPress Dockerfile:

* Installs PHP.
* Installs PHP-FPM.
* Installs the required PHP extensions.
* Configures PHP-FPM.
* Installs and configures WordPress.

### MariaDB Dockerfile

The MariaDB Dockerfile:

* Installs MariaDB.
* Creates the required directories.
* Configures MariaDB.
* Prepares the database environment.

### Redis Dockerfile

The Redis Dockerfile:

* Installs Redis.
* Configures the Redis server.
* Starts Redis.

### Adminer Dockerfile

The Adminer Dockerfile:

* Installs PHP and PHP-FPM.
* Installs the required PHP extensions.
* Provides the environment required by Adminer.

### VSFTPD Dockerfile

The VSFTPD Dockerfile:

* Installs VSFTPD.
* Installs the required tools for user and FTP management.
* Provides the environment required by the FTP server.

### Static Website Dockerfile

The Website Dockerfile:

* Installs NGINX.
* Copies the static website files.
* Starts the NGINX web server.

### Glances Dockerfile

The Glances Dockerfile:

* Installs Python and pip.
* Installs Glances.
* Installs the web dependencies.
* Runs Glances in web server mode.

The web dependencies are installed with:

```bash
pip3 install --break-system-packages "glances[web]"
```

---

## Docker Compose

Docker Compose is responsible for **orchestrating the containers**.

The Dockerfiles define how the images are built, while Docker Compose defines how the containers interact with each other.

The Compose configuration defines:

* Services.
* Container names.
* Networks.
* Volumes.
* Ports.
* Environment variables.
* Secrets.
* Dependencies.
* Build configuration.

The project uses two Compose files.

### `docker-compose.yml`

Contains the mandatory services:

```text
NGINX
WordPress
MariaDB
```

### `docker-compose_bonus.yml`

Contains the additional services:

```text
Redis
Adminer
VSFTPD
Website
Glances
```

When the bonus target is executed, both Compose files are used together.

---

# Services

## NGINX

NGINX is the public entry point of the infrastructure.

It is responsible for:

* Accepting HTTPS connections.
* Managing TLS certificates.
* Supporting TLS 1.3.
* Redirecting HTTP traffic to HTTPS.
* Acting as a reverse proxy.
* Forwarding PHP requests to WordPress.
* Forwarding requests to Adminer.
* Forwarding requests to the static website.
* Forwarding monitoring requests to Glances.

The host exposes NGINX on port `443`.

---

## WordPress

WordPress is the main web application.

It runs with PHP-FPM and communicates with MariaDB through the Docker network.

```text
NGINX
  │
  │ FastCGI
  ▼
WordPress / PHP-FPM
  │
  │ MySQL
  ▼
MariaDB
```

---

## MariaDB

MariaDB provides the relational database used by WordPress.

It stores WordPress data such as:

* Users.
* Posts.
* Pages.
* Configuration.
* Plugin information.
* Theme information.

Database data is persisted using a host-mounted volume.

---

## Redis

Redis is an in-memory key-value database.

It is included as a bonus service and can be used as a caching layer to reduce repeated database operations and improve application performance.

---

## Adminer

Adminer is a lightweight web interface for managing MariaDB.

It allows administrators to:

* Access databases.
* Browse tables.
* Execute SQL queries.
* Inspect database contents.
* Manage database information.

Adminer is accessible through NGINX.

Example:

```text
https://DOMAIN_NAME/adminer.php
```

---

## VSFTPD

VSFTPD provides FTP access to the project files.

It allows an administrator to connect using an FTP client such as FileZilla and manage files stored in the shared project directory.

The FTP service uses:

* A dedicated FTP user.
* A password stored as a Docker Secret.
* Passive FTP ports for file transfers.

---

## Static Website

The static website is an independent web service running inside its own container.

It uses a separate NGINX instance to serve static HTML content.

The main NGINX container acts as a reverse proxy:

```text
Browser
   │
   ▼
Main NGINX
   │
   ▼
Website container
```

---

## Glances

Glances is used to monitor the infrastructure.

It provides information about:

* CPU usage.
* RAM usage.
* Disk usage.
* Network activity.
* Running processes.
* Docker containers.

Glances runs in web mode and listens on port `61208`.

---

# Instructions

## Prerequisites

The following software is required:

* Docker Engine.
* Docker Compose.
* GNU Make.

Check the installed versions:

```bash
docker --version
docker compose version
make --version
```

---

## Project Configuration

The project uses an environment file:

```text
src/.env
```

A sample configuration is provided:

```text
src/.env.sample
```

Create the `.env` file using:

```bash
make setup
```

The configuration contains variables such as:

```text
DOMAIN_NAME
PHP_VERSION
MYSQL_DATABASE
MYSQL_USER
MYSQL_ROOT
MARIADB_PORT
NGINX_PORT
ADMINER_PORT
REDIS_PORT
VSFTPD_PORT
VSFTPD_DATA_PORT
VSFTPD_USER
ADMINER_VERSION
```

The exact values can be adjusted according to the local environment.

---

## Docker Secrets

Sensitive credentials are stored separately from the Compose configuration.

The required secret files are located in:

```text
secrets/
```

For example:

```text
secrets/
├── db_password.txt
├── db_root_password.txt
├── ftp_password.txt
└── credentials.txt
```

Docker mounts the required secrets inside the containers under:

```text
/run/secrets/
```

Passwords should not be hard-coded into Dockerfiles or committed to a public repository.

---

## Build and Start the Mandatory Services

To build and start the mandatory infrastructure:

```bash
make up
```

This starts:

```text
NGINX
WordPress
MariaDB
```

---

## Build and Start the Complete Project

To build and start the mandatory and bonus services:

```bash
make bonus
```

This starts:

```text
NGINX
WordPress
MariaDB
Redis
Adminer
VSFTPD
Website
Glances
```

---

## Check the Containers

List all containers:

```bash
docker ps -a
```

Or use:

```bash
make ps
```

---

## Check Logs

To check the logs of a specific container:

```bash
docker logs <container_name>
```

For example:

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
docker logs adminer
docker logs vsftpd
docker logs glances
```

The Makefile also provides:

```bash
make logs ID=nginx
```

---

## Access a Container

The Makefile provides a shortcut for opening a shell:

```bash
make it ID=<container_name>
```

For example:

```bash
make it ID=wordpress
```

or:

```bash
make it ID=vsftpd
```

---

## Access the Services

### WordPress

```text
https://DOMAIN_NAME
```

### Adminer

```text
https://DOMAIN_NAME/adminer.php
```

### Static Website

```text
https://DOMAIN_NAME/static/
```

### Glances

The monitoring interface is available through the configured NGINX route.

### VSFTPD

The FTP service can be accessed using an FTP client such as FileZilla.

Use:

```text
Host: DOMAIN_NAME
Port: VSFTPD_PORT
Username: VSFTPD_USER
Password: FTP password
```

---

## Stop the Project

To stop and remove the containers:

```bash
make clean
```

---

## Full Cleanup

To remove containers, images, volumes and local persistent data:

```bash
make fclean
```

**Warning:** this removes the persistent MariaDB and WordPress data stored under:

```text
/home/<USER>/data/
```

---

## Rebuild the Project

To perform a complete rebuild:

```bash
make re
```

---

# Data Persistence

Persistent data is stored on the host system.

MariaDB data:

```text
/home/<USER>/data/mariadb
```

WordPress data:

```text
/home/<USER>/data/wordpress
```

This allows data to survive container recreation.

The general structure is:

```text
Host
 │
 ├── /home/<USER>/data/mariadb
 │          │
 │          ▼
 │      MariaDB
 │
 └── /home/<USER>/data/wordpress
            │
            ▼
        WordPress
```

---

# Resources

The project was developed using official documentation and technical references related to Docker, Linux, NGINX, PHP-FPM, MariaDB and the different bonus services.

## Docker

* Docker Documentation — https://docs.docker.com/
* Docker Compose Documentation — https://docs.docker.com/compose/
* Dockerfile Reference — https://docs.docker.com/reference/dockerfile/
* Docker Volumes — https://docs.docker.com/engine/storage/volumes/
* Docker Networking — https://docs.docker.com/engine/network/

## NGINX

* NGINX Documentation — https://nginx.org/en/docs/
* NGINX Beginner's Guide — https://nginx.org/en/docs/beginners_guide.html

## WordPress

* WordPress Developer Resources — https://developer.wordpress.org/
* WordPress Documentation — https://wordpress.org/documentation/

## MariaDB

* MariaDB Documentation — https://mariadb.com/docs/

## Redis

* Redis Documentation — https://redis.io/docs/

## VSFTPD

* VSFTPD Documentation — https://security.appspot.com/vsftpd.html

## Linux

* Alpine Linux Documentation — https://docs.alpinelinux.org/
* Linux `man` pages — https://man7.org/linux/man-pages/

---

# AI Usage

Artificial Intelligence tools were used as a development and learning aid during this project.

AI was primarily used for:

* Understanding Docker and Docker Compose concepts.
* Understanding how containers communicate through Docker networks.
* Troubleshooting Docker build and runtime errors.
* Understanding NGINX reverse proxy configuration.
* Understanding TLS and HTTPS configuration.
* Debugging PHP-FPM and WordPress connectivity.
* Troubleshooting MariaDB connectivity.
* Understanding Docker volumes and persistent storage.
* Troubleshooting the bonus services.
* Understanding VSFTPD configuration and passive FTP connections.
* Configuring Adminer with PHP-FPM.
* Setting up Glances in web server mode.
* Reviewing and improving project documentation.

FTP connection and networking problems.

The AI-generated suggestions were reviewed, tested and adapted manually to the project.

The final configuration, Dockerfiles, Compose files, scripts and project structure were implemented and tested as part of the development process.

AI was therefore used as a **learning, debugging and documentation assistant**, rather than as a replacement for understanding or testing the project.

