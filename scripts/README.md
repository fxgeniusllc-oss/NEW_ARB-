# APEX Scripts Directory

This directory contains automation scripts for auditing, testing, and maintaining the APEX Arbitrage System.

## Available Scripts

### 1. Integration Source Audit (`audit-integration.sh`)

**Purpose**: Comprehensive audit of the entire codebase to ensure quality, security, and compatibility.

**Usage**:
```bash
./scripts/audit-integration.sh
```

**What it checks**:
- ✅ Environment compatibility (Node.js ≥16.x, Python ≥3.8, Rust ≥1.70)
- ✅ Code structure and organization
- ✅ Security vulnerabilities
- ✅ Dependency management
- ✅ Test coverage
- ✅ Documentation completeness
- ✅ CI/CD configuration
- ✅ Git repository hygiene

**Output**: Generates detailed report in `./audit-reports/audit_<timestamp>.md`

**Exit codes**:
- `0`: All checks passed
- `1`: Passed with warnings
- `2`: Failed (critical issues)

---

### 2. Performance Benchmark (`performance-benchmark.sh`)

**Purpose**: Measure and track performance across all system components.

**Usage**:
```bash
./scripts/performance-benchmark.sh
```

**What it measures**:
- ⚡ TypeScript/Node.js startup and execution times
- ⚡ Python computation performance
- ⚡ Rust benchmark results
- ⚡ Build times for all components
- ⚡ Memory usage and resource utilization
- ⚡ Network latency

**Output**: Generates benchmark report in `./benchmark-results/benchmark_<timestamp>.md`

---

### 3. Pre-Commit Check (`pre-commit-check.sh`)

**Purpose**: Quick validation before committing code to catch common issues early.

**Usage**:
```bash
./scripts/pre-commit-check.sh
```

**What it checks**:
- 🔒 Security (no .env files, no hardcoded secrets)
- 🎨 Code formatting
- 📏 File sizes (warns about large files)
- 🧪 Test coverage (reminds to update tests)
- 📚 Documentation (suggests updates)
- 💬 Commit message guidelines

**Exit codes**:
- `0`: Ready to commit
- `1`: Issues found (fix before committing)

---

## Recommended Workflow

### Before Starting Development

1. Ensure environment is properly set up:
   ```bash
   node --version   # Should be ≥16.x
   python3 --version # Should be ≥3.8
   rustc --version   # Should be ≥1.70
   ```

### During Development

1. Make your code changes
2. Write or update tests
3. Update documentation if needed

### Before Committing

1. Run pre-commit check:
   ```bash
   ./scripts/pre-commit-check.sh
   ```

2. Fix any issues found

3. Stage your changes:
   ```bash
   git add .
   ```

4. Commit with descriptive message:
   ```bash
   git commit -m "feat: Your feature description"
   ```

### Before Creating PR

1. Run full integration audit:
   ```bash
   ./scripts/audit-integration.sh
   ```

2. Review audit report in `./audit-reports/`

3. Address any failures or warnings

4. Run performance benchmarks:
   ```bash
   ./scripts/performance-benchmark.sh
   ```

5. Verify no performance regressions

### Before Release

1. Run all audits and benchmarks
2. Verify all CI/CD checks pass
3. Review all documentation
4. Test in simulation mode
5. Get peer review approval

---

## Script Details

### Integration Audit Components

| Component | What it checks |
|-----------|---------------|
| Environment | Node.js, Python, Rust versions |
| TypeScript | package.json, tsconfig.json, source files |
| Python | requirements.txt, source files, tests |
| Rust | Cargo.toml, source files, tests |
| Security | No secrets, proper .gitignore, .env.example |
| Performance | Build configs, optimization flags |
| Documentation | README, docs directory, completeness |
| Tests | Test files, coverage, configuration |
| Dependencies | Lock files, version pinning |
| CI/CD | GitHub Actions, workflow configs |
| Git | File sizes, repository cleanliness |

### Performance Benchmark Metrics

| Metric | Target | Threshold |
|--------|--------|-----------|
| TypeScript Build | < 10s | < 30s |
| Rust Release Build | < 60s | < 180s |
| Python Startup | < 500ms | < 2s |
| Node.js Startup | < 200ms | < 1s |
| Memory Usage | < 70% | < 90% |

---

## Troubleshooting

### Script Won't Execute

```bash
# Make script executable
chmod +x scripts/audit-integration.sh
chmod +x scripts/performance-benchmark.sh
chmod +x scripts/pre-commit-check.sh
```

### Environment Checks Fail

```bash
# Install Node.js
nvm install 18

# Install Python
sudo apt-get install python3.10

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### Audit Reports Not Generated

```bash
# Ensure write permissions
chmod 755 .
mkdir -p audit-reports benchmark-results
```

---

## Integration with Git Hooks

### Setup Pre-Commit Hook

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
./scripts/pre-commit-check.sh
```

Make it executable:

```bash
chmod +x .git/hooks/pre-commit
```

### Setup Pre-Push Hook

Create `.git/hooks/pre-push`:

```bash
#!/bin/bash
echo "Running integration audit before push..."
./scripts/audit-integration.sh
```

Make it executable:

```bash
chmod +x .git/hooks/pre-push
```

---

## CI/CD Integration

These scripts are automatically run by GitHub Actions:

- **On every push**: Pre-commit checks, security scans
- **On every PR**: Full integration audit
- **Daily at 2 AM UTC**: Comprehensive audit and benchmarks
- **Manual trigger**: Available via workflow dispatch

View results in the **Actions** tab on GitHub.

---

## Contributing

When adding new scripts:

1. Follow the existing format and structure
2. Use colored output for readability
3. Include proper error handling
4. Document in this README
5. Make script executable: `chmod +x script.sh`
6. Test thoroughly before committing

---

## Support

For issues with these scripts:
1. Check the [Integration Audit Documentation](../docs/INTEGRATION_AUDIT.md)
2. Review the [QA Guide](../docs/QA_GUIDE.md)
3. Open a GitHub issue with the `scripts` label

---

**Last Updated**: 2025-10-29
**Maintainer**: APEX Development Team
