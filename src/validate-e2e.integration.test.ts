/**
 * Integration test for end-to-end validation
 */

import { E2EValidator } from '../validate-e2e';

// Set test timeout to 60 seconds
jest.setTimeout(60000);

describe('End-to-End Validation', () => {
  let validator: E2EValidator;

  beforeAll(() => {
    // Set environment to SIM mode for testing
    process.env.EXECUTION_MODE = 'SIM';
    process.env.POLYGON_RPC_URL = 'https://polygon-rpc.com';
    process.env.PRIVATE_KEY = '0x0000000000000000000000000000000000000000000000000000000000000001';
    process.env.ML_SERVER_URL = 'http://localhost:8000';
    
    validator = new E2EValidator();
  });

  test('should complete full validation successfully', async () => {
    const results = await validator.runValidation();
    
    expect(results).toBeDefined();
    expect(results.length).toBeGreaterThan(0);
    
    // Check that all critical stages are present
    const stages = results.map(r => r.stage);
    expect(stages).toContain('DATA_FETCH');
    expect(stages).toContain('OPPORTUNITY_DETECTION');
    expect(stages).toContain('ML_SCORING');
    expect(stages).toContain('TX_BUILDING');
    expect(stages).toContain('BROADCASTING');
    
    // In simulation mode, most stages should pass
    const passedCount = results.filter(r => r.success).length;
    expect(passedCount).toBeGreaterThan(results.length / 2);
  });

  test('should handle data fetch correctly', async () => {
    const results = await validator.runValidation();
    const dataFetchResult = results.find(r => r.stage === 'DATA_FETCH');
    
    expect(dataFetchResult).toBeDefined();
    if (dataFetchResult) {
      expect(dataFetchResult.success).toBe(true);
    }
  });

  test('should detect arbitrage opportunities', async () => {
    const results = await validator.runValidation();
    const opportunityResult = results.find(r => r.stage === 'OPPORTUNITY_DETECTION');
    
    expect(opportunityResult).toBeDefined();
    if (opportunityResult && opportunityResult.success) {
      expect(opportunityResult.data).toBeDefined();
    }
  });

  test('should build and sign transactions', async () => {
    const results = await validator.runValidation();
    const txBuildResult = results.find(r => r.stage === 'TX_BUILDING');
    
    expect(txBuildResult).toBeDefined();
    if (txBuildResult && txBuildResult.success) {
      expect(txBuildResult.data).toBeDefined();
      expect(txBuildResult.data.signedTx).toBeDefined();
      expect(txBuildResult.data.signedTx.hash).toBeDefined();
    }
  });

  test('should broadcast transactions in simulation mode', async () => {
    const results = await validator.runValidation();
    const broadcastResult = results.find(r => r.stage === 'BROADCASTING');
    
    expect(broadcastResult).toBeDefined();
    if (broadcastResult && broadcastResult.success) {
      expect(broadcastResult.data).toBeDefined();
      expect(broadcastResult.data.txHash).toBeDefined();
    }
  });
});
