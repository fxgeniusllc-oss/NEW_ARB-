import { ethers } from 'ethers';
import crypto from 'crypto';
import logger from '../utils/logger';
import { 
  ArbitrageOpportunity, 
  ExecutionPlan, 
  TransactionPayload, 
  SignedTransaction 
} from '../utils/types';
import { GasOptimizer } from '../utils/gasOptimizer';

export class TransactionBuilder {
  private wallet: ethers.Wallet;
  private provider: ethers.providers.JsonRpcProvider;
  private gasOptimizer: GasOptimizer;

  constructor(
    provider: ethers.providers.JsonRpcProvider,
    privateKey: string,
    gasOptimizer: GasOptimizer
  ) {
    this.provider = provider;
    this.wallet = new ethers.Wallet(privateKey, provider);
    this.gasOptimizer = gasOptimizer;
  }

  /**
   * Build execution plan from opportunity
   */
  async buildExecutionPlan(opportunity: ArbitrageOpportunity): Promise<ExecutionPlan> {
    logger.info('Building execution plan', { opportunityId: opportunity.id });

    // Select flashloan provider
    const flashloanProvider = this.selectFlashloanProvider(opportunity);
    
    // Build calldata for the arbitrage execution
    const calldata = this.buildCalldata(opportunity);
    
    // Get optimal gas parameters
    const gasPrice = await this.gasOptimizer.getOptimalGasPrice();
    const gasLimit = opportunity.gasEstimate;
    
    // Get current nonce
    let nonce: number;
    try {
      nonce = await this.wallet.getTransactionCount('pending');
    } catch (error) {
      logger.debug('Using default nonce 0 (network unavailable)', { error });
      nonce = 0;
    }
    
    // Set deadline (5 minutes from now)
    const deadline = Math.floor(Date.now() / 1000) + 300;

    const plan: ExecutionPlan = {
      opportunity,
      flashloanProvider,
      calldata,
      gasLimit,
      gasPrice: gasPrice.toString(),
      nonce,
      deadline
    };

    logger.info('Execution plan created', { 
      opportunityId: opportunity.id,
      flashloanProvider,
      gasPrice: ethers.utils.formatUnits(gasPrice, 'gwei')
    });

    return plan;
  }

  /**
   * Build transaction payload from execution plan
   */
  async buildTransactionPayload(plan: ExecutionPlan): Promise<TransactionPayload> {
    logger.info('Building transaction payload', { opportunityId: plan.opportunity.id });

    // Mock contract address for flashloan executor
    const flashloanExecutorAddress = '0x0000000000000000000000000000000000000001';

    let chainId: number;
    try {
      chainId = await this.provider.getNetwork().then(n => n.chainId);
    } catch (error) {
      logger.debug('Using default chainId 137 (network unavailable)', { error });
      chainId = 137;
    }

    const payload: TransactionPayload = {
      to: flashloanExecutorAddress,
      data: plan.calldata,
      value: '0',
      gasLimit: plan.gasLimit,
      gasPrice: plan.gasPrice,
      nonce: plan.nonce,
      chainId
    };

    logger.info('Transaction payload built', {
      to: payload.to,
      dataLength: payload.data.length,
      gasLimit: payload.gasLimit
    });

    return payload;
  }

  /**
   * Sign transaction payload
   */
  async signTransaction(payload: TransactionPayload): Promise<SignedTransaction> {
    logger.info('Signing transaction', { nonce: payload.nonce });

    try {
      const tx: ethers.providers.TransactionRequest = {
        to: payload.to,
        data: payload.data,
        value: ethers.BigNumber.from(payload.value),
        gasLimit: ethers.BigNumber.from(payload.gasLimit),
        gasPrice: ethers.BigNumber.from(payload.gasPrice),
        nonce: payload.nonce,
        chainId: payload.chainId
      };

      const signedTx = await this.wallet.signTransaction(tx);
      const txHash = ethers.utils.keccak256(signedTx);

      const signed: SignedTransaction = {
        payload,
        signature: signedTx.substring(0, 132), // Extract signature
        hash: txHash,
        rawTx: signedTx
      };

      logger.info('Transaction signed', { hash: signed.hash });

      return signed;
    } catch (error) {
      logger.error('Error signing transaction', { error });
      throw error;
    }
  }

  /**
   * Select best flashloan provider for opportunity
   */
  private selectFlashloanProvider(opportunity: ArbitrageOpportunity): string {
    // In a real implementation, this would analyze fees and availability
    const providers = ['Aave', 'Balancer', 'dYdX', 'Curve'];
    return providers[0]; // Default to Aave
  }

  /**
   * Build calldata for flashloan execution
   */
  private buildCalldata(opportunity: ArbitrageOpportunity): string {
    // Mock ABI encoding for flashloan execution
    // In a real implementation, this would use ethers.js contract interface
    
    const functionSelector = '0x1234abcd'; // Mock function selector
    const encodedParams = ethers.utils.defaultAbiCoder.encode(
      ['uint256', 'address[]', 'string[]'],
      [
        ethers.utils.parseEther(opportunity.inputAmount),
        opportunity.path,
        opportunity.dexes
      ]
    );

    return functionSelector + encodedParams.slice(2);
  }
}
