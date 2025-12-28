#!/bin/bash
set -euo pipefail

# GitHub Actions Runner Management Script
# Provides utilities for managing self-hosted runners

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/compose.yml"
ENV_FILE="${SCRIPT_DIR}/.env"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if .env file exists
check_env() {
    if [[ ! -f "$ENV_FILE" ]]; then
        log_error ".env file not found. Please copy .env.example to .env and configure it."
        exit 1
    fi
    
    # Source the env file to check required variables
    set -a
    source "$ENV_FILE"
    set +a
    
    if [[ -z "${REPO_URL:-}" ]]; then
        log_error "REPO_URL not set in .env file"
        exit 1
    fi
    
    if [[ -z "${RUNNER_TOKEN:-}" ]]; then
        log_error "RUNNER_TOKEN not set in .env file"
        exit 1
    fi
}

# Show usage information
usage() {
    cat << EOF
GitHub Actions Runner Management

Usage: $0 <command> [options]

Commands:
    start [runner-name]     Start all runners or specific runner
    stop [runner-name]      Stop all runners or specific runner
    restart [runner-name]   Restart all runners or specific runner
    status                  Show status of all runners
    logs [runner-name]      Show logs for all runners or specific runner
    clean                   Stop runners and clean up resources
    token                   Generate new runner registration token
    validate                Validate configuration and connectivity

Examples:
    $0 start                # Start all runners
    $0 start runner-1       # Start only runner-1
    $0 logs runner-2        # Show logs for runner-2
    $0 status               # Show status of all runners
    $0 clean                # Clean shutdown and cleanup

EOF
}

# Start runners
start_runners() {
    local runner_name="${1:-}"
    
    check_env
    log_info "Starting GitHub Actions runners..."
    
    if [[ -n "$runner_name" ]]; then
        log_info "Starting specific runner: $runner_name"
        docker compose -f "$COMPOSE_FILE" up -d "$runner_name"
    else
        log_info "Starting all runners"
        docker compose -f "$COMPOSE_FILE" up -d
    fi
    
    log_success "Runners started successfully"
}

# Stop runners
stop_runners() {
    local runner_name="${1:-}"
    
    log_info "Stopping GitHub Actions runners..."
    
    if [[ -n "$runner_name" ]]; then
        log_info "Stopping specific runner: $runner_name"
        docker compose -f "$COMPOSE_FILE" stop "$runner_name"
    else
        log_info "Stopping all runners"
        docker compose -f "$COMPOSE_FILE" stop
    fi
    
    log_success "Runners stopped successfully"
}

# Restart runners
restart_runners() {
    local runner_name="${1:-}"
    
    log_info "Restarting GitHub Actions runners..."
    
    if [[ -n "$runner_name" ]]; then
        log_info "Restarting specific runner: $runner_name"
        docker compose -f "$COMPOSE_FILE" restart "$runner_name"
    else
        log_info "Restarting all runners"
        docker compose -f "$COMPOSE_FILE" restart
    fi
    
    log_success "Runners restarted successfully"
}

# Show runner status
show_status() {
    log_info "GitHub Actions Runner Status:"
    echo
    docker compose -f "$COMPOSE_FILE" ps
    echo
    
    # Show Docker system info
    log_info "Docker System Status:"
    docker system df
}

# Show logs
show_logs() {
    local runner_name="${1:-}"
    
    if [[ -n "$runner_name" ]]; then
        log_info "Showing logs for: $runner_name"
        docker compose -f "$COMPOSE_FILE" logs -f "$runner_name"
    else
        log_info "Showing logs for all runners"
        docker compose -f "$COMPOSE_FILE" logs -f
    fi
}

# Clean up resources
clean_up() {
    log_warning "This will stop all runners and remove containers. Continue? (y/N)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        log_info "Stopping and removing containers..."
        docker compose -f "$COMPOSE_FILE" down
        
        log_info "Cleaning up Docker resources..."
        docker system prune -f
        
        log_success "Cleanup completed"
    else
        log_info "Cleanup cancelled"
    fi
}

# Generate new runner token (placeholder - requires GitHub CLI or API)
generate_token() {
    log_info "To generate a new runner token:"
    echo "1. Go to your repository on GitHub"
    echo "2. Navigate to Settings → Actions → Runners"
    echo "3. Click 'New self-hosted runner'"
    echo "4. Copy the token from the configuration command"
    echo "5. Update RUNNER_TOKEN in your .env file"
    echo
    log_warning "Note: Tokens expire after 1 hour and must be regenerated"
}

# Validate configuration
validate_config() {
    log_info "Validating configuration..."
    
    # Check .env file
    check_env
    log_success ".env file is valid"
    
    # Check Docker
    if ! docker version >/dev/null 2>&1; then
        log_error "Docker is not running or not accessible"
        exit 1
    fi
    log_success "Docker is accessible"
    
    # Check Docker Compose
    if ! docker compose version >/dev/null 2>&1; then
        log_error "Docker Compose is not available"
        exit 1
    fi
    log_success "Docker Compose is available"
    
    # Check GitHub connectivity
    if ! curl -s --connect-timeout 5 https://api.github.com >/dev/null; then
        log_warning "Cannot reach GitHub API (network issue?)"
    else
        log_success "GitHub API is reachable"
    fi
    
    # Check repository URL format
    if [[ ! "$REPO_URL" =~ ^https://github\.com/[^/]+/[^/]+$ ]]; then
        log_warning "REPO_URL format may be incorrect: $REPO_URL"
    else
        log_success "REPO_URL format is valid"
    fi
    
    log_success "Configuration validation completed"
}

# Main command dispatcher
main() {
    case "${1:-}" in
        start)
            start_runners "${2:-}"
            ;;
        stop)
            stop_runners "${2:-}"
            ;;
        restart)
            restart_runners "${2:-}"
            ;;
        status)
            show_status
            ;;
        logs)
            show_logs "${2:-}"
            ;;
        clean)
            clean_up
            ;;
        token)
            generate_token
            ;;
        validate)
            validate_config
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            log_error "Unknown command: ${1:-}"
            echo
            usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
