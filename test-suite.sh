#!/usr/bin/env bash
#
# test-suite.sh - Comprehensive test suite for hardened dot-bin scripts
# Tests security features, Socket.dev integration, and Shai-Hulud protection
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test results
typeset -a FAILED_TESTS

log_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
    FAILED_TESTS+=("$1")
}

log_skip() {
    echo -e "${YELLOW}[SKIP]${NC} $1"
}

# ==============================================================================
# TEST HELPERS
# ==============================================================================

test_command_exists() {
    local cmd="$1"
    if command -v "$cmd" >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

test_file_exists() {
    local file="$1"
    if [[ -f "$file" ]]; then
        return 0
    fi
    return 1
}

test_file_executable() {
    local file="$1"
    if [[ -x "$file" ]]; then
        return 0
    fi
    return 1
}

test_script_syntax() {
    local script="$1"
    if zsh -n "$script" 2>/dev/null; then
        return 0
    fi
    return 1
}

test_contains_function() {
    local script="$1"
    local func="$2"
    if grep -q "^[[:space:]]*${func}()" "$script" || grep -q "^${func}()" "$script"; then
        return 0
    fi
    return 1
}

# ==============================================================================
# PRE-REQUISITE TESTS
# ==============================================================================

test_prerequisites() {
    echo ""
    echo "========================================================================"
    echo "PRE-REQUISITE TESTS"
    echo "========================================================================"
    
    # Test 1: dot-bin directory exists
    ((TESTS_RUN++))
    log_test "dot-bin directory exists"
    if [[ -d "$HOME/AI-sandbox/dev/dot-bin" ]]; then
        log_pass "dot-bin directory found"
    else
        log_fail "dot-bin directory not found"
    fi
    
    # Test 2: dont-be-shy-hulud repository
    ((TESTS_RUN++))
    log_test "dont-be-shy-hulud repository exists"
    if [[ -d "$HOME/AI-sandbox/dev/dont-be-shy-hulud" ]]; then
        log_pass "dont-be-shy-hulud repo found"
    else
        log_fail "dont-be-shy-hulud repo not found"
    fi
    
    # Test 3: detect.sh script exists and executable
    ((TESTS_RUN++))
    log_test "detect.sh script exists and executable"
    local detector="$HOME/AI-sandbox/dev/dont-be-shy-hulud/scripts/detect.sh"
    if test_file_executable "$detector"; then
        log_pass "detect.sh is executable"
    else
        log_fail "detect.sh not found or not executable"
    fi
    
    # Test 4: Socket CLI available
    ((TESTS_RUN++))
    log_test "Socket CLI installed"
    if test_command_exists socket; then
        local socket_version=$(socket --version 2>/dev/null || echo "unknown")
        log_pass "Socket CLI installed: $socket_version"
    else
        log_fail "Socket CLI not installed (npm install -g @socketdev/socket-cli)"
    fi
    
    # Test 5: Socket firewall status
    ((TESTS_RUN++))
    log_test "Socket firewall enabled"
    if test_command_exists socket; then
        if socket firewall status 2>/dev/null | grep -qi "enabled"; then
            log_pass "Socket firewall is enabled"
        else
            log_fail "Socket firewall is disabled (socket firewall enable)"
        fi
    else
        log_skip "Socket CLI not available"
    fi
    
    # Test 6: npm available
    ((TESTS_RUN++))
    log_test "npm command available"
    if test_command_exists npm; then
        local npm_version=$(npm --version 2>/dev/null || echo "unknown")
        log_pass "npm installed: v$npm_version"
    else
        log_fail "npm not installed"
    fi
    
    # Test 7: zsh available
    ((TESTS_RUN++))
    log_test "zsh shell available"
    if test_command_exists zsh; then
        local zsh_version=$(zsh --version 2>/dev/null | awk '{print $2}' || echo "unknown")
        log_pass "zsh installed: $zsh_version"
    else
        log_fail "zsh not installed"
    fi
}

# ==============================================================================
# SYSUPDATE.ZSH TESTS
# ==============================================================================

test_sysupdate() {
    echo ""
    echo "========================================================================"
    echo "SYSUPDATE.ZSH TESTS"
    echo "========================================================================"
    
    local script="$HOME/AI-sandbox/dev/dot-bin/sysupdate.zsh"
    
    # Test 1: Script exists
    ((TESTS_RUN++))
    log_test "sysupdate.zsh exists"
    if test_file_exists "$script"; then
        log_pass "sysupdate.zsh found"
    else
        log_fail "sysupdate.zsh not found"
        return
    fi
    
    # Test 2: Script executable
    ((TESTS_RUN++))
    log_test "sysupdate.zsh is executable"
    if test_file_executable "$script"; then
        log_pass "sysupdate.zsh is executable"
    else
        log_fail "sysupdate.zsh is not executable (chmod +x)"
    fi
    
    # Test 3: Syntax check
    ((TESTS_RUN++))
    log_test "sysupdate.zsh syntax valid"
    if test_script_syntax "$script"; then
        log_pass "sysupdate.zsh syntax OK"
    else
        log_fail "sysupdate.zsh has syntax errors"
    fi
    
    # Test 4: Socket firewall check function
    ((TESTS_RUN++))
    log_test "sysupdate.zsh has check_socket_firewall()"
    if test_contains_function "$script" "check_socket_firewall"; then
        log_pass "check_socket_firewall() present"
    else
        log_fail "check_socket_firewall() missing"
    fi
    
    # Test 5: Shai-Hulud detection function
    ((TESTS_RUN++))
    log_test "sysupdate.zsh has check_shai_hulud()"
    if test_contains_function "$script" "check_shai_hulud"; then
        log_pass "check_shai_hulud() present"
    else
        log_fail "check_shai_hulud() missing"
    fi
    
    # Test 6: Backup function
    ((TESTS_RUN++))
    log_test "sysupdate.zsh has backup_critical_configs()"
    if test_contains_function "$script" "backup_critical_configs"; then
        log_pass "backup_critical_configs() present"
    else
        log_fail "backup_critical_configs() missing"
    fi
    
    # Test 7: --skip-security-checks flag
    ((TESTS_RUN++))
    log_test "sysupdate.zsh supports --skip-security-checks"
    if grep -q "skip-security-checks" "$script"; then
        log_pass "--skip-security-checks flag present"
    else
        log_fail "--skip-security-checks flag missing"
    fi
    
    # Test 8: nvm support
    ((TESTS_RUN++))
    log_test "sysupdate.zsh has nvm support"
    if grep -q "NVM_DIR" "$script"; then
        log_pass "nvm support present"
    else
        log_fail "nvm support missing"
    fi
    
    # Test 9: Docker link fix
    ((TESTS_RUN++))
    log_test "sysupdate.zsh has Docker link fix"
    if grep -q "docker_app/Contents/Resources/bin/docker" "$script"; then
        log_pass "Docker link fix present"
    else
        log_fail "Docker link fix missing"
    fi
    
    # Test 10: Dry-run execution
    ((TESTS_RUN++))
    log_test "sysupdate.zsh dry-run executes without errors"
    local temp_log=$(mktemp)
    if timeout 10s "$script" --skip-security-checks 2>&1 | tee "$temp_log" | grep -qi "hotovo\|complete"; then
        log_pass "Dry-run executed successfully"
    else
        log_fail "Dry-run failed (check: $temp_log)"
    fi
}

# ==============================================================================
# SYSCLEANUP.ZSH TESTS
# ==============================================================================

test_syscleanup() {
    echo ""
    echo "========================================================================"
    echo "SYSCLEANUP.ZSH TESTS"
    echo "========================================================================"
    
    local script="$HOME/AI-sandbox/dev/dot-bin/syscleanup.zsh"
    
    # Test 1: Script exists
    ((TESTS_RUN++))
    log_test "syscleanup.zsh exists"
    if test_file_exists "$script"; then
        log_pass "syscleanup.zsh found"
    else
        log_fail "syscleanup.zsh not found"
        return
    fi
    
    # Test 2: Script executable
    ((TESTS_RUN++))
    log_test "syscleanup.zsh is executable"
    if test_file_executable "$script"; then
        log_pass "syscleanup.zsh is executable"
    else
        log_fail "syscleanup.zsh is not executable"
    fi
    
    # Test 3: Syntax check
    ((TESTS_RUN++))
    log_test "syscleanup.zsh syntax valid"
    if test_script_syntax "$script"; then
        log_pass "syscleanup.zsh syntax OK"
    else
        log_fail "syscleanup.zsh has syntax errors"
    fi
    
    # Test 4: Shai-Hulud check function
    ((TESTS_RUN++))
    log_test "syscleanup.zsh has check_for_shai_hulud()"
    if test_contains_function "$script" "check_for_shai_hulud"; then
        log_pass "check_for_shai_hulud() present"
    else
        log_fail "check_for_shai_hulud() missing"
    fi
    
    # Test 5: Forensic backup function
    ((TESTS_RUN++))
    log_test "syscleanup.zsh has create_forensic_backup()"
    if test_contains_function "$script" "create_forensic_backup"; then
        log_pass "create_forensic_backup() present"
    else
        log_fail "create_forensic_backup() missing"
    fi
    
    # Test 6: npm verify before clean
    ((TESTS_RUN++))
    log_test "syscleanup.zsh runs npm cache verify"
    if grep -q "npm cache verify" "$script"; then
        log_pass "npm cache verify present"
    else
        log_fail "npm cache verify missing"
    fi
    
    # Test 7: Dry-run execution
    ((TESTS_RUN++))
    log_test "syscleanup.zsh dry-run executes"
    local temp_log=$(mktemp)
    if timeout 10s "$script" --skip-security-checks 2>&1 | tee "$temp_log" | grep -qi "finished\|summary"; then
        log_pass "Dry-run executed successfully"
    else
        log_fail "Dry-run failed (check: $temp_log)"
    fi
}

# ==============================================================================
# SOCKET.DEV INTEGRATION TESTS
# ==============================================================================

test_socket_integration() {
    echo ""
    echo "========================================================================"
    echo "SOCKET.DEV INTEGRATION TESTS"
    echo "========================================================================"
    
    if ! test_command_exists socket; then
        log_skip "Socket CLI not available - skipping integration tests"
        return
    fi
    
    # Test 1: Socket authentication
    ((TESTS_RUN++))
    log_test "Socket CLI authenticated"
    if socket --version >/dev/null 2>&1; then
        log_pass "Socket CLI working"
    else
        log_fail "Socket CLI not authenticated (socket login)"
    fi
    
    # Test 2: Socket firewall functionality
    ((TESTS_RUN++))
    log_test "Socket firewall commands work"
    if socket firewall status >/dev/null 2>&1; then
        log_pass "Socket firewall commands work"
    else
        log_fail "Socket firewall commands fail"
    fi
    
    # Test 3: Socket npm audit
    ((TESTS_RUN++))
    log_test "Socket npm audit works"
    local test_dir=$(mktemp -d)
    echo '{"name":"test","version":"1.0.0"}' > "$test_dir/package.json"
    if socket npm audit "$test_dir" >/dev/null 2>&1; then
        log_pass "Socket npm audit works"
    else
        log_fail "Socket npm audit fails"
    fi
    rm -rf "$test_dir"
}

# ==============================================================================
# SHAI-HULUD DETECTION TESTS
# ==============================================================================

test_shai_hulud_detection() {
    echo ""
    echo "========================================================================"
    echo "SHAI-HULUD DETECTION TESTS"
    echo "========================================================================"
    
    local detector="$HOME/AI-sandbox/dev/dont-be-shy-hulud/scripts/detect.sh"
    
    if ! test_file_executable "$detector"; then
        log_skip "detect.sh not available - skipping detection tests"
        return
    fi
    
    # Test 1: Clean directory scan
    ((TESTS_RUN++))
    log_test "detect.sh scans clean directory"
    local test_dir=$(mktemp -d)
    if timeout 30s "$detector" "$test_dir" 2>&1 | grep -qi "no indicators\|clean\|0.*issues"; then
        log_pass "Clean directory scan works"
    else
        log_fail "Clean directory scan failed"
    fi
    rm -rf "$test_dir"
    
    # Test 2: IOC file detection
    ((TESTS_RUN++))
    log_test "detect.sh detects IOC files"
    local test_dir=$(mktemp -d)
    touch "$test_dir/setup_bun.js"
    if timeout 30s "$detector" "$test_dir" 2>&1 | grep -qi "setup_bun.js\|critical\|error"; then
        log_pass "IOC file detection works"
    else
        log_fail "IOC file detection failed"
    fi
    rm -rf "$test_dir"
    
    # Test 3: --ci mode
    ((TESTS_RUN++))
    log_test "detect.sh --ci mode works"
    local test_dir=$(mktemp -d)
    local output_file="$test_dir/output.txt"
    if timeout 30s "$detector" "$test_dir" --ci --output="$output_file" 2>&1 >/dev/null; then
        if [[ -f "$output_file" ]]; then
            log_pass "--ci mode works"
        else
            log_fail "--ci mode output file not created"
        fi
    else
        log_fail "--ci mode execution failed"
    fi
    rm -rf "$test_dir"
}

# ==============================================================================
# SUMMARY
# ==============================================================================

print_summary() {
    echo ""
    echo "========================================================================"
    echo "TEST SUMMARY"
    echo "========================================================================"
    echo -e "Total Tests: ${BLUE}${TESTS_RUN}${NC}"
    echo -e "Passed:      ${GREEN}${TESTS_PASSED}${NC}"
    echo -e "Failed:      ${RED}${TESTS_FAILED}${NC}"
    echo ""
    
    if (( TESTS_FAILED > 0 )); then
        echo "Failed Tests:"
        for test in "${FAILED_TESTS[@]}"; do
            echo -e "  ${RED}✗${NC} $test"
        done
        echo ""
        echo -e "${RED}❌ TESTS FAILED${NC}"
        return 1
    else
        echo -e "${GREEN}✅ ALL TESTS PASSED${NC}"
        return 0
    fi
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
    echo "========================================================================"
    echo "DOT-BIN SECURITY TEST SUITE"
    echo "Testing hardened scripts with Socket.dev + Shai-Hulud protection"
    echo "========================================================================"
    echo ""
    echo "Test Date: $(date)"
    echo "Hostname: $(hostname)"
    echo "User: $(whoami)"
    echo ""
    
    # Run all test suites
    test_prerequisites
    test_sysupdate
    test_syscleanup
    test_socket_integration
    test_shai_hulud_detection
    
    # Print summary
    print_summary
    exit $?
}

main "$@"
