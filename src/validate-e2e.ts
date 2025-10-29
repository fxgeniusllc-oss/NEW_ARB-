import { ethers } from 'ethers';
import logger from './utils/logger';
import { config } from './config/config';
import { Scanner } from './services/scanner';
import { MLClient } from './services/mlClient';
import { TransactionBuilder } from './services/transactionBuilder';
import { TransactionBroadcaster } from './services/broadcaster';
import { GasOptimizer } from './utils/gasOptimizer';
import { ValidationResult, ArbitrageOpportunity, SignedTransaction } from './utils/types';

export class E2EValidator {
  private provider: ethers.providers.JsonRpcProvider;
  private scanner: Scanner;
  private mlClient: MLClient;
  private txBuilder: TransactionBuilder;
  private broadcaster: TransactionBroadcaster;
  private gasOptimizer: GasOptimizer;
  private results: ValidationResult[] = [];
  private useMockProvider: boolean = false;

  constructor() {
    logger.info('Initializing E2E Validator', { 
      rpcUrl: config.rpcUrl,
      mode: config.executionMode 
    });

    // Use mock provider in simulation mode if RPC is unavailable
    this.useMockProvider = config.executionMode === 'SIM';
    
    try {
      this.provider = new ethers.providers.JsonRpcProvider(config.rpcUrl);
    } catch (error) {
      logger.warn('Failed to connect to RPC, using mock provider', { error });
      this.useMockProvider = true;
      this.provider = new ethers.providers.JsonRpcProvider('http://localhost:8545');
    }
    
    this.gasOptimizer = new GasOptimizer(this.provider, config.maxGasPriceGwei);
    this.scanner = new Scanner(this.provider, config.minProfitUSD);
    this.mlClient = new MLClient(config.mlServerUrl);
    this.txBuilder = new TransactionBuilder(this.provider, config.privateKey, this.gasOptimizer);
    this.broadcaster = new TransactionBroadcaster(
      this.provider, 
      config.mevProtection, 
      config.executionMode
    );
  }

  /**
   * Run complete end-to-end validation
   */
  async runValidation(): Promise<ValidationResult[]> {
    logger.info('======================================');
    logger.info('Starting End-to-End Validation');
    logger.info('======================================');

    this.results = [];

    try {
      // Stage 1: Data Fetch
      await this.validateDataFetch();

      // Stage 2: Arbitrage Calculation & Opportunity Detection
      await this.validateOpportunityDetection();

      // Stage 3: ML Scoring
      await this.validateMLScoring();

      // Stage 4: Transaction Building & Signing
      await this.validateTransactionBuildingAndSigning();

      // Stage 5: MEV Protection
      await this.validateMEVProtection();

      // Stage 6: Transaction Broadcasting
      await this.validateBroadcasting();

      // Print summary
      this.printSummary();

    } catch (error: any) {
      logger.error('Validation failed', { error: error.message });
      this.addResult('OVERALL', false, 'Validation failed', undefined, error.message);
    }

    return this.results;
  }

  /**
   * Stage 1: Validate data fetching from DEX
   */
  private async validateDataFetch(): Promise<void> {
    logger.info('');
    logger.info('Stage 1: Data Fetch from DEX');
    logger.info('----------------------------');

    try {
      const tokenIn = '0x0000000000000000000000000000000000000001';
      const tokenOut = '0x0000000000000000000000000000000000000002';
      const amountIn = '1.0';

      const quotes = await this.scanner.fetchDEXQuotes(tokenIn, tokenOut, amountIn);

      if (quotes.length > 0) {
        this.addResult('DATA_FETCH', true, `Successfully fetched ${quotes.length} DEX quotes`, quotes);
        logger.info(`✅ Fetched ${quotes.length} quotes from DEXes`);
      } else {
        this.addResult('DATA_FETCH', false, 'No quotes fetched', quotes);
        logger.error('❌ No quotes fetched');
      }
    } catch (error: any) {
      this.addResult('DATA_FETCH', false, 'Data fetch failed', undefined, error.message);
      logger.error('❌ Data fetch failed', { error: error.message });
      throw error;
    }
  }

