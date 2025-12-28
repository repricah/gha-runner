# Contributing to gha-runner

Thank you for your interest in contributing to gha-runner! This document provides guidelines for contributing to this project.

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue using our [bug report template](https://github.com/repricah/gha-runner/issues/new?template=bug_report.yml).

Include:
- Clear description of the issue
- Steps to reproduce
- Expected vs actual behavior
- Relevant log output
- Version information

### Suggesting Features

We welcome feature suggestions! Please open an issue with:
- Clear description of the proposed feature
- Use case and motivation
- Possible implementation approach

### Submitting Pull Requests

1. **Fork the repository** and create a branch from `main`
2. **Make your changes** following our guidelines below
3. **Test your changes** to ensure they work as expected
4. **Update documentation** if needed
5. **Submit a pull request** with a clear description

## Development Guidelines

### Code Style

- Follow existing code patterns and conventions
- Keep scripts POSIX-compliant where possible
- Use meaningful variable names and comments
- Test changes with `shellcheck` for shell scripts

### Docker Compose Changes

- Validate compose files: `docker compose config`
- Test locally before submitting
- Document any new environment variables in `.env.example`
- Update README.md if configuration changes

### Documentation

- Update README.md for user-facing changes
- Update docs/ for detailed guides
- Keep documentation clear and concise
- Include code examples where helpful

### Testing

Before submitting a PR:
- Run `./manage.sh --help` to verify script functionality
- Validate compose file: `docker compose config`
- Test runner startup locally if possible
- Verify documentation renders correctly

### Commit Messages

- Use clear, descriptive commit messages
- Start with a verb (Add, Fix, Update, etc.)
- Keep first line under 72 characters
- Add details in body if needed

Example:
```
Add feature request issue template

- Created template with standard fields
- Includes motivation and use case sections
```

## Code of Conduct

Please note that this project is released with a [Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

## Questions?

Feel free to open an issue for questions or discussion about contributions.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
