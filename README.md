# GitHub Actions Self-Hosted Runner

[![CI](https://github.com/repricah/gha-runner/actions/workflows/ci.yml/badge.svg)](https://github.com/repricah/gha-runner/actions/workflows/ci.yml)
[![Dogfood Test](https://github.com/repricah/gha-runner/actions/workflows/dogfood.yml/badge.svg)](https://github.com/repricah/gha-runner/actions/workflows/dogfood.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Docker Compose setup for running GitHub Actions self-hosted runners that use the host Docker daemon. This setup allows you to run CI/CD workflows with Docker builds while maintaining isolation and security.

## Features

- **Host Docker Integration**: Uses host Docker daemon via socket mounting
- **Multi-Runner Support**: Run multiple runners simultaneously for parallel job execution
- **Persistent State**: Runner registration persists across container restarts
- **Docker Authentication**: Inherits host Docker credentials for registry access
- **Node.js Runtime**: Includes Node.js externals for JavaScript actions

## Quick Start

1. **Clone this repository**:
   ```bash
   git clone https://github.com/repricah/gha-runner.git
   cd gha-runner
   ```

2. **Configure environment**:
   ```bash
   cp .env.example .env
   # Edit .env with your repository URL and runner token
   ```

3. **Start the runners**:
   ```bash
   docker compose up -d
   ```

4. **Verify runners are registered**:
   Check your repository's Settings → Actions → Runners to see the registered runners.

## Configuration

### Environment Variables

- `REPO_URL`: Your GitHub repository URL (e.g., `https://github.com/owner/repo`)
- `RUNNER_TOKEN`: Registration token from GitHub (generate in repo settings)
- `RUNNER_LABELS`: Labels for the runners (default: `self-hosted,dind,buildkit`)

### Runner Registration Token

Generate a registration token from your repository:
1. Go to Settings → Actions → Runners
2. Click "New self-hosted runner"
3. Copy the token from the configuration command

## Architecture

The setup uses the host Docker daemon by mounting `/var/run/docker.sock` into the runner containers. This allows workflows to build and push Docker images while maintaining security through proper user permissions and Docker group membership.

### Security Considerations

- Runners run with appropriate Docker group permissions
- Host Docker credentials are mounted read-only
- Each runner has isolated working directories
- State persistence prevents re-registration on restart

## Usage in Workflows

Target your workflows to use these runners:

```yaml
jobs:
  build:
    runs-on: [self-hosted, dind, buildkit]
    steps:
      - uses: actions/checkout@v4
      - name: Build Docker image
        run: docker build -t my-app .
```

## Scaling

The default setup includes 8 runners. To adjust:

1. **Add more runners**: Copy a runner service in `compose.yml` and update the name/workdir
2. **Remove runners**: Comment out or remove runner services
3. **Resource limits**: Add resource constraints to services as needed

## Troubleshooting

### Runner Registration Issues
- Verify `REPO_URL` and `RUNNER_TOKEN` are correct
- Check that the token hasn't expired
- Ensure the repository allows self-hosted runners

### Docker Permission Issues
- Verify Docker daemon is running on host
- Check `/var/run/docker.sock` permissions
- Ensure user is in docker group on host

### Node.js Runtime Issues
- Check that `seed-externals` service completed successfully
- Verify `/home/runner/externals` mount exists

## License

MIT License - see LICENSE file for details.
