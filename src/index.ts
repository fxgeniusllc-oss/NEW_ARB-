import * as dotenv from 'dotenv';
import logger from './utils/logger';
import { E2EValidator } from './validate-e2e';

dotenv.config();

async function main() {
  logger.info('APEX Arbitrage System - End-to-End Validation');
  logger.info('');

  try {
    const validator = new E2EValidator();
    const results = await validator.runValidation();

    // Exit with appropriate code
    const hasFailures = results.some(r => !r.success);
    process.exit(hasFailures ? 1 : 0);

  } catch (error: any) {
    logger.error('Fatal error during validation', { error: error.message });
    process.exit(1);
  }
}

main();
