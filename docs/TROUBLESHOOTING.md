# Troubleshooting Guide

## Common Issues

### Runners Not Appearing Online

**Symptoms**: Containers are running but runners show as offline in GitHub

**Solutions**:
1. Check if registration token has expired (tokens expire after 1 hour)
   ```bash
   # Generate new token and update .env
   ./manage.sh token
   docker compose restart
   ```

2. Check container logs for errors:
   ```bash
   docker compose logs runner-1
   ```

3. Clear corrupted state:
   ```bash
   docker compose down
   docker volume rm gha-runner_runner-state
   docker compose up -d
   ```

### Docker Permission Issues

**Symptoms**: Jobs fail with Docker permission errors

**Solutions**:
1. Ensure Docker socket has correct permissions:
   ```bash
   sudo chmod 666 /var/run/docker.sock
   ```

2. Check if user is in docker group:
   ```bash
   sudo usermod -aG docker $USER
   ```

### Resource Exhaustion

**Symptoms**: Runners become unresponsive or jobs fail

**Solutions**:
1. Monitor resource usage:
   ```bash
   docker stats
   ```

2. Add resource limits to compose.yml:
   ```yaml
   deploy:
     resources:
       limits:
         memory: 2G
         cpus: '1.0'
   ```

### Network Issues

**Symptoms**: Runners can't connect to GitHub

**Solutions**:
1. Check network connectivity:
   ```bash
   docker compose exec runner-1 curl -I https://github.com
   ```

2. Verify DNS resolution:
   ```bash
   docker compose exec runner-1 nslookup github.com
   ```

## Getting Help

1. Check existing [issues](https://github.com/repricah/gha-runner/issues)
2. Create a new issue with:
   - Container logs
   - System information
   - Steps to reproduce