  /**
   * Stage 2: Validate arbitrage opportunity detection
   */
  private async validateOpportunityDetection(): Promise<void> {
    logger.info('');
    logger.info('Stage 2: Arbitrage Calculation & Opportunity Detection');
    logger.info('-----------------------------------------------------');

    try {
      const tokenIn = '0x0000000000000000000000000000000000000001';
      const tokenOut = '0x0000000000000000000000000000000000000002';
      const amountIn = '1.0';

      const quotes = await this.scanner.fetchDEXQuotes(tokenIn, tokenOut, amountIn);
      const opportunities = await this.scanner.detectOpportunities(quotes);

      if (opportunities.length > 0) {
        this.addResult('OPPORTUNITY_DETECTION', true, 
          `Detected ${opportunities.length} arbitrage opportunities`, 
          opportunities
        );
        logger.info(`✅ Detected ${opportunities.length} opportunities`);
        
        opportunities.forEach((opp: ArbitrageOpportunity, idx: number) => {
          logger.info(`  Opportunity ${idx + 1}: ${opp.expectedProfitUSD.toFixed(2)} USD profit`);
        });
      } else {
        this.addResult('OPPORTUNITY_DETECTION', false, 'No opportunities detected', opportunities);
        logger.warn('⚠️  No opportunities detected');
      }
    } catch (error: any) {
      this.addResult('OPPORTUNITY_DETECTION', false, 'Opportunity detection failed', undefined, error.message);
      logger.error('❌ Opportunity detection failed', { error: error.message });
      throw error;
    }
  }

  /**
   * Stage 3: Validate ML scoring
   */
  private async validateMLScoring(): Promise<void> {
    logger.info('');
    logger.info('Stage 3: ML Scoring');
    logger.info('-------------------');

    try {
      // Check ML server health
      const isHealthy = await this.mlClient.healthCheck();
      logger.info(`ML Server health: ${isHealthy ? '✅ Online' : '⚠️  Offline (using fallback)'}`);

      // Get a sample opportunity
      const tokenIn = '0x0000000000000000000000000000000000000001';
      const tokenOut = '0x0000000000000000000000000000000000000002';
      const quotes = await this.scanner.fetchDEXQuotes(tokenIn, tokenOut, '1.0');
      const opportunities = await this.scanner.detectOpportunities(quotes);

      if (opportunities.length === 0) {
        this.addResult('ML_SCORING', false, 'No opportunities to score');
        logger.warn('⚠️  No opportunities available for scoring');
        return;
      }

      const opportunity = opportunities[0];
      const prediction = await this.mlClient.scoreOpportunity(opportunity);

      this.addResult('ML_SCORING', true, 
        `ML scoring completed. Score: ${prediction.score.toFixed(3)}, Approved: ${prediction.approved}`,
        prediction
      );
      logger.info(`✅ ML Score: ${prediction.score.toFixed(3)}, Confidence: ${prediction.confidence.toFixed(3)}`);
      logger.info(`   Approved: ${prediction.approved ? 'YES' : 'NO'}`);

    } catch (error: any) {
      this.addResult('ML_SCORING', false, 'ML scoring failed', undefined, error.message);
      logger.error('❌ ML scoring failed', { error: error.message });
      throw error;
    }
  }

  /**
   * Stage 4: Validate transaction building and signing
   */
  private async validateTransactionBuildingAndSigning(): Promise<void> {
    logger.info('');
    logger.info('Stage 4: Transaction Payload Building & Signing');
    logger.info('-----------------------------------------------');

    try {
      // Get a sample opportunity
      const tokenIn = '0x0000000000000000000000000000000000000001';
      const tokenOut = '0x0000000000000000000000000000000000000002';
      const quotes = await this.scanner.fetchDEXQuotes(tokenIn, tokenOut, '1.0');
      const opportunities = await this.scanner.detectOpportunities(quotes);

      if (opportunities.length === 0) {
        this.addResult('TX_BUILDING', false, 'No opportunities to build transaction for');
        logger.warn('⚠️  No opportunities available');
        return;
      }

      const opportunity = opportunities[0];

      // Build execution plan
      const plan = await this.txBuilder.buildExecutionPlan(opportunity);
      logger.info('✅ Execution plan created');

      // Build transaction payload
      const payload = await this.txBuilder.buildTransactionPayload(plan);
      logger.info('✅ Transaction payload built');

      // Sign transaction
      const signedTx = await this.txBuilder.signTransaction(payload);
      logger.info('✅ Transaction signed');

      this.addResult('TX_BUILDING', true, 
        'Transaction successfully built and signed',
        { plan, payload, signedTx }
      );
      logger.info(`   TX Hash: ${signedTx.hash}`);

    } catch (error: any) {
      this.addResult('TX_BUILDING', false, 'Transaction building failed', undefined, error.message);
      logger.error('❌ Transaction building failed', { error: error.message });
      throw error;
    }
  }

