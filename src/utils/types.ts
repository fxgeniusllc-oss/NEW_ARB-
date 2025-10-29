// Shared TypeScript types for the APEX system

export interface DEXQuote {
  dex: string;
  tokenIn: string;
  tokenOut: string;
  amountIn: string;
  amountOut: string;
  price: number;
  gasEstimate: string;
  timestamp: number;
}

export interface ArbitrageOpportunity {
  id: string;
  path: string[];
  dexes: string[];
  expectedProfit: number;
  expectedProfitUSD: number;
  gasEstimate: string;
  inputAmount: string;
  outputAmount: string;
  timestamp: number;
  score?: number; // ML score from prediction
}

export interface ExecutionPlan {
  opportunity: ArbitrageOpportunity;
  flashloanProvider: string;
  calldata: string;
  gasLimit: string;
  gasPrice: string;
  nonce: number;
  deadline: number;
}

export interface TransactionPayload {
  to: string;
  data: string;
  value: string;
  gasLimit: string;
  gasPrice: string;
  nonce: number;
  chainId: number;
}

export interface SignedTransaction {
  payload: TransactionPayload;
  signature: string;
  hash: string;
  rawTx: string;
}

export interface BroadcastResult {
  success: boolean;
  txHash?: string;
  error?: string;
  timestamp: number;
  blockNumber?: number;
}

export interface MLPrediction {
  score: number;
  confidence: number;
  features: number[];
  approved: boolean;
}

export interface MEVProtectionConfig {
  enabled: boolean;
  provider: 'bloxroute' | 'quicknode' | 'flashbots';
  endpoint: string;
  useMerkleTree: boolean;
}

export interface SystemConfig {
  rpcUrl: string;
  privateKey: string;
  walletAddress: string;
  maxGasPriceGwei: number;
  minProfitUSD: number;
  mlServerUrl: string;
  executionMode: 'SIM' | 'LIVE';
  mevProtection: MEVProtectionConfig;
  chainId: number;
}

export interface ValidationResult {
  stage: string;
  success: boolean;
  message: string;
  data?: any;
  error?: string;
  timestamp: number;
}
