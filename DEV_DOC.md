# Inception - Developer Documentation

## Project Overview

This project deploys a complete Docker-based web infrastructure following the 42 Inception subject.

Each service runs inside its own container and communicates through a dedicated Docker network.

The infrastructure consists of:

* NGINX (TLS 1.3 reverse proxy)
* WordPress (PHP-FPM)
* MariaDB
* Redis
* Adminer
* VSFTPD
* Static Website
* Glances

---

# Prerequisites

Before building the project, install the following software:

* Docker Engine
* Docker Compose (Docker CLI plugin)
* GNU Make

Verify the installation:

```bash
docker --version
docker compose version
make --version
```

---

# Project Structure

```text
.
├── Makefile
├── secrets/
│   ├── db_password.txt
│   ├── db_root_password.txt
│   └── ftp_password.txt
└── src/
    ├── .env
    ├── docker-compose.yml
    ├── docker-compose_bonus.yml
    └── requirements/
        ├── mariadb/
        ├── nginx/
        ├── wordpress/
        └── bonus/
            ├── redis/
            ├── adminer/
            ├── website/
            ├── vsftpd/
            └── glances/
```

---

# Environment Setup

## 1. Create the configuration file

Generate the environment file from the template:

```bash
make setup
```

This creates:

```text
src/.env
```

---

## 2. Configure Docker Secrets

Create the required secret files inside:

```text
secrets/
```

Required files:

```text
db_password.txt
db_root_password.txt
ftp_password.txt
```

These files are mounted into the containers through Docker Secrets and should never be committed to version control.

---

# Building the Project

Build and start the mandatory services:

```bash
make up
```

Build and start the complete infrastructure (mandatory + bonus):

```bash
make bonus
```

Docker Compose automatically builds images that do not already exist.

---

# Project Management

## Stop all containers

```bash
make clean
```

---

## Remove everything

```bash
make fclean
```

This command removes:

* Containers
* Images
* Volumes
* Local persistent data

---

## Rebuild from scratch

```bash
make re
```

---

## Enter a container

```bash
make it ID=<container_name>
```

Example:

```bash
make it ID=wordpress
```

---

## View logs

```bash
make logs ID=<container_name>
```

Example:

```bash
make logs ID=mariadb
```

---

## List running containers

```bash
make ps
```

---

## List Docker images

```bash
make images
```

---

# Docker Compose

The project is split into two Compose files.

## docker-compose.yml

Contains the mandatory services:

* MariaDB
* WordPress
* NGINX

## docker-compose_bonus.yml

Contains the bonus services:

* Redis
* Adminer
* VSFTPD
* Static Website
* Glances

When running:

```bash
make bonus
```

Docker merges both Compose files into a single project.

---

# Data Persistence

Persistent data is stored using bind mounts.

MariaDB data:

```text
/home/<USER>/data/mariadb
```

WordPress files:

```text
/home/<USER>/data/wordpress
```

The directories are automatically created by the Makefile during the setup process.

Because bind mounts are used, data remains available even after containers are removed.

---

# Networks

All containers communicate through a dedicated Docker bridge network.

Service discovery is handled automatically by Docker DNS.

Containers can communicate using their service names.

Examples:

```text
mariadb
wordpress
redis
adminer
website
glances
vsftpd
```

No IP addresses need to be configured manually.

---

# Docker Images

Each service has its own Dockerfile located under:

```text
src/requirements/
```

Each image is built independently and follows the "one service per container" principle.

---

# Useful Docker Commands

List running containers:

```bash
docker ps
```

List all containers:

```bash
docker ps -a
```

Inspect a container:

```bash
docker inspect <container_name>
```

Display container logs:

```bash
docker logs <container_name>
```

Open an interactive shell:

```bash
docker exec -it <container_name> sh
```

Inspect the Docker network:

```bash
docker network inspect inception-network
```

Inspect mounted volumes:

```bash
docker volume ls
```

---

# Development Workflow

1. Update the source code.
2. Rebuild the affected image.
3. Restart the service.
4. Check the container logs.
5. Verify the service from the browser or terminal.

For major changes, perform a full rebuild:

```bash
make fclean
make bonus
```

---

# Troubleshooting

If a container fails to start:

* Check the container logs.
* Verify that all secret files exist.
* Verify the values inside `src/.env`.
* Confirm that the required host directories exist.
* Ensure that the Docker network was created correctly.
* Rebuild the image if necessary.

Most startup issues can be diagnosed using:

```bash
docker logs <container_name>
```

or

```bash
make logs ID=<container_name>
```

