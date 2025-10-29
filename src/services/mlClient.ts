import axios from 'axios';
import logger from '../utils/logger';
import { ArbitrageOpportunity, MLPrediction } from '../utils/types';

export class MLClient {
  private serverUrl: string;

  constructor(serverUrl: string) {
    this.serverUrl = serverUrl;
  }

  /**
   * Send opportunity to ML server for scoring
   */
  async scoreOpportunity(opportunity: ArbitrageOpportunity): Promise<MLPrediction> {
    logger.info('Scoring opportunity with ML', { opportunityId: opportunity.id });
    
    try {
      // Extract features for ML model
      const features = this.extractFeatures(opportunity);
      
      const response = await axios.post(`${this.serverUrl}/predict`, {
        features,
        opportunity_id: opportunity.id
      }, {
        timeout: 5000
      });

      const prediction: MLPrediction = {
        score: response.data.score || 0.5,
        confidence: response.data.confidence || 0.5,
        features,
        approved: response.data.approved || false
      };

      logger.info('ML prediction received', { 
        opportunityId: opportunity.id,
        score: prediction.score,
        approved: prediction.approved
      });

      return prediction;
    } catch (error) {
      logger.warn('ML prediction failed, using fallback', { error });
      
      // Fallback: simple rule-based approval
      const features = this.extractFeatures(opportunity);
      const fallbackScore = opportunity.expectedProfitUSD > 10 ? 0.7 : 0.4;
      
      return {
        score: fallbackScore,
        confidence: 0.3,
        features,
        approved: fallbackScore > 0.6
      };
    }
  }

  /**
   * Extract numerical features from opportunity for ML model
   */
  private extractFeatures(opportunity: ArbitrageOpportunity): number[] {
    return [
      opportunity.expectedProfit,
      opportunity.expectedProfitUSD,
      parseFloat(opportunity.gasEstimate),
      parseFloat(opportunity.inputAmount),
      parseFloat(opportunity.outputAmount),
      opportunity.path.length,
      opportunity.dexes.length,
      Date.now() - opportunity.timestamp // Freshness
    ];
  }

  /**
   * Check if ML server is available
   */
  async healthCheck(): Promise<boolean> {
    try {
      const response = await axios.get(`${this.serverUrl}/health`, {
        timeout: 3000
      });
      return response.status === 200;
    } catch (error) {
      logger.warn('ML server health check failed', { error });
      return false;
    }
  }
}
