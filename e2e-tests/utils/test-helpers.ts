/**
 * Test utilities and helper functions
 */

/**
 * Generate a unique test ID for isolation
 */
export function generateTestId(): string {
  return `test-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
}

/**
 * Generate test user ID
 */
export function generateUserId(): string {
  return `user-${generateTestId()}`;
}

/**
 * Generate test product ID
 */
export function generateProductId(): string {
  return `PROD-${Date.now()}-${Math.random().toString(36).substr(2, 5).toUpperCase()}`;
}

/**
 * Sleep/wait utility
 */
export async function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * Retry an async operation with exponential backoff
 */
export async function retryWithBackoff<T>(
  fn: () => Promise<T>,
  maxRetries: number = 5,
  initialDelay: number = 1000
): Promise<T> {
  let lastError: Error;
  
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error as Error;
      if (i < maxRetries - 1) {
        const delay = initialDelay * Math.pow(2, i);
        console.log(`Retry ${i + 1}/${maxRetries} after ${delay}ms`);
        await sleep(delay);
      }
    }
  }
  
  throw lastError!;
}

/**
 * Wait for a condition to be true
 */
export async function waitFor(
  condition: () => Promise<boolean>,
  timeoutMs: number = 30000,
  checkIntervalMs: number = 1000
): Promise<void> {
  const startTime = Date.now();
  
  while (Date.now() - startTime < timeoutMs) {
    if (await condition()) {
      return;
    }
    await sleep(checkIntervalMs);
  }
  
  throw new Error(`Condition not met within ${timeoutMs}ms`);
}

/**
 * Clean up test data (can be extended)
 */
export interface CleanupFunction {
  (): Promise<void>;
}

export class TestCleanup {
  private cleanupFunctions: CleanupFunction[] = [];
  
  register(fn: CleanupFunction): void {
    this.cleanupFunctions.push(fn);
  }
  
  async cleanup(): Promise<void> {
    for (const fn of this.cleanupFunctions.reverse()) {
      try {
        await fn();
      } catch (error) {
        console.error('Cleanup error:', error);
      }
    }
    this.cleanupFunctions = [];
  }
}
