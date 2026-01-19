#!/bin/bash
# git-utils.sh - Git commit and push helpers
# Source this file: source lib/git-utils.sh

MAIN_BRANCH="${MAIN_BRANCH:-main}"

# Commit changes
commit_changes() {
    local message="$1"

    [ -z "$(git status --porcelain 2>/dev/null)" ] && return 0

    git add -A
    git commit -m "$message" >/dev/null 2>&1 || true
}

# Push to remote (uses current branch by default)
push_changes() {
    local current_branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "$MAIN_BRANCH")
    local branch="${1:-$current_branch}"

    git push origin "$branch" >/dev/null 2>&1 || true
}

# Commit and push (uses current branch by default)
commit_and_push() {
    local message="$1"
    local current_branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "$MAIN_BRANCH")
    local branch="${2:-$current_branch}"

    commit_changes "$message"
    push_changes "$branch"
}

# Check for dangerous patterns in diff
check_dangerous() {
    local diff_content
    diff_content=$(git diff 2>/dev/null) || return 0

    local dangerous=(
        "rm -rf /"
        "rm -rf ~"
        "sudo rm -rf"
        "chmod -R 777 /"
    )

    for pattern in "${dangerous[@]}"; do
        if echo "$diff_content" | grep -qF "$pattern"; then
            echo "[DANGER] Found: $pattern"
            return 1
        fi
    done

    return 0
}

# Check for secrets in staged files
check_secrets() {
    local patterns=(
        # AI Services
        "sk-ant-[a-zA-Z0-9]{20,}"           # Anthropic API key
        "sk-[a-zA-Z0-9]{40,}"               # OpenAI API key

        # Git Platforms
        "ghp_[a-zA-Z0-9]{36,}"              # GitHub PAT (fine-grained)
        "github_pat_[a-zA-Z0-9]{22,}"       # GitHub PAT (new format)
        "gho_[a-zA-Z0-9]{36,}"              # GitHub OAuth token
        "ghu_[a-zA-Z0-9]{36,}"              # GitHub user-to-server token
        "ghs_[a-zA-Z0-9]{36,}"              # GitHub server-to-server token
        "glpat-[a-zA-Z0-9_-]{20,}"          # GitLab PAT
        "gloas-[a-zA-Z0-9_-]{20,}"          # GitLab OAuth token

        # AWS
        "AKIA[0-9A-Z]{16}"                  # AWS Access Key ID
        "ABIA[0-9A-Z]{16}"                  # AWS STS token
        "ACCA[0-9A-Z]{16}"                  # AWS CloudFront
        "ASIA[0-9A-Z]{16}"                  # AWS temporary credentials

        # Google Cloud
        "AIza[0-9A-Za-z_-]{35}"             # Google API key
        '"type":\s*"service_account"'       # GCP service account JSON
        "ya29\.[0-9A-Za-z_-]{50,}"          # Google OAuth token

        # Azure
        "[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}" # Azure client ID/secret (GUID format - broad)
        "DefaultEndpointsProtocol=https;AccountName=" # Azure Storage connection string

        # DigitalOcean
        "dop_v1_[a-f0-9]{64}"               # DigitalOcean PAT
        "doo_v1_[a-f0-9]{64}"               # DigitalOcean OAuth token

        # Hetzner
        "[a-zA-Z0-9]{64}"                   # Hetzner API token (64 char alphanumeric) - checked with context

        # Other Cloud/Services
        "SG\.[a-zA-Z0-9_-]{22}\.[a-zA-Z0-9_-]{43}" # SendGrid API key
        "xox[baprs]-[0-9a-zA-Z]{10,}"       # Slack tokens
        "sq0atp-[0-9A-Za-z_-]{22}"          # Square access token
        "sq0csp-[0-9A-Za-z_-]{43}"          # Square OAuth secret
        "SK[a-f0-9]{32}"                    # Twilio API key
        "AC[a-f0-9]{32}"                    # Twilio Account SID
        "pk_live_[0-9a-zA-Z]{24,}"          # Stripe publishable key
        "sk_live_[0-9a-zA-Z]{24,}"          # Stripe secret key
        "rk_live_[0-9a-zA-Z]{24,}"          # Stripe restricted key
        "whsec_[0-9a-zA-Z]{32,}"            # Stripe webhook secret

        # Database connection strings
        "mongodb(\+srv)?://[^:]+:[^@]+@"    # MongoDB connection string with password
        "postgres(ql)?://[^:]+:[^@]+@"      # PostgreSQL connection string with password
        "mysql://[^:]+:[^@]+@"              # MySQL connection string with password
        "redis://[^:]+:[^@]+@"              # Redis connection string with password

        # Private keys
        "-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----" # Private keys
        "-----BEGIN PGP PRIVATE KEY BLOCK-----" # PGP private key
    )

    for pattern in "${patterns[@]}"; do
        if git diff --cached 2>/dev/null | grep -qE "$pattern"; then
            echo "[DANGER] Secret pattern found: $pattern"
            return 1
        fi
    done

    return 0
}
