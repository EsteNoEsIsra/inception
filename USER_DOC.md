# Inception - User Documentation

## Overview

This project deploys a complete web infrastructure using Docker Compose. Each service runs inside its own container and communicates through a private Docker network.

The stack includes the following services:

| Service            | Description                                              |
| ------------------ | -------------------------------------------------------- |
| **NGINX**          | Reverse proxy and HTTPS web server using TLS 1.3.        |
| **WordPress**      | Content Management System (CMS) running on PHP-FPM.      |
| **MariaDB**        | Database server used by WordPress.                       |
| **Redis**          | Object cache used to improve WordPress performance.      |
| **Adminer**        | Web-based database management interface for MariaDB.     |
| **vsftpd**         | FTP server used to upload and manage website files.      |
| **Static Website** | Additional static website served through NGINX.          |
| **Glances**        | Web-based monitoring tool for the Docker infrastructure. |

---

# Starting the Project

Before starting the project, make sure Docker and Docker Compose are installed.


Shows all the commands in the Makefile:

```bash
make help
```

Build and start all mandatory services:

```bash
make up
```

Build and start the complete project (mandatory + bonus):

```bash
make bonus
```

The first execution may take a few minutes while Docker builds the images.

---

# Stopping the Project

Stop and remove all running containers:

```bash
make clean
```

Remove containers, images, volumes and local data:

```bash
make fclean
```

---

# Accessing the Services

After the project has started successfully, the following services are available.

| Service        | URL                             |
| -------------- | ------------------------------- |
| WordPress      | https://DOMAIN_NAME             |
| Adminer        | https://DOMAIN_NAME/adminer.php |
| Static Website | https://DOMAIN_NAME/static/     |
| Glances        | https://DOMAIN_NAME/glances/    |

Replace **DOMAIN_NAME** with the domain configured in the `.env` file.

Example:

```text
https://israetor.42.fr
```

---

# FTP Access

Connect using any FTP client (for example FileZilla).

Connection parameters:

* Host: DOMAIN_NAME
* Port: VSFTPD_PORT
* Username: VSFTPD_USER
* Password: stored in `ftp_password.txt`

Uploaded files are stored inside the shared WordPress volume.

---

# Database Access (Adminer)

Open:

```text
https://DOMAIN_NAME/adminer.php
```

Use the following values:

* System: MySQL
* Server: mariadb
* Username: MYSQL_USER (or MYSQL_ROOT)
* Password: stored in the Docker secrets
* Database: MYSQL_DATABASE

Do **not** use `localhost` as the database server. Containers communicate through the Docker network, so the correct hostname is `mariadb`.

---

# Credentials

Sensitive information is stored using Docker Secrets.

The secret files are located in:

```text
secrets/
```

Example:

```text
secrets/
├── db_password.txt
├── db_root_password.txt
├── ftp_password.txt
└── credentials.txt
```

The `.env` file contains the remaining configuration values such as:

* Domain name
* Ports
* Database name
* Usernames
* PHP version
* Redis configuration

Never commit secret files or the `.env` file to a public repository.

---

# Checking the Services

Display all running containers:

```bash
docker ps
```

View the logs of a specific service:

```bash
make logs ID=<container_name>
```

Example:

```bash
make logs ID=nginx
```

Open a shell inside a container:

```bash
make it ID=<container_name>
```

Example:

```bash
make it ID=wordpress
```

---

# Verifying the Installation

The installation is successful if the following conditions are met:

* WordPress is accessible over HTTPS.
* Adminer opens and connects successfully to MariaDB.
* The static website is accessible.
* Redis is running and available.
* FTP accepts client connections.
* Glances displays the monitoring dashboard.
* All containers remain in the **Up** state.

Check container status:

```bash
docker ps
```

Expected output:

```text
nginx       Up
wordpress   Up
mariadb     Up
redis       Up
adminer     Up
vsftpd      Up
website     Up
glances     Up
```

---

# Troubleshooting

If a service fails to start:

1. Check the container logs.

```bash
make logs ID=<container_name>
```

2. Verify that the Docker secrets exist.

3. Verify that the `.env` file contains the correct configuration.

4. Rebuild the project if necessary.

```bash
make fclean
make bonus
```