  /**
   * Stage 5: Validate MEV protection
   */
  private async validateMEVProtection(): Promise<void> {
    logger.info('');
    logger.info('Stage 5: MEV Protection (Merkle Tree)');
    logger.info('-------------------------------------');

    try {
      if (!config.mevProtection.enabled) {
        this.addResult('MEV_PROTECTION', true, 'MEV protection disabled (skipped)');
        logger.info('⚠️  MEV protection is disabled');
        return;
      }

      // Get a sample signed transaction
      const tokenIn = '0x0000000000000000000000000000000000000001';
      const tokenOut = '0x0000000000000000000000000000000000000002';
      const quotes = await this.scanner.fetchDEXQuotes(tokenIn, tokenOut, '1.0');
      const opportunities = await this.scanner.detectOpportunities(quotes);
      const plan = await this.txBuilder.buildExecutionPlan(opportunities[0]);
      const payload = await this.txBuilder.buildTransactionPayload(plan);
      const signedTx = await this.txBuilder.signTransaction(payload);

      // Test MEV protection
      const { MEVProtection } = await import('./services/mevProtection');
      const mevProtection = new MEVProtection(config.mevProtection);
      const merkleData = mevProtection.buildMerkleTree([signedTx]);
      const protectedPayload = await mevProtection.prepareProtectedTransaction(signedTx, merkleData);

      this.addResult('MEV_PROTECTION', true, 
        `MEV protection configured for ${config.mevProtection.provider}`,
        { merkleData, protectedPayload }
      );
      logger.info(`✅ MEV protection configured: ${config.mevProtection.provider}`);
      logger.info(`   Merkle root: ${merkleData.root.substring(0, 20)}...`);
      logger.info(`   Endpoint: ${config.mevProtection.endpoint}`);

    } catch (error: any) {
      this.addResult('MEV_PROTECTION', false, 'MEV protection validation failed', undefined, error.message);
      logger.error('❌ MEV protection failed', { error: error.message });
      throw error;
    }
  }

  /**
   * Stage 6: Validate transaction broadcasting
   */
  private async validateBroadcasting(): Promise<void> {
    logger.info('');
    logger.info('Stage 6: Transaction Broadcasting to Blockchain');
    logger.info('-----------------------------------------------');

    try {
      // Get a complete signed transaction
      const tokenIn = '0x0000000000000000000000000000000000000001';
      const tokenOut = '0x0000000000000000000000000000000000000002';
      const quotes = await this.scanner.fetchDEXQuotes(tokenIn, tokenOut, '1.0');
      const opportunities = await this.scanner.detectOpportunities(quotes);
      const plan = await this.txBuilder.buildExecutionPlan(opportunities[0]);
      const payload = await this.txBuilder.buildTransactionPayload(plan);
      const signedTx = await this.txBuilder.signTransaction(payload);

      // Broadcast transaction
      const result = await this.broadcaster.broadcast(signedTx);

      if (result.success) {
        this.addResult('BROADCASTING', true, 
          `Transaction broadcast successful (Mode: ${config.executionMode})`,
          result
        );
        logger.info(`✅ Transaction broadcast successful`);
        logger.info(`   TX Hash: ${result.txHash}`);
        logger.info(`   Block: ${result.blockNumber || 'pending'}`);
        logger.info(`   Mode: ${config.executionMode}`);
      } else {
        this.addResult('BROADCASTING', false, 'Transaction broadcast failed', result);
        logger.error('❌ Transaction broadcast failed', { error: result.error });
      }

    } catch (error: any) {
      this.addResult('BROADCASTING', false, 'Broadcasting validation failed', undefined, error.message);
      logger.error('❌ Broadcasting failed', { error: error.message });
      throw error;
    }
  }

  /**
   * Add a validation result
   */
  private addResult(stage: string, success: boolean, message: string, data?: any, error?: string): void {
    this.results.push({
      stage,
      success,
      message,
      data,
      error,
      timestamp: Date.now()
    });
  }

  /**
   * Print validation summary
   */
  private printSummary(): void {
    logger.info('');
    logger.info('======================================');
    logger.info('End-to-End Validation Summary');
    logger.info('======================================');
    logger.info('');

    const passed = this.results.filter(r => r.success).length;
    const failed = this.results.filter(r => !r.success).length;

    this.results.forEach((result, idx) => {
      const icon = result.success ? '✅' : '❌';
      logger.info(`${idx + 1}. ${icon} ${result.stage}: ${result.message}`);
    });

    logger.info('');
    logger.info(`Total: ${this.results.length} | Passed: ${passed} | Failed: ${failed}`);
    logger.info('');

    if (failed === 0) {
      logger.info('🎉 All validation stages passed successfully!');
    } else {
      logger.warn(`⚠️  ${failed} validation stage(s) failed`);
    }

    logger.info('======================================');
  }
}
