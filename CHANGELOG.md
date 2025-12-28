# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive CI/CD pipeline with validation and security scanning
- Health checks for runner containers
- Security documentation and best practices
- Issue templates for bug reports and feature requests
- Dogfood testing workflow using project's own runners

### Changed
- Enhanced environment configuration with more options
- Improved documentation structure

### Fixed
- CI validation now properly handles required environment variables

## [1.0.0] - 2025-12-28

### Added
- Initial release
- Docker Compose setup for GitHub Actions self-hosted runners
- Multi-runner support with persistent state
- Host Docker integration
- Management script for runner operations
- Basic documentation and setup guide
