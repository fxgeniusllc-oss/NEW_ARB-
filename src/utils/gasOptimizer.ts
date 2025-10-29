import { ethers } from 'ethers';
import logger from './logger';

export class GasOptimizer {
  private provider: ethers.providers.JsonRpcProvider;
  private maxGasPriceGwei: number;

  constructor(provider: ethers.providers.JsonRpcProvider, maxGasPriceGwei: number) {
    this.provider = provider;
    this.maxGasPriceGwei = maxGasPriceGwei;
  }

  async getOptimalGasPrice(): Promise<ethers.BigNumber> {
    try {
      const gasPrice = await this.provider.getGasPrice();
      const maxGasPrice = ethers.utils.parseUnits(this.maxGasPriceGwei.toString(), 'gwei');
      
      // Use the lower of current gas price or max configured
      const optimalGasPrice = gasPrice.gt(maxGasPrice) ? maxGasPrice : gasPrice;
      
      logger.info('Gas price calculated', {
        currentGwei: ethers.utils.formatUnits(gasPrice, 'gwei'),
        optimalGwei: ethers.utils.formatUnits(optimalGasPrice, 'gwei')
      });
      
      return optimalGasPrice;
    } catch (error) {
      logger.error('Error calculating optimal gas price', { error });
      throw error;
    }
  }

  async estimateGas(transaction: ethers.providers.TransactionRequest): Promise<ethers.BigNumber> {
    try {
      const gasEstimate = await this.provider.estimateGas(transaction);
      // Add 20% buffer for safety
      const gasWithBuffer = gasEstimate.mul(120).div(100);
      
      logger.debug('Gas estimate calculated', {
        estimate: gasEstimate.toString(),
        withBuffer: gasWithBuffer.toString()
      });
      
      return gasWithBuffer;
    } catch (error) {
      logger.error('Error estimating gas', { error });
      throw error;
    }
  }
}
