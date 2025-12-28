# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please report it by:

1. **Opening a security advisory** on GitHub (preferred)
   - Go to the Security tab → Report a vulnerability
2. **Creating a private issue** if security advisories are not available
3. **DO NOT** open a public issue for security vulnerabilities

Please include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

We will respond as soon as possible and work with you to understand and address the issue.

## Security Considerations

### Docker Socket Access

This setup mounts the Docker socket (`/var/run/docker.sock`) which gives containers full access to the Docker daemon. Consider these security implications:

- Containers can start/stop other containers
- Access to host filesystem through volume mounts
- Potential privilege escalation

## Recommendations

1. **Network Isolation**: Use dedicated networks for runner containers
2. **Resource Limits**: Set CPU/memory limits in compose.yml
3. **Regular Updates**: Keep runner images updated
4. **Monitoring**: Monitor container activity and resource usage

## Alternative Approaches

- **Docker-in-Docker (DinD)**: More isolated but complex
- **Podman**: Rootless container runtime
- **Kubernetes**: For larger scale deployments
