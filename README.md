# APEX Arbitrage System

> Multi-chain, ML-guided, flashloan-powered MEV arbitrage execution architecture

## 🎯 Overview

APEX is a high-performance arbitrage system that combines machine learning prediction with ultra-low-latency transaction execution across multiple blockchain networks. The system uses TypeScript for orchestration, Python for AI/ML inference, and Rust for high-speed transaction execution.

### Key Features

- **Multi-chain Support**: Polygon, Ethereum, BSC, and more
- **ML-Powered**: Real-time opportunity scoring using trained neural networks
- **Flashloan Integration**: Balancer, Aave, Curve, and DODO protocols
- **High Performance**: Rust-based execution engine for minimal latency

## 📚 Documentation

For detailed information about the system, please refer to:

- **[Architecture](docs/ARCHITECTURE.md)** - System architecture, components, and execution flow
- **[Project Structure](docs/PROJECT_STRUCTURE.md)** - Detailed directory structure and component details
- **[Deployment](docs/DEPLOYMENT.md)** - Deployment, monitoring, testing, and security guidelines

## 🚀 Quick Start

### Prerequisites

- Node.js >= 16.x
- Python >= 3.8
- Rust >= 1.70
- Yarn or npm

### Installation

#### Automated Installation (Recommended)

**Linux/macOS:**
```bash
# Clone the repository
git clone https://github.com/fxgeniusllc-oss/NEW_ARB-.git
cd NEW_ARB-

# Run automated installation and startup
./scripts/install-and-run.sh
```

**Windows:**
```batch
# Clone the repository
git clone https://github.com/fxgeniusllc-oss/NEW_ARB-.git
cd NEW_ARB-

# Run automated installation and startup
scripts\install-and-run.bat
```

#### Manual Installation

```bash
# Clone the repository
git clone https://github.com/fxgeniusllc-oss/NEW_ARB-.git
cd NEW_ARB-

# Install TypeScript dependencies
yarn install

# Install Python dependencies
pip install -r python/requirements.txt

# Build Rust modules
cd rust && cargo build --release
```

### Configuration

Create a `.env` file in the root directory:

```env
# RPC Endpoints
POLYGON_RPC_URL=https://polygon-rpc.com
ETHEREUM_RPC_URL=https://eth-mainnet.alchemyapi.io/v2/YOUR-API-KEY

# Wallet Configuration
PRIVATE_KEY=your_private_key_here

# Gas Settings
MAX_GAS_PRICE_GWEI=100
MIN_PROFIT_USD=5

# ML Server
ML_SERVER_URL=http://localhost:8000

# Mode
EXECUTION_MODE=SIM  # Use 'LIVE' for production
```

### Running the System

#### Start ML Inference Server

```bash
cd python
python main.py
```

#### Run Scanner in Simulation Mode

```bash
yarn start:sim
```

#### Run Full System

```bash
# Terminal 1: Start Python ML server
cd python && python main.py

# Terminal 2: Run TypeScript orchestrator
yarn start
```

## 📝 License

[Insert License Information]

## 🔗 Resources

- [Flashloan Documentation](https://docs.aave.com/developers/guides/flash-loans)
- [MEV Protection](https://docs.flashbots.net/)
- [Ethers.js Documentation](https://docs.ethers.io/)
- [Web3.py Documentation](https://web3py.readthedocs.io/)

## 📞 Support

For issues and questions:
- Open an issue on GitHub
- Check existing documentation in `/docs`
- Review code comments for implementation details

## ⚠️ Important Notice

This software is provided for educational and research purposes only. Always test thoroughly in simulation mode before deploying with real funds. The authors are not responsible for any financial losses.

