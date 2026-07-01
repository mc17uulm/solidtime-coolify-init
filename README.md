# Solidtime Coolify Init

This repository contains everything required to deploy Solidtime on Coolify using Docker Compose.

It provides:

- A custom initialization image for Solidtime
- Automatic execution of migrations
- Automatic generation of the Laravel `.env` file
- Automatic generation of application keys
- Automatic creation of the initial admin user
- A Docker Compose configuration that can be used as a Coolify "Docker Compose Empty" application

## Purpose

Solidtime currently does not provide a deployment experience that integrates seamlessly with Coolify. This repository fills that gap by providing an initialization container that prepares the required configuration before the Solidtime application starts.

The init container:

1. Validates required environment variables
2. Generates the Laravel configuration file
3. Generates encryption and authentication keys
4. Creates the initial administrator account
5. Exits successfully so the remaining containers can start

## Supported Solidtime Versions

The branch name corresponds to the Solidtime version.

| Branch    | Solidtime Version |
|-----------|-------------------|
| `v0.15.0` | `0.15.0`          |
| `v0.14.0` | `0.14.0`          |

Docker images are automatically published for each version branch.

## Docker Image

The initialization image is published to Docker Hub:

```text
mcombosch/solidtime-coolify-init
```

Version tags match the Solidtime version.

Example:

```text
mcombosch/solidtime-coolify-init:0.15.0
```

## Deploying with Coolify

1. Create a new application in Coolify.
2. Select **Docker Compose Empty**.
3. Copy the contents of `coolify.yml` into the Compose configuration.
4. Configure the required environment variables.
5. Deploy.

## Required Environment Variables

| Variable | Description |
|-----------|-------------|
| APP_NAME | Name of the application |
| POSTGRES_DATABASE | PostgreSQL database name |
| POSTGRES_USER | PostgreSQL username |
| ADMIN_NAME | Initial administrator name |
| ADMIN_EMAIL | Initial administrator email |

The following passwords can be generated automatically using Coolify service variables:

```text
SERVICE_PASSWORD_POSTGRES
SERVICE_PASSWORD_ADMIN
```

## Optional Mail Configuration

| Variable |
|-----------|
| SMTP_HOST |
| SMTP_PORT |
| SMTP_FROM_ADDRESS |
| SMTP_FROM_NAME |
| SMTP_USERNAME |
| SMTP_PASSWORD |

## Files

| File | Description |
|--------|-------------|
| `Dockerfile` | Builds the initialization image |
| `init.sh` | Generates configuration and initializes Solidtime |
| `coolify.yml` | Compose file for deployment in Coolify |
| `test.yml` | Local development and testing setup |

## Building the Init Image

```bash
docker build \
  -t mcombosch/solidtime-coolify-init:0.15.0 .
```

## Local Testing

```bash
docker compose \
  --env-file test.env \
  -f test.yml \
  up
```

## GitHub Actions

Images are automatically built and published for every version branch:

```text
v0.15.0
```

Published tags:

```text
latest
0.15.0
0.14.0
```

## Contributing

Issues and pull requests are welcome.

## License

GNU GPLv3
