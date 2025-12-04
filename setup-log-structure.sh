#!/usr/bin/env bash
# =============================================================================
# setup-log-structure.sh - Create standardized log directory structure
# =============================================================================

set -euo pipefail

BLUE='\033[1;34m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

say() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[DONE]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

say "Setting up standardized log directory structure..."
echo ""

# ~/Log/ - Main log directory
say "Creating ~/Log/ structure..."
mkdir -p ~/Log/security/{socket,shai-hulud,malware,incidents}
mkdir -p ~/Log/system/{updates,cleanup,doctor,info}
mkdir -p ~/Log/audits/{packages,dependencies,repos}
mkdir -p ~/Log/backups/{configs,scripts,forensic}

success "~/Log/ structure created"

# ~/AI-sandbox/logs/ - AI-sandbox specific logs
say "Creating ~/AI-sandbox/logs/ structure..."
mkdir -p ~/AI-sandbox/logs/socket-audits
mkdir -p ~/AI-sandbox/logs/projects/{dont-be-shy-hulud,ownCTRL,clients}
mkdir -p ~/AI-sandbox/logs/agents/research
mkdir -p ~/AI-sandbox/logs/ci-cd

success "~/AI-sandbox/logs/ structure created"

# Create README files
say "Creating README files..."

cat > ~/Log/README.md << 'EOF'
# Log Directory Structure

This directory contains all system and security logs organized by category.

## Structure

- `security/` - Security-related logs (Socket.dev, malware detection, incidents)
- `system/` - System operation logs (updates, cleanup, diagnostics, info)
- `audits/` - Audit results (packages, dependencies, repositories)
- `backups/` - Critical backups (configs, scripts, forensic evidence)

## Retention Policy

- Regular logs: 30 days
- Security logs: 90 days
- Incident reports: 365 days (1 year)
- Forensic backups: Indefinite (manual cleanup required)

## Naming Conventions

- Folders: `YYYY-MM-DD` format
- Files: `{script}-{YYYYMMDD}-{HHMMSS}.log`
- Reports: `{script}-{YYYYMMDD}-{HHMMSS}-report.{txt|json|md}`
- Forensic: `{incident-type}-{YYYYMMDD}-FORENSIC.tar.gz`
EOF

cat > ~/AI-sandbox/logs/README.md << 'EOF'
# AI-Sandbox Logs

This directory contains logs specific to AI-sandbox projects and operations.

## Structure

- `socket-audits/` - Socket.dev GitHub repository audits
- `projects/` - Project-specific logs
- `agents/` - AI agent research and operation logs
- `ci-cd/` - CI/CD pipeline logs

## Projects

- `dont-be-shy-hulud/` - Shai-Hulud detection toolkit
- `ownCTRL/` - ownCTRL platform development
- `clients/` - Client project logs
EOF

success "README files created"

# Create .gitignore for logs
say "Creating .gitignore files..."

cat > ~/Log/.gitignore << 'EOF'
# Ignore all log files
*.log
*.txt
*.json
*.md
*.tar.gz

# Except README
!README.md
!.gitignore

# Keep directory structure
!*/
EOF

cat > ~/AI-sandbox/logs/.gitignore << 'EOF'
# Ignore all log files
*.log
*.txt
*.json
*.csv
*.tar.gz

# Except README and specific documentation
!README.md
!.gitignore
!*/AUDIT.md

# Keep directory structure
!*/
EOF

success ".gitignore files created"

# Create log rotation script
say "Creating log rotation helper..."

cat > ~/Log/rotate-logs.sh << 'EOFROTATE'
#!/usr/bin/env bash
# Log rotation helper - run weekly

RETENTION_DAYS_REGULAR=30
RETENTION_DAYS_SECURITY=90
RETENTION_DAYS_INCIDENTS=365

echo "Rotating logs..."

# Regular logs (30 days)
find ~/Log/system ~/Log/audits -type f -name "*.log" -mtime +$RETENTION_DAYS_REGULAR -delete
echo "Deleted regular logs older than $RETENTION_DAYS_REGULAR days"

# Security logs (90 days)
find ~/Log/security/{socket,shai-hulud,malware} -type f -name "*.log" -mtime +$RETENTION_DAYS_SECURITY -delete
echo "Deleted security logs older than $RETENTION_DAYS_SECURITY days"

# Incident reports (365 days)
find ~/Log/security/incidents -type f -mtime +$RETENTION_DAYS_INCIDENTS -delete
echo "Deleted incident reports older than $RETENTION_DAYS_INCIDENTS days"

# Forensic backups (manual cleanup only - do not auto-delete)
echo "Forensic backups in ~/Log/backups/forensic/ require manual review"

echo "Log rotation complete"
EOFROTATE

chmod +x ~/Log/rotate-logs.sh
success "Log rotation script created"

echo ""
echo "========================================================================"
echo "Log structure setup complete!"
echo "========================================================================"
echo ""
echo "Directories created:"
echo "  ~/Log/ (main logs)"
echo "  ~/AI-sandbox/logs/ (project logs)"
echo ""
echo "Maintenance:"
echo "  Run ~/Log/rotate-logs.sh weekly for cleanup"
echo ""
echo "Next steps:"
echo "  1. Update dot-bin scripts to use new log structure"
echo "  2. Move existing logs to new structure"
echo "  3. Setup cron job for log rotation (optional)"
echo ""
