# APEX Arbitrage System

> Multi-chain, ML-guided, flashloan-powered MEV arbitrage execution architecture

## 🎯 Overview

APEX is a high-performance arbitrage system that combines machine learning prediction with ultra-low-latency transaction execution across multiple blockchain networks. The system uses TypeScript for orchestration, Python for AI/ML inference, and Rust for high-speed transaction execution.

## 🏗️ Architecture

The system is built on a tri-core architecture:

- **Brain (Python)**: LSTM/Random Forest models for opportunity prediction
- **Nerve (TypeScript)**: Orchestration, routing, and coordination
- **Muscle (Rust)**: Ultra-fast transaction execution and mempool interaction

### Component Overview

| Layer | Language | Purpose |
|-------|----------|---------|
| `scanner.ts` | TypeScript | Feature extraction & AI prediction |
| `predictor.py` | Python | LSTM/RF model inference server |
| `executor.rs` | Rust | Ultra-fast tx execution via FFI |
| `router.ts` | TypeScript | Filters AI-approved routes into ExecutionPlan |

## 🚀 Features

- **Multi-chain Support**: Polygon, Ethereum, BSC, and more
- **ML-Powered**: Real-time opportunity scoring using trained neural networks
- **Flashloan Integration**: Balancer, Aave, Curve, and DODO protocols
- **High Performance**: Rust-based execution engine for minimal latency
- **Gas Optimization**: Dynamic gas pricing and transaction optimization
- **MEV Protection**: Optional Flashbots/Eden relay integration

## 📋 Prerequisites

- Node.js >= 16.x
- Python >= 3.8
- Rust >= 1.70
- Yarn or npm

## 🔧 Installation

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

## ⚙️ Configuration

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

## 🎮 Usage

### Start ML Inference Server

```bash
cd python
python main.py
```

### Run Scanner in Simulation Mode

```bash
yarn start:sim
```

### Run Full System

```bash
# Terminal 1: Start Python ML server
cd python && python main.py

# Terminal 2: Run TypeScript orchestrator
yarn start
```

## 📁 Project Structure

```
APEX-ARBITRAGE-SYSTEM/
├── README.md
├── .env.example
├── package.json
├── Cargo.toml
├── tsconfig.json
├── yarn.lock
│
├── src/                            # TypeScript core
│   ├── core/
│   │   ├── scanner.ts              # DEX scan → AI score
│   │   ├── router.ts               # Filter/scored ops → execution plan
│   │   └── executor.ts             # Send to Rust → calldata dispatch
│   │
│   ├── config/
│   │   └── config.ts               # Global config (RPCs, wallets, thresholds)
│   │
│   ├── services/
│   │   ├── scanner.ts              # DEX quote fetcher
│   │   ├── executorBridge.ts       # Neon bridge to Rust executor
│   │   └── relayClient.ts          # Optional: external relay client
│   │
│   ├── utils/
│   │   ├── logger.ts               # Colored logging
│   │   ├── gasOptimizer.ts         # Dynamic gas pricing
│   │   └── types.ts                # Shared TypeScript types
│   │
│   └── index.ts                    # Main entrypoint
│
├── rust/                           # Rust for speed-critical ops
│   ├── src/
│   │   ├── lib.rs                  # Entry for Neon / FFI bridge
│   │   ├── types.rs                # ExecutionPlan, EncodedTx (shared)
│   │   ├── abi.rs                  # Encode calldata (flashloan, swaps)
│   │   ├── relay.rs                # Bundle + broadcast
│   │   └── executor.rs             # Flashloan pipeline executor
│
├── python/                         # Python AI Engine
│   ├── main.py                     # FastAPI inference server
│   ├── tx_engine.py                # Transaction execution engine
│   ├── model/
│   │   ├── lstm_omni.onnx          # Optimized ONNX model
│   │   ├── predictor.py            # Input → vector → ONNX inference
│   │   └── train.py                # Model trainer
│   │
│   └── utils/
│       └── preprocess.py           # Scaling + normalization
│
├── scripts/
│   ├── install-and-run.sh         # One-click launcher
│   ├── validate-all.sh            # End-to-end system check
│   └── train-ml-models.py         # Bootstraps model training
│
├── docs/
│   ├── APEX-SETUP.md
│   ├── MEV-STRATEGIES.md
│   ├── ARCHITECTURE.md
│   └── TERMINAL-DISPLAY.md
│
└── logs/
    └── system.log
```

## 🔄 Execution Flow

```
[scanner.ts] ─────> Fetch DEX data
      │
      ▼
[ML Server] ◄───── POST /predict (Python FastAPI, ONNX)
      │
      ▼
[router.ts] ─────> Build ranked execution plans
      │
      ▼
[executor.ts] ────> Send plans to execution engine
      │
      ▼
[Rust/Python] ────> Sign & broadcast transactions
```

## 🔐 Security Considerations

- Never commit private keys or sensitive credentials
- Use environment variables for all sensitive configuration
- Test thoroughly in simulation mode before live deployment
- Monitor gas prices and set appropriate limits
- Implement circuit breakers for risk management
- Use secure RPC endpoints
- Consider using MEV protection services (Flashbots, Eden)

## 🧪 Testing

```bash
# Run TypeScript tests
yarn test

# Run Python tests
cd python && pytest

# Run Rust tests
cd rust && cargo test

# Run integration tests
yarn test:integration
```

## 📊 Monitoring

The system includes built-in monitoring and logging:

- Real-time opportunity detection
- Transaction success/failure tracking
- Gas usage analytics
- Profit/loss reporting
- System health metrics

Logs are written to `logs/system.log` and can be monitored in real-time.

## 🚀 Deployment

### Development Mode

```bash
# Start all services
yarn dev
```

### Production Mode

```bash
# Build all components
yarn build
cd rust && cargo build --release

# Start production server
yarn start:prod
```

## 📚 Module Documentation

### TypeScript Core

- **scanner.ts**: Monitors DEX pools for arbitrage opportunities
- **router.ts**: Routes profitable opportunities through execution pipeline
- **executor.ts**: Handles transaction execution and monitoring

### Python AI Engine

- **main.py**: FastAPI server for ML inference
- **predictor.py**: LSTM/Random Forest prediction models
- **tx_engine.py**: Fallback transaction execution engine with modular components:
  - Opportunity ingestion from router
  - ABI payload encoding
  - Transaction building and signing
  - Broadcast engine with queue management
  - ML-based decision engine for approval

### Rust Execution

- **executor.rs**: High-speed transaction execution
- **abi.rs**: ABI encoding for smart contract calls
- **types.rs**: Shared data structures

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Submit a pull request

## ⚠️ Disclaimer

This software is provided for educational and research purposes only. Use at your own risk. The authors are not responsible for any financial losses incurred through the use of this software. Always test thoroughly in simulation mode before deploying with real funds.

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
