# APEX System Architecture

## 🏗️ Architecture Overview

The system is built on a tri-core architecture:

- **Brain (Python)**: LSTM/Random Forest models for opportunity prediction
- **Nerve (TypeScript)**: Orchestration, routing, and coordination
- **Muscle (Rust)**: Ultra-fast transaction execution and mempool interaction

## Component Overview

| Layer | Language | Purpose |
|-------|----------|---------|
| `scanner.ts` | TypeScript | Feature extraction & AI prediction |
| `predictor.py` | Python | LSTM/RF model inference server |
| `executor.rs` | Rust | Ultra-fast tx execution via FFI |
| `router.ts` | TypeScript | Filters AI-approved routes into ExecutionPlan |

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

## 🚀 Features

- **Multi-chain Support**: Polygon, Ethereum, BSC, and more
- **ML-Powered**: Real-time opportunity scoring using trained neural networks
- **Flashloan Integration**: Balancer, Aave, Curve, and DODO protocols
- **High Performance**: Rust-based execution engine for minimal latency
- **Gas Optimization**: Dynamic gas pricing and transaction optimization
- **MEV Protection**: Optional Flashbots/Eden relay integration
