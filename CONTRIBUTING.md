# Contributing to GHA Runner

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## Development Setup

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/gha-runner.git`
3. Create a feature branch: `git checkout -b feature/your-feature`

## Testing Changes

Before submitting a PR:

```bash
# Test compose file validation
cp .env.example .env
docker compose config

# Test the management script
./manage.sh --help

# Run the dogfood workflow to test runners
```

## Pull Request Process

1. Update documentation if needed
2. Ensure CI passes
3. Add a clear description of changes
4. Link any related issues

## Code Style

- Use shellcheck for bash scripts
- Follow Docker best practices
- Keep compose files readable and well-commented

## Reporting Issues

Use the issue templates provided in `.github/ISSUE_TEMPLATE/`
