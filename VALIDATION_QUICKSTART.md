# End-to-End Validation System - Quick Start

## Overview

This validation system tests the complete arbitrage pipeline from data fetching to blockchain transaction broadcasting.

## Quick Test (Without Dependencies)

The fastest way to test the system:

```bash
# Build TypeScript
npm install
npm run build

# Run validation (simulation mode)
EXECUTION_MODE=SIM \
POLYGON_RPC_URL=https://polygon-rpc.com \
PRIVATE_KEY=0x0000000000000000000000000000000000000000000000000000000000000001 \
ML_SERVER_URL=http://localhost:8000 \
node dist/index.js
```

## Test with MEV Protection

```bash
EXECUTION_MODE=SIM \
POLYGON_RPC_URL=https://polygon-rpc.com \
PRIVATE_KEY=0x0000000000000000000000000000000000000000000000000000000000000001 \
ML_SERVER_URL=http://localhost:8000 \
USE_MEV_PROTECTION=true \
MEV_PROVIDER=bloxroute \
BLOXROUTE_URL=https://api.bloxroute.com/ \
USE_MERKLE_TREE=true \
node dist/index.js
```

## Full Test (With ML Server)

For complete testing with the ML inference server:

```bash
# Terminal 1: Start ML Server
cd python
pip install fastapi uvicorn numpy pydantic
python3 main.py

# Terminal 2: Run Validation
npm run build
npm run validate:e2e
```

## Validation Stages

The system validates 6 stages:

1. **Data Fetch from DEX** - Fetches quotes from multiple DEXes
2. **Arbitrage Calculation & Opportunity Detection** - Detects profitable opportunities
3. **ML Scoring** - Scores opportunities using AI/ML (with fallback)
4. **Transaction Payload Building & Signing** - Builds and signs transactions
5. **MEV Protection (Merkle Tree)** - Prepares MEV-protected payloads
6. **Transaction Broadcasting** - Broadcasts to blockchain (simulated)

## Expected Results

```
✅ DATA_FETCH: Successfully fetched 4 DEX quotes
✅ OPPORTUNITY_DETECTION: Detected 6 arbitrage opportunities
✅ ML_SCORING: ML scoring completed. Score: 0.700, Approved: true
✅ TX_BUILDING: Transaction successfully built and signed
✅ MEV_PROTECTION: MEV protection configured for bloxroute
✅ BROADCASTING: Transaction broadcast successful (Mode: SIM)

Total: 6 | Passed: 6 | Failed: 0
🎉 All validation stages passed successfully!
```

## Environment Variables

### Required
- `EXECUTION_MODE`: Set to `SIM` for testing
- `POLYGON_RPC_URL`: RPC endpoint (can be any URL in SIM mode)
- `PRIVATE_KEY`: Wallet private key (use test key for SIM mode)

### Optional
- `ML_SERVER_URL`: ML inference server URL (uses fallback if unavailable)
- `USE_MEV_PROTECTION`: Enable MEV protection testing
- `MEV_PROVIDER`: MEV provider (bloxroute, quicknode, flashbots)
- `BLOXROUTE_URL` / `QUICKNODE_URL`: Provider endpoints
- `USE_MERKLE_TREE`: Enable Merkle tree protection

## Simulation Mode

In `SIM` mode:
- No real transactions are sent to blockchain
- Network errors are gracefully handled with fallbacks
- All logic is validated without risk
- Perfect for development and testing

## Troubleshooting

### "Cannot find module" errors
```bash
npm install
npm run build
```

### ML Server unavailable
The system will use rule-based fallback scoring automatically.

### Network connection issues
In SIM mode, the system gracefully handles network issues and uses mock data.

## Next Steps

After validation passes:
1. Review the logs in `./logs/system.log`
2. Check the E2E_VALIDATION.md documentation for details
3. Configure real RPC endpoints and private keys for production
4. Set `EXECUTION_MODE=LIVE` only after thorough testing

## Documentation

- [E2E_VALIDATION.md](../docs/E2E_VALIDATION.md) - Complete documentation
- [ARCHITECTURE.md](../docs/ARCHITECTURE.md) - System architecture
- [DEPLOYMENT.md](../docs/DEPLOYMENT.md) - Deployment guide
