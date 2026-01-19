# 🔥 Ralph Inferno

```
🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥
🔥                                              🔥
🔥  ██████╗  █████╗ ██╗     ██████╗ ██╗  ██╗    🔥
🔥  ██╔══██╗██╔══██╗██║     ██╔══██╗██║  ██║    🔥
🔥  ██████╔╝███████║██║     ██████╔╝███████║    🔥
🔥  ██╔══██╗██╔══██║██║     ██╔═══╝ ██╔══██║    🔥
🔥  ██║  ██║██║  ██║███████╗██║     ██║  ██║    🔥
🔥  ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝  ╚═╝    🔥
🔥                                              🔥
🔥          I N F E R N O   M O D E             🔥
🔥                                              🔥
🔥  Build while you sleep. Wake to working code 🔥
🔥                   🌙 → ☀️                     🔥
🔥                                              🔥
🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥
```

AI-driven autonomous development workflow.

## How It Works

Ralph installs as **slash commands** in Claude Code. When you run `npx ralph-inferno install`, it creates a `.ralph/` folder with scripts and a `.claude/commands/` folder with command definitions. Claude Code automatically picks these up - no separate CLI needed!

```
Local Machine                      VM (Sandbox)
┌─────────────────┐               ┌─────────────────┐
│ Claude Code     │               │ Claude Code     │
│ + Ralph commands│  Git Host     │ + ralph.sh      │
│                 │ ────────────► │                 │
│ /ralph:discover │ (GitHub or    │ Runs specs      │
│ /ralph:plan     │  GitLab)      │ autonomously    │
│ /ralph:deploy   │               │                 │
└─────────────────┘               └─────────────────┘
```

**The flow:**
1. You work locally with Claude Code, using `/ralph:discover` and `/ralph:plan`
2. `/ralph:deploy` pushes your specs to your git host (GitHub or GitLab) and starts Ralph on the VM
3. Ralph runs autonomously on the VM while you sleep
4. Next day: `/ralph:review` to test what was built

## Requirements

### Local Machine

| Tool | Required | How to install |
|------|----------|----------------|
| Node.js | Yes | `brew install node` |
| Claude Code | Yes | `npm install -g @anthropic-ai/claude-code` |
| Git CLI | Recommended | GitHub: `brew install gh` then `gh auth login`<br>GitLab: `brew install glab` then `glab auth login` |

### VM (Sandbox)

| Tool | Required | Notes |
|------|----------|-------|
| SSH access | Yes | You need to be able to SSH into the VM |
| Git | Yes | Usually pre-installed |
| Claude Code | Yes | `npm install -g @anthropic-ai/claude-code` |
| Claude auth | Yes | Run `claude login` OR set `ANTHROPIC_API_KEY` |
| Git CLI | Yes | GitHub: `gh auth login` / GitLab: `glab auth login` |

**Important:** Both machines need git host authentication for Git operations to work!

### Optional

