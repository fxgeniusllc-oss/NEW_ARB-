import * as dotenv from 'dotenv';
import { SystemConfig } from '../utils/types';

dotenv.config();

export function loadConfig(): SystemConfig {
  const config: SystemConfig = {
    rpcUrl: process.env.POLYGON_RPC_URL || process.env.ETHEREUM_RPC_URL || 'http://localhost:8545',
    privateKey: process.env.PRIVATE_KEY || '0x0000000000000000000000000000000000000000000000000000000000000000',
    walletAddress: process.env.WALLET_ADDRESS || '',
    maxGasPriceGwei: parseInt(process.env.MAX_GAS_PRICE_GWEI || '100'),
    minProfitUSD: parseFloat(process.env.MIN_PROFIT_USD || '5'),
    mlServerUrl: process.env.ML_SERVER_URL || 'http://localhost:8000',
    executionMode: (process.env.EXECUTION_MODE as 'SIM' | 'LIVE') || 'SIM',
    chainId: parseInt(process.env.CHAIN_ID || '137'), // Default to Polygon
    mevProtection: {
      enabled: process.env.USE_MEV_PROTECTION === 'true',
      provider: (process.env.MEV_PROVIDER as 'bloxroute' | 'quicknode' | 'flashbots') || 'bloxroute',
      endpoint: process.env.MEV_ENDPOINT || process.env.BLOXROUTE_URL || process.env.QUICKNODE_URL || '',
      useMerkleTree: process.env.USE_MERKLE_TREE === 'true'
    }
  };

  return config;
}

export const config = loadConfig();
