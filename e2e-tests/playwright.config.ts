import { defineConfig, devices } from '@playwright/test';

/**
 * Playwright configuration for Spring Boot gRPC microservices testing
 * See https://playwright.dev/docs/test-configuration
 */
export default defineConfig({
  testDir: './tests',
  
  /* Run tests in files in parallel */
  fullyParallel: false,
  
  /* Fail the build on CI if you accidentally left test.only in the source code */
  forbidOnly: !!process.env.CI,
  
  /* Retry on CI only */
  retries: process.env.CI ? 2 : 0,
  
  /* Opt out of parallel tests on CI */
  workers: process.env.CI ? 1 : undefined,
  
  /* Reporter to use */
  reporter: [
    ['html', { outputFolder: 'test-results/html-report' }],
    ['json', { outputFile: 'test-results/results.json' }],
    ['list']
  ],
  
  /* Shared settings for all the projects below */
  use: {
    /* Base URL for API calls */
    baseURL: 'http://localhost',
    
    /* Collect trace when retrying the failed test */
    trace: 'on-first-retry',
    
    /* Screenshot on failure */
    screenshot: 'only-on-failure',
    
    /* Extra HTTP headers */
    extraHTTPHeaders: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }
  },

  /* Configure projects for different service endpoints */
  projects: [
    {
      name: 'order-service',
      use: { 
        ...devices['Desktop Chrome'],
        baseURL: 'http://localhost:8081'
      },
    },
    {
      name: 'payment-service',
      use: { 
        ...devices['Desktop Chrome'],
        baseURL: 'http://localhost:8082'
      },
    },
    {
      name: 'api-gateway',
      use: { 
        ...devices['Desktop Chrome'],
        baseURL: 'http://localhost:8080'
      },
    },
    {
      name: 'e2e-integration',
      use: { 
        ...devices['Desktop Chrome']
      },
    }
  ],

  /* Global timeout for each test */
  timeout: 30000,

  /* Timeout for expect() assertions */
  expect: {
    timeout: 5000
  },

  /* Web server configuration - not needed as services run in Docker */
  // webServer: {
  //   command: 'docker-compose up',
  //   url: 'http://localhost:8081/api/health',
  //   reuseExistingServer: !process.env.CI,
  // },
});