- **Claude Chrome Extension** - Lets Claude browse websites during `/ralph:discover`
- Cloud CLI (`hcloud`, `gcloud`, `doctl`, `aws`) - For VM management
- [ntfy.sh](https://ntfy.sh) - Push notifications when Ralph finishes

## Installation

### Step 1: Install Ralph locally

```bash
cd your-project
npx ralph-inferno install
```

This creates:
- `.ralph/` - Scripts and config
- `.claude/commands/` - Slash commands for Claude Code

### Step 2: Set up your VM

SSH into your VM and install the prerequisites:

```bash
# Install Node.js (if not installed)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Claude Code
npm install -g @anthropic-ai/claude-code

# Authenticate Claude (choose one):
claude login                    # If you have Claude Pro/Max subscription
# OR
export ANTHROPIC_API_KEY="sk-ant-..."  # If using API key

# Install and authenticate git CLI
# For GitHub:
sudo apt-get install gh
gh auth login
# For GitLab:
# See https://gitlab.com/gitlab-org/cli for installation
# glab auth login

# Install Playwright dependencies (for E2E tests)
npx playwright install-deps
npx playwright install
```

### Step 3: Verify setup

On your local machine, start Claude Code:
```bash
claude
```

Type `/ralph:` and you should see the available commands:
- `/ralph:discover`
- `/ralph:plan`
- `/ralph:deploy`
- etc.

## Update

Update core files while preserving your config:

```bash
npx ralph-inferno update
```

Or use the slash command in Claude Code:
```
/ralph:update
```

## Workflow

Ralph supports two entry points: **Greenfield** (new apps) and **Brownfield** (existing apps).

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        TWO ENTRY POINTS                                      │
└─────────────────────────────────────────────────────────────────────────────┘

   GREENFIELD (new app)                    BROWNFIELD (existing app)
         │                                          │
         ▼                                          ▼
   /ralph:idea ──────────────────────────► /ralph:change-request
   (BMAD Brainstorm)                       (Analyze scope: S/M/L)
         │                                          │
         ▼                                          │
   PROJECT-BRIEF.md                                 │
         │                                          │
         ▼                                          │
   /ralph:discover                                  │
   (BMAD Analyst)                                   │
         │                                          │
         ▼                                          ▼
      PRD.md ─────────────────────────► CHANGE-REQUEST.md
                            │
                            ▼
                      /ralph:plan
                      (auto-detects input)
                            │
                            ▼
                      /ralph:deploy → VM → /ralph:review
```

### Commands

| Command | Description |
|---------|-------------|
| `/ralph:idea` | **Greenfield start** - BMAD brainstorm → PROJECT-BRIEF.md |
| `/ralph:discover` | BMAD analyst mode → PRD.md |
| `/ralph:change-request` | **Brownfield start** - Analyze changes → CR specs |
| `/ralph:plan` | Creates specs from PRD or Change Request |
| `/ralph:deploy` | Push to git host (GitHub/GitLab), choose mode, start Ralph on VM |
| `/ralph:review` | Open SSH tunnels, test the app |
| `/ralph:status` | Check Ralph's progress on VM |
| `/ralph:abort` | Stop Ralph on VM |

### Deploy Modes

When running `/ralph:deploy`, you choose a mode:

| Mode | What it does |
|------|--------------|
| **Quick** | Spec execution + build verify only |
| **Standard** | + Playwright E2E tests + auto-CR generation |
| **Inferno** | + Design review + parallel worktrees |

### Tips for Best Results

**Discovery mode works best when Claude can browse the web.**

Install the **Claude Chrome Extension** - it lets Claude see and interact with websites you reference during `/ralph:discover`. This enables better research of competitors, APIs, and documentation.

### Example: New App (Greenfield)

```bash
# 1. Install Ralph
npx ralph-inferno install

# 2. Brainstorm & Discover
/ralph:idea "todo app"      # BMAD brainstorm → PROJECT-BRIEF.md
/ralph:discover             # BMAD analyst → PRD.md

# 3. Plan & Deploy
/ralph:plan                 # Generate specs
/ralph:deploy               # Send to VM

# 4. Review
/ralph:review               # Test what Ralph built
```

### Example: Existing App (Brownfield)

```bash
# 1. Describe changes
/ralph:change-request "add dark mode"   # Analyze scope → CR specs

# 2. Plan & Deploy
/ralph:plan                 # Auto-detects Change Request
/ralph:deploy               # Send to VM

# 3. Review
/ralph:review               # Test the changes
```

## Language Agnostic

Ralph auto-detects your project type and uses the appropriate build/test commands:

| Project Type | Build Command | Test Command |
|--------------|---------------|--------------|
| Node.js (package.json) | `npm run build` | `npm test` |
| Rust (Cargo.toml) | `cargo build` | `cargo test` |
| Go (go.mod) | `go build ./...` | `go test ./...` |
| Python (pyproject.toml) | `python -m build` | `pytest` |
| Makefile | `make build` | `make test` |

**Custom commands:** Override in `.ralph/config.json`:
```json
{
  "build_cmd": "yarn build",
  "test_cmd": "yarn test:ci"
}
```

## Safety

Ralph runs AI-generated code autonomously. For safety:

- **ALWAYS run on a disposable VM** - never on your local machine
- Review generated code before production
- Never store credentials in code

### Credential Protection

Ralph automatically scans for secrets before committing code. If any of the following credential patterns are detected in staged files, the commit will be blocked:

| Category | Credentials Detected |
|----------|---------------------|
| **AI Services** | Anthropic API keys (`sk-ant-*`), OpenAI keys (`sk-*`) |
| **GitHub** | Personal access tokens (`ghp_*`, `github_pat_*`), OAuth tokens (`gho_*`), App tokens (`ghu_*`, `ghs_*`) |
| **GitLab** | Personal access tokens (`glpat-*`), OAuth tokens (`gloas-*`) |
| **AWS** | Access Key IDs (`AKIA*`, `ASIA*`, `ABIA*`, `ACCA*`) |
| **Google Cloud** | API keys (`AIza*`), OAuth tokens (`ya29.*`), Service account JSON |
| **Azure** | Storage connection strings, Client secrets (GUID format) |
| **DigitalOcean** | Personal access tokens (`dop_v1_*`), OAuth tokens (`doo_v1_*`) |
| **Hetzner** | API tokens (64-char alphanumeric) |
| **Stripe** | Live keys (`pk_live_*`, `sk_live_*`, `rk_live_*`), Webhook secrets (`whsec_*`) |
| **Twilio** | API keys (`SK*`), Account SIDs (`AC*`) |
| **Slack** | Bot/app tokens (`xoxb-*`, `xoxa-*`, `xoxp-*`, `xoxr-*`, `xoxs-*`) |
| **SendGrid** | API keys (`SG.*`) |
| **Square** | Access tokens (`sq0atp-*`), OAuth secrets (`sq0csp-*`) |
| **Databases** | MongoDB, PostgreSQL, MySQL, Redis connection strings with embedded passwords |
| **Private Keys** | RSA, EC, DSA, OpenSSH, PGP private keys |

This check runs via `check_secrets()` in `.ralph/lib/git-utils.sh` before every commit made by Ralph.

### Dangerous Command Detection

Ralph also blocks commits containing dangerous shell patterns:
- `rm -rf /` or `rm -rf ~`
- `sudo rm -rf`
- `chmod -R 777 /`

## Cloud Providers

Ralph supports multiple cloud providers for VM execution:

| Provider | CLI | Notes |
|----------|-----|-------|
| Hetzner | `hcloud` | Cheapest, great for Europe |
| Google Cloud | `gcloud` | Good free tier |
| DigitalOcean | `doctl` | Simple and reliable |
| AWS | `aws` | Enterprise option |
| SSH | - | Use your own server |

## Git Host Configuration

Ralph supports both **GitHub** and **GitLab** as git hosting platforms.

### During Installation

When you run `npx ralph-inferno install`, you'll be prompted to select your git host:

```
? Git hosting platform?
  1) GitHub
  2) GitLab
