import axios from 'axios';
import { ethers } from 'ethers';
import logger from '../utils/logger';
import { SignedTransaction, BroadcastResult, MEVProtectionConfig } from '../utils/types';
import { MEVProtection } from './mevProtection';

export class TransactionBroadcaster {
  private provider: ethers.providers.JsonRpcProvider;
  private mevProtection: MEVProtection;
  private executionMode: 'SIM' | 'LIVE';

  constructor(
    provider: ethers.providers.JsonRpcProvider,
    mevConfig: MEVProtectionConfig,
    executionMode: 'SIM' | 'LIVE'
  ) {
    this.provider = provider;
    this.mevProtection = new MEVProtection(mevConfig);
    this.executionMode = executionMode;
  }

  /**
   * Broadcast signed transaction to blockchain
   */
  async broadcast(signedTx: SignedTransaction): Promise<BroadcastResult> {
    logger.info('Broadcasting transaction', {
      hash: signedTx.hash,
      mode: this.executionMode,
      mevProtected: this.mevProtection['config'].enabled
    });

    // In simulation mode, don't actually broadcast
    if (this.executionMode === 'SIM') {
      return this.simulateBroadcast(signedTx);
    }

    try {
      let txHash: string;
      
      if (this.mevProtection['config'].enabled) {
        txHash = await this.broadcastWithMEVProtection(signedTx);
      } else {
        txHash = await this.broadcastStandard(signedTx);
      }

      // Wait for transaction receipt
      const receipt = await this.waitForReceipt(txHash);

      const result: BroadcastResult = {
        success: receipt.status === 1,
        txHash: receipt.transactionHash,
        timestamp: Date.now(),
        blockNumber: receipt.blockNumber
      };

      logger.info('Transaction broadcast successful', result);
      return result;

    } catch (error: any) {
      logger.error('Transaction broadcast failed', { error: error.message });
      
      return {
        success: false,
        error: error.message,
        timestamp: Date.now()
      };
    }
  }

  /**
   * Broadcast transaction with MEV protection
   */
  private async broadcastWithMEVProtection(signedTx: SignedTransaction): Promise<string> {
    logger.info('Broadcasting with MEV protection', {
      provider: this.mevProtection['config'].provider
    });

    const merkleData = this.mevProtection.buildMerkleTree([signedTx]);
    const protectedPayload = await this.mevProtection.prepareProtectedTransaction(
      signedTx,
      merkleData
    );

    const endpoint = this.mevProtection['config'].endpoint;

    try {
      const response = await axios.post(endpoint, protectedPayload, {
        headers: {
          'Content-Type': 'application/json'
        },
        timeout: 30000
      });

      logger.info('MEV-protected transaction submitted', { response: response.data });
      
      // Extract transaction hash from response
      return response.data.txHash || response.data.hash || signedTx.hash;

    } catch (error: any) {
      logger.error('MEV-protected broadcast failed', { error: error.message });
      throw error;
    }
  }

  /**
   * Broadcast transaction through standard RPC
   */
  private async broadcastStandard(signedTx: SignedTransaction): Promise<string> {
    logger.info('Broadcasting through standard RPC');

    const tx = await this.provider.sendTransaction(signedTx.rawTx);
    logger.info('Transaction submitted to mempool', { hash: tx.hash });
    
    return tx.hash;
  }

  /**
   * Wait for transaction receipt
   */
  private async waitForReceipt(txHash: string, timeout: number = 60000): Promise<ethers.providers.TransactionReceipt> {
    logger.info('Waiting for transaction receipt', { txHash });

    const startTime = Date.now();
    
    while (Date.now() - startTime < timeout) {
      try {
        const receipt = await this.provider.getTransactionReceipt(txHash);
        
        if (receipt) {
          logger.info('Transaction receipt received', {
            hash: txHash,
            blockNumber: receipt.blockNumber,
            status: receipt.status
          });
          return receipt;
        }
        
        // Wait 2 seconds before checking again
        await new Promise(resolve => setTimeout(resolve, 2000));
      } catch (error) {
        logger.warn('Error checking transaction receipt', { error });
      }
    }

    throw new Error(`Transaction receipt timeout after ${timeout}ms`);
  }

  /**
   * Simulate transaction broadcast (for testing)
   */
  private async simulateBroadcast(signedTx: SignedTransaction): Promise<BroadcastResult> {
    logger.info('Simulating transaction broadcast', { hash: signedTx.hash });

    // Simulate network delay
    await new Promise(resolve => setTimeout(resolve, 1000));

    // Simulate success with mock data
    const result: BroadcastResult = {
      success: true,
      txHash: signedTx.hash,
      timestamp: Date.now(),
      blockNumber: 12345678 // Mock block number
    };

    logger.info('Transaction simulation complete', result);
    return result;
  }
}
