# APEX Scripts Directory

This directory contains automation scripts for installing, running, and validating the APEX Arbitrage System.

## Available Scripts

### Installation and Startup

#### Linux/macOS
```bash
./install-and-run.sh
```

#### Windows
```batch
install-and-run.bat
```

**Description:** This script automates the complete installation and startup process:
- Checks for required prerequisites (Node.js, Python, Rust, Yarn)
- Installs all TypeScript dependencies via Yarn
- Installs Python dependencies from requirements.txt
- Builds Rust modules in release mode
- Starts the ML inference server
- Launches the TypeScript orchestrator

### System Validation

#### Linux/macOS
```bash
./validate-all.sh
```

#### Windows
```batch
validate-all.bat
```

**Description:** This script validates the entire system by:
- Checking project structure
- Running TypeScript tests
- Running Python tests (pytest)
- Running Rust tests (cargo test)
- Running integration tests

### ML Model Training

#### Linux/macOS/Windows
```bash
python scripts/train-ml-models.py
```
or
```bash
./scripts/train-ml-models.py
```

**Description:** This script bootstraps the machine learning model training process by:
- Locating the training script in python/model/train.py
- Running the training script
- Handling errors and providing feedback

## Prerequisites

Before running any scripts, ensure you have:

- **Node.js** >= 16.x
- **Python** >= 3.8
- **Rust** >= 1.70
- **Yarn** (will be auto-installed if missing)

## Notes

- On Linux/macOS, scripts must be made executable: `chmod +x script-name.sh`
- Windows batch files (.bat) can be run directly by double-clicking or from Command Prompt
- The install-and-run scripts will start services that may need to be manually stopped
- Always run validation scripts after making changes to ensure system integrity

## Troubleshooting

### Common Issues

**Script won't run on Linux/macOS:**
```bash
chmod +x scripts/*.sh
```

**Python command not found:**
- Make sure Python is installed and in your PATH
- On some systems, use `python3` instead of `python`

**Rust build fails:**
- Ensure Rust is properly installed: `rustc --version`
- Update Rust to the latest version: `rustup update`

**Yarn not found:**
- Install Yarn globally: `npm install -g yarn`
- Or the scripts will attempt to install it automatically