```

Ralph will then:
1. Check for the appropriate CLI (`gh` for GitHub, `glab` for GitLab)
2. Auto-detect your username from the CLI if authenticated
3. Configure all commands to use the correct platform

### CLI Setup

**GitHub:**
```bash
# Install
brew install gh          # macOS
sudo apt install gh      # Ubuntu/Debian

# Authenticate
gh auth login
```

**GitLab:**
```bash
# Install (see https://gitlab.com/gitlab-org/cli)
brew install glab        # macOS

# Authenticate
glab auth login
```

### Manual Configuration

You can also manually set or change your git host in `.ralph/config.json`:

```json
{
  "git_host": "gitlab",
  "git": {
    "host": "gitlab",
    "username": "your-gitlab-username"
  }
}
```

### Command Differences

| Operation | GitHub | GitLab |
|-----------|--------|--------|
| Clone repo | `gh repo clone` | `glab repo clone` |
| List changes | `gh pr list` | `glab mr list` |
| Auth check | `gh auth status` | `glab auth status` |

Ralph automatically uses the correct command based on your `git_host` setting.

## Config File

Configuration is stored in `.ralph/config.json`:

```json
{
  "version": "1.0.6",
  "language": "en",
  "provider": "hcloud",
  "vm_name": "ralph-sandbox",
  "region": "fsn1",
  "git_host": "github",
  "git": {
    "host": "github",
    "username": "your-username"
  },
  "claude": {
    "auth_method": "subscription"
  },
  "notifications": {
    "ntfy_enabled": true,
    "ntfy_topic": "my-unique-ralph-topic"
  },
  "build_cmd": "npm run build",
  "test_cmd": "npm test"
}
```

## Documentation

- [Architecture](docs/ARCHITECTURE.md) - System overview and memory model
- [CLI Flags](docs/CLI-FLAGS.md) - All ralph.sh options
- [Token Optimization](docs/TOKEN-OPTIMIZATION.md) - Cost-saving strategies

## Credits & Inspiration

Ralph Inferno builds on ideas from:

- [snarktank/ralph](https://github.com/snarktank/ralph) - Ryan Carson's original Ralph concept
- [how-to-build-a-coding-agent](https://github.com/ghuntley/how-to-build-a-coding-agent) - Geoffrey Huntley's agent patterns
- [claude-ralph](https://github.com/RobinOppenstam/claude-ralph) - Robin Oppenstam's implementation

## License

MIT
