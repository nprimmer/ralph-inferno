#!/bin/bash
#
# requirements.sh - Kolla och installera dependencies för react-supabase stack
#
# Usage:
#   ./requirements.sh [--check|--install|--fix]
#
# Modes:
#   --check   Bara kolla, returnera exit code (default)
#   --install Installera saknade dependencies
#   --fix     Samma som --install
#

set -uo pipefail

# Färger
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

MODE="${1:---check}"
MISSING=()
WARNINGS=()

log() { echo -e "$1"; }
ok() { log "${GREEN}✅ $1${NC}"; }
fail() { log "${RED}❌ $1${NC}"; MISSING+=("$1"); }
warn() { log "${YELLOW}⚠️ $1${NC}"; WARNINGS+=("$1"); }

# =============================================================================
# REQUIRED DEPENDENCIES
# =============================================================================
check_required() {
    log "${BLUE}=== REQUIRED ===${NC}"

    # Node.js
    if command -v node &>/dev/null; then
        local node_ver=$(node --version)
        ok "Node.js $node_ver"
    else
        fail "Node.js - MISSING"
    fi

    # npm
    if command -v npm &>/dev/null; then
        local npm_ver=$(npm --version)
        ok "npm $npm_ver"
    else
        fail "npm - MISSING"
    fi

    # git
    if command -v git &>/dev/null; then
        local git_ver=$(git --version | awk '{print $3}')
        ok "git $git_ver"
    else
        fail "git - MISSING"
    fi

    # TypeScript (global)
    if command -v tsc &>/dev/null; then
        local tsc_ver=$(tsc --version | awk '{print $2}')
        ok "TypeScript $tsc_ver"
    else
        fail "TypeScript (tsc) - MISSING"
    fi

    # Git CLI (gh or glab based on config)
    local git_host=$(grep -o '"git_host"[[:space:]]*:[[:space:]]*"[^"]*"' .ralph/config.json 2>/dev/null | cut -d'"' -f4)
    git_host="${git_host:-github}"
    local git_cli="gh"
    [ "$git_host" = "gitlab" ] && git_cli="glab"

    if command -v $git_cli &>/dev/null; then
        local cli_ver=$($git_cli --version | head -1)
        ok "$git_cli CLI: $cli_ver"
    else
        fail "$git_cli CLI - MISSING"
    fi

    # Claude CLI
    if command -v claude &>/dev/null; then
        ok "Claude CLI installed"
    else
        fail "Claude CLI - MISSING"
    fi
}

# =============================================================================
# OPTIONAL DEPENDENCIES (för full funktionalitet)
# =============================================================================
check_optional() {
    log ""
    log "${BLUE}=== OPTIONAL ===${NC}"

    # Docker (för lokal Supabase)
    if command -v docker &>/dev/null; then
        local docker_ver=$(docker --version | awk '{print $3}' | tr -d ',')
        ok "Docker $docker_ver"
    else
        warn "Docker - MISSING (behövs för lokal Supabase)"
    fi

    # Supabase CLI
    if command -v supabase &>/dev/null; then
        local supa_ver=$(supabase --version 2>/dev/null || echo "unknown")
        ok "Supabase CLI $supa_ver"
    else
        warn "Supabase CLI - MISSING"
    fi

    # Playwright (för E2E)
    if npx playwright --version &>/dev/null 2>&1; then
        ok "Playwright installed"
    else
        warn "Playwright - MISSING (behövs för E2E-tester)"
    fi
}

# =============================================================================
# AUTH STATUS
# =============================================================================
check_auth() {
    log ""
    log "${BLUE}=== AUTH STATUS ===${NC}"

    # Git host auth (gh or glab based on config)
    local git_host=$(grep -o '"git_host"[[:space:]]*:[[:space:]]*"[^"]*"' .ralph/config.json 2>/dev/null | cut -d'"' -f4)
    git_host="${git_host:-github}"
    local git_cli="gh"
    [ "$git_host" = "gitlab" ] && git_cli="glab"

    if $git_cli auth status &>/dev/null 2>&1; then
        local git_user=$($git_cli auth status 2>&1 | grep -i "logged in" | awk '{print $NF}')
        ok "$git_cli: Logged in as $git_user"
    else
        fail "$git_cli: NOT AUTHENTICATED"
    fi

    # Claude auth
    if claude auth status &>/dev/null 2>&1; then
        ok "Claude: Authenticated"
    else
        fail "Claude: NOT AUTHENTICATED"
    fi
}

# =============================================================================
# INSTALL MISSING
# =============================================================================
install_missing() {
    log ""
    log "${BLUE}=== INSTALLING MISSING ===${NC}"

    for dep in "${MISSING[@]}"; do
        case "$dep" in
            *"TypeScript"*)
                log "Installing TypeScript..."
                npm install -g typescript && ok "TypeScript installed" || fail "TypeScript install failed"
                ;;
            *"Supabase CLI"*)
                log "Installing Supabase CLI..."
                npm install -g supabase && ok "Supabase CLI installed" || warn "Supabase CLI install failed"
                ;;
            *"Playwright"*)
                log "Installing Playwright..."
                npx playwright install && ok "Playwright installed" || warn "Playwright install failed"
                ;;
            *"gh:"*|*"Claude:"*)
                log "${YELLOW}$dep kräver manuell autentisering:${NC}"
                if [[ "$dep" == *"gh:"* ]]; then
                    log "  gh auth login"
                else
                    log "  claude login"
                fi
                ;;
            *"Node.js"*|*"npm"*|*"git"*|*"gh CLI"*|*"Claude CLI"*|*"Docker"*)
                log "${YELLOW}$dep måste installeras manuellt${NC}"
                ;;
        esac
    done
}

# =============================================================================
# MAIN
# =============================================================================
main() {
    log ""
    log "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
    log "${BLUE}║       REQUIREMENTS CHECK: react-supabase                  ║${NC}"
    log "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
    log ""

    check_required
    check_optional
    check_auth

    # Summary
    log ""
    log "${BLUE}=== SUMMARY ===${NC}"

    if [ ${#MISSING[@]} -eq 0 ]; then
        log ""
        log "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
        log "${GREEN}║                    ✅ VM READY                             ║${NC}"
        log "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
        log ""
        return 0
    else
        log ""
        log "${RED}Missing (${#MISSING[@]}):${NC}"
        for m in "${MISSING[@]}"; do
            log "  - $m"
        done

        if [ ${#WARNINGS[@]} -gt 0 ]; then
            log ""
            log "${YELLOW}Warnings (${#WARNINGS[@]}):${NC}"
            for w in "${WARNINGS[@]}"; do
                log "  - $w"
            done
        fi

        # Install mode?
        if [[ "$MODE" == "--install" ]] || [[ "$MODE" == "--fix" ]]; then
            install_missing

            # Re-check
            MISSING=()
            WARNINGS=()
            check_required >/dev/null 2>&1
            check_auth >/dev/null 2>&1

            if [ ${#MISSING[@]} -eq 0 ]; then
                log ""
                log "${GREEN}✅ All fixable issues resolved${NC}"
                return 0
            else
                log ""
                log "${RED}Still missing (requires manual action):${NC}"
                for m in "${MISSING[@]}"; do
                    log "  - $m"
                done
                return 1
            fi
        else
            log ""
            log "Kör med ${CYAN}--install${NC} för att fixa automatiskt"
            return 1
        fi
    fi
}

main "$@"
