# Docker-in-Docker GitHub Actions Runner

This document explains how to set up and use GitHub Actions self-hosted runners that utilize the host Docker daemon through Docker-in-Docker (DinD) architecture.

## Architecture Overview

The setup consists of:

1. **Host Docker Daemon**: The Docker daemon running on your host system
2. **Runner Containers**: GitHub Actions runner containers that connect to the host Docker daemon
3. **Shared Socket**: `/var/run/docker.sock` mounted into runner containers
4. **Persistent State**: Runner registration state persisted across container restarts

## Goals

- Run GitHub Actions workflows that require Docker builds
- Maintain security through proper permissions and isolation
- Enable container registry authentication (GHCR, Docker Hub, etc.)
- Support parallel job execution with multiple runners
- Persist runner registration across container restarts

## Prerequisites

- Docker installed and running on the host
- GitHub repository with Actions enabled
- Ability to generate runner registration tokens

## Setup Instructions

### 1. Generate Runner Token

1. Navigate to your repository on GitHub
2. Go to Settings → Actions → Runners
3. Click "New self-hosted runner"
4. Copy the registration token from the configuration command

### 2. Configure Environment

```bash
cp .env.example .env
# Edit .env with your repository details
```

Required environment variables:
- `REPO_URL`: Your GitHub repository URL
- `RUNNER_TOKEN`: Registration token from GitHub
- `RUNNER_LABELS`: Labels for runner targeting (optional)

### 3. Start Runners

```bash
# Start all runners
docker compose up -d

# Start specific runners
docker compose up -d runner-1 runner-2

# View logs
docker compose logs -f runner-1
```

### 4. Verify Registration

Check your repository's Actions → Runners page to confirm the runners appear as "Online".

## Usage in Workflows

Target workflows to use your self-hosted runners:

```yaml
name: Build and Deploy
on: [push]

jobs:
  build:
    runs-on: [self-hosted, dind, buildkit]
    steps:
      - uses: actions/checkout@v4
      
      - name: Build Docker image
        run: |
          docker build -t my-app:${{ github.sha }} .
      
      - name: Push to registry
        run: |
          echo "${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u ${{ github.actor }} --password-stdin
          docker push ghcr.io/${{ github.repository }}:${{ github.sha }}
```

## Security Considerations

### Docker Socket Access

The setup mounts `/var/run/docker.sock` into runner containers, which provides Docker API access. This is secured through:

- **User Permissions**: Runners run as the `runner` user with appropriate Docker group membership
- **Read-only Mounts**: Host Docker credentials are mounted read-only
- **Isolated Workspaces**: Each runner has its own working directory

### Network Security

- Runners use `network_mode: host` for simplicity
- Consider using custom Docker networks for additional isolation
- Ensure firewall rules allow necessary GitHub Actions communication

### Credential Management

- Host Docker credentials are inherited by runners
- Use GitHub secrets for sensitive values
- Avoid hardcoding credentials in workflows

## Scaling and Performance

### Adding More Runners

To add additional runners:

1. Copy an existing runner service in `compose.yml`
2. Update the service name and `RUNNER_NAME`
3. Update volume mounts (e.g., `/runner3:/runner3`)
4. Restart the compose stack

### Resource Management

Add resource limits to prevent resource exhaustion:

```yaml
services:
  runner-1:
    # ... other config
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 4G
        reservations:
          cpus: '1.0'
          memory: 2G
```

### Monitoring

Monitor runner health:

```bash
# Check runner status
docker compose ps

# View resource usage
docker stats

# Check runner logs
docker compose logs runner-1
```

## Troubleshooting

### Common Issues

**Runner Registration Fails**
- Verify `REPO_URL` and `RUNNER_TOKEN` are correct
- Check token hasn't expired (tokens expire after 1 hour)
- Ensure repository allows self-hosted runners

**Docker Permission Denied**
- Verify Docker daemon is running: `systemctl status docker`
- Check socket permissions: `ls -la /var/run/docker.sock`
- Ensure host user is in docker group: `groups $USER`

**Node.js Runtime Missing**
- Check `seed-externals` service completed: `docker compose logs seed-externals`
- Verify externals mount: `docker compose exec runner-1 ls -la /home/runner/externals`

**Build Cache Issues**
- Docker builds may be slower without BuildKit cache
- Consider using registry cache or local cache mounts
- Monitor disk usage: `docker system df`

### Debugging Commands

```bash
# Enter runner container
docker compose exec runner-1 bash

# Check Docker access from runner
docker compose exec runner-1 su runner -c "docker version"

# View runner configuration
docker compose exec runner-1 cat /home/runner/.runner

# Check GitHub connectivity
docker compose exec runner-1 su runner -c "curl -I https://api.github.com"
```

## Maintenance

### Updating Runners

```bash
# Pull latest runner image
docker compose pull

# Restart with new image
docker compose up -d --force-recreate
```

### Cleaning Up

```bash
# Stop all runners
docker compose down

# Remove runner state (forces re-registration)
docker volume rm gha-runner_runner-state

# Clean up Docker resources
docker system prune -f
```

### Token Rotation

When runner tokens expire:

1. Generate new token from GitHub
2. Update `RUNNER_TOKEN` in `.env`
3. Restart runners: `docker compose restart`

## Advanced Configuration

### Custom Networks

For additional isolation, use custom Docker networks:

```yaml
networks:
  runner-network:
    driver: bridge

services:
  runner-1:
    networks:
      - runner-network
    # Remove network_mode: host
```

### Registry Authentication

For private registries, ensure host Docker config includes authentication:

```bash
# Login on host (credentials will be inherited)
docker login ghcr.io
docker login registry.example.com
```

### Persistent Volumes

For additional persistence, mount specific directories:

```yaml
volumes:
  - runner-cache:/home/runner/.cache
  - runner-npm:/home/runner/.npm
```

This setup provides a robust, scalable solution for running GitHub Actions workflows with Docker capabilities while maintaining security and performance.
