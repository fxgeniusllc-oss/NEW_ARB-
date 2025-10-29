import axios from 'axios';
import { ethers } from 'ethers';
import crypto from 'crypto';
import logger from '../utils/logger';
import { SignedTransaction, MEVProtectionConfig } from '../utils/types';

export class MEVProtection {
  private config: MEVProtectionConfig;

  constructor(config: MEVProtectionConfig) {
    this.config = config;
  }

  /**
   * Build Merkle tree for MEV protection
   */
  buildMerkleTree(transactions: SignedTransaction[]): { root: string; proof: string[] } {
    logger.info('Building Merkle tree', { txCount: transactions.length });

    if (!this.config.useMerkleTree) {
      return { root: '', proof: [] };
    }

    // Build Merkle tree from transaction hashes
    const leaves = transactions.map(tx => 
      ethers.utils.keccak256(ethers.utils.toUtf8Bytes(tx.hash))
    );

    const tree = this.buildTree(leaves);
    const root = tree[tree.length - 1][0];
    const proof = this.generateProof(leaves, 0, tree);

    logger.info('Merkle tree built', { root, proofLength: proof.length });

    return { root, proof };
  }

  /**
   * Prepare transaction for MEV-protected submission
   */
  async prepareProtectedTransaction(
    signedTx: SignedTransaction,
    merkleProof?: { root: string; proof: string[] }
  ): Promise<any> {
    logger.info('Preparing MEV-protected transaction', { 
      provider: this.config.provider,
      txHash: signedTx.hash
    });

    const payload: any = {
      rawTransaction: signedTx.rawTx,
      txHash: signedTx.hash
    };

    if (this.config.useMerkleTree && merkleProof) {
      payload.merkleRoot = merkleProof.root;
      payload.merkleProof = merkleProof.proof;
    }

    // Provider-specific formatting
    switch (this.config.provider) {
      case 'bloxroute':
        return this.formatForBloxRoute(payload);
      case 'quicknode':
        return this.formatForQuickNode(payload);
      case 'flashbots':
        return this.formatForFlashbots(payload);
      default:
        return payload;
    }
  }

  /**
   * Format transaction for BloxRoute
   */
  private formatForBloxRoute(payload: any): any {
    return {
      transaction: payload.rawTransaction,
      blockchain_network: 'polygon',
      mev_builders: {
        all: true
      },
      frontrunning_protection: true,
      ...(payload.merkleRoot && {
        merkle_root: payload.merkleRoot,
        merkle_proof: payload.merkleProof
      })
    };
  }

  /**
   * Format transaction for QuickNode
   */
  private formatForQuickNode(payload: any): any {
    return {
      method: 'eth_sendRawTransaction',
      params: [payload.rawTransaction],
      id: Date.now(),
      jsonrpc: '2.0',
      ...(payload.merkleRoot && {
        mev_protection: {
          merkle_root: payload.merkleRoot,
          merkle_proof: payload.merkleProof
        }
      })
    };
  }

  /**
   * Format transaction for Flashbots
   */
  private formatForFlashbots(payload: any): any {
    return {
      jsonrpc: '2.0',
      id: Date.now(),
      method: 'eth_sendBundle',
      params: [{
        txs: [payload.rawTransaction],
        blockNumber: ethers.utils.hexlify(0), // Will be set by caller
        ...(payload.merkleRoot && {
          merkleRoot: payload.merkleRoot,
          merkleProof: payload.merkleProof
        })
      }]
    };
  }

  /**
   * Build Merkle tree from leaves
   */
  private buildTree(leaves: string[]): string[][] {
    if (leaves.length === 0) return [[]];
    
    const tree: string[][] = [leaves];
    let currentLevel = leaves;

    while (currentLevel.length > 1) {
      const nextLevel: string[] = [];
      
      for (let i = 0; i < currentLevel.length; i += 2) {
        const left = currentLevel[i];
        const right = i + 1 < currentLevel.length ? currentLevel[i + 1] : left;
        const combined = ethers.utils.keccak256(
          ethers.utils.concat([left, right])
        );
        nextLevel.push(combined);
      }
      
      tree.push(nextLevel);
      currentLevel = nextLevel;
    }

    return tree;
  }

  /**
   * Generate Merkle proof for a leaf
   */
  private generateProof(leaves: string[], index: number, tree: string[][]): string[] {
    const proof: string[] = [];
    let currentIndex = index;

    for (let level = 0; level < tree.length - 1; level++) {
      const currentLevel = tree[level];
      const isRightNode = currentIndex % 2 === 1;
      const siblingIndex = isRightNode ? currentIndex - 1 : currentIndex + 1;

      if (siblingIndex < currentLevel.length) {
        proof.push(currentLevel[siblingIndex]);
      }

      currentIndex = Math.floor(currentIndex / 2);
    }

    return proof;
  }
}
