# =============================================================================
# Dockerfile - Shai-Hulud Detection Scanner
# =============================================================================
#
# Isolated scanning environment for detecting npm supply chain attacks.
# Use this container to safely scan potentially compromised projects.
#
# Build:
#   docker build -t hulud-scanner .
#
# Usage:
#   # Scan current directory
#   docker run --rm -v $(pwd):/target hulud-scanner
#
#   # Scan with JSON output
#   docker run --rm -v $(pwd):/target hulud-scanner --format json
#
#   # Scan specific path
#   docker run --rm -v /path/to/project:/target hulud-scanner
#
#   # Save results to file
#   docker run --rm -v $(pwd):/target -v $(pwd)/results:/results \
#     hulud-scanner --output /results/scan.txt
#
# =============================================================================

FROM node:20-alpine

LABEL maintainer="miccy <https://github.com/miccy>"
LABEL description="Shai-Hulud 2.0 Detection Scanner - Isolated scanning environment"
LABEL version="1.5.1"

# Install required tools
RUN apk add --no-cache \
    bash \
    coreutils \
    findutils \
    grep \
    jq \
    curl \
    git

# Create scanner user (non-root)
RUN addgroup -g 1000 scanner && \
    adduser -u 1000 -G scanner -s /bin/bash -D scanner

# Create directories
RUN mkdir -p /scanner /target /results && \
    chown -R scanner:scanner /scanner /target /results

# Copy scanner scripts
COPY --chown=scanner:scanner scripts/ /scanner/scripts/
COPY --chown=scanner:scanner ioc/ /scanner/ioc/
COPY --chown=scanner:scanner bin/ /scanner/bin/

# Make scripts executable
RUN chmod +x /scanner/scripts/*.sh

# Set working directory
WORKDIR /target

# Switch to non-root user
USER scanner

# Environment variables
ENV PATH="/scanner/scripts:/scanner/bin:$PATH"
ENV SCAN_PATH="/target"
ENV IOC_PATH="/scanner/ioc"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD detect.sh --version || exit 1

# Default entrypoint
ENTRYPOINT ["/scanner/scripts/detect.sh"]

# Default command (scan /target)
CMD ["/target"]
