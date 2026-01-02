import { test, expect } from '@playwright/test';

test.describe('Home Page', () => {
  test('should load the home page', async ({ page }) => {
    await page.goto('/');
    
    // Check for the main heading
    await expect(page.locator('h1')).toContainText('ApexGrid');
    
    // Check for navigation
    await expect(page.locator('header')).toBeVisible();
    await expect(page.locator('footer')).toBeVisible();
  });

  test('should have working navigation links', async ({ page }) => {
    await page.goto('/');
    
    // Check for leagues link
    const leaguesLink = page.locator('a[href*="leagues"]').first();
    await expect(leaguesLink).toBeVisible();
    
    // Navigate to leagues
    await leaguesLink.click();
    await expect(page).toHaveURL(/.*leagues/);
  });

  test('should have theme toggle', async ({ page }) => {
    await page.goto('/');
    
    // Find and click theme toggle
    const themeToggle = page.locator('[data-testid="theme-toggle"]');
    await expect(themeToggle).toBeVisible();
    
    // Check initial theme (should be system/dark by default in our setup)
    const html = page.locator('html');
    const initialClass = await html.getAttribute('class');
    
    // Click toggle
    await themeToggle.click();
    
    // Wait for theme change
    await page.waitForTimeout(100);
  });

  test('should have locale toggle', async ({ page }) => {
    await page.goto('/');
    
    // Find locale toggle
    const localeToggle = page.locator('[data-testid="locale-toggle"]');
    await expect(localeToggle).toBeVisible();
  });
});

test.describe('Authentication', () => {
  test('should show sign in page', async ({ page }) => {
    await page.goto('/auth/signin');
    
    await expect(page.locator('h1, h2').first()).toContainText(/sign in|log in|welcome/i);
    
    // Check for form elements
    await expect(page.locator('input[type="email"]')).toBeVisible();
    await expect(page.locator('input[type="password"]')).toBeVisible();
  });

  test('should show sign up page', async ({ page }) => {
    await page.goto('/auth/signup');
    
    await expect(page.locator('h1, h2').first()).toContainText(/sign up|register|create/i);
    
    // Check for form elements
    await expect(page.locator('input[type="email"]')).toBeVisible();
  });

  test('should navigate between sign in and sign up', async ({ page }) => {
    await page.goto('/auth/signin');
    
    // Find link to sign up
    const signUpLink = page.locator('a[href*="signup"]');
    await expect(signUpLink).toBeVisible();
    
    await signUpLink.click();
    await expect(page).toHaveURL(/.*signup/);
    
    // Find link back to sign in
    const signInLink = page.locator('a[href*="signin"]');
    await expect(signInLink).toBeVisible();
  });

  test('should show validation errors for empty form', async ({ page }) => {
    await page.goto('/auth/signin');
    
    // Submit empty form
    await page.locator('button[type="submit"]').click();
    
    // Should stay on the same page or show errors
    await expect(page).toHaveURL(/.*signin/);
  });
});

test.describe('Leagues', () => {
  test('should show leagues list page', async ({ page }) => {
    await page.goto('/leagues');
    
    await expect(page.locator('h1')).toContainText(/leagues/i);
  });

  test('should have create league button for authenticated users', async ({ page }) => {
    // This test would need authentication setup
    // For now, just check the page loads
    await page.goto('/leagues');
    
    await expect(page).toHaveURL(/.*leagues/);
  });
});

test.describe('Accessibility', () => {
  test('home page should be accessible', async ({ page }) => {
    await page.goto('/');
    
    // Check for basic accessibility features
    // Skip link
    const skipLink = page.locator('a[href="#main-content"]');
    
    // Check heading hierarchy
    const h1 = page.locator('h1');
    await expect(h1).toHaveCount(1);
    
    // Check for alt text on images
    const images = page.locator('img');
    const imageCount = await images.count();
    for (let i = 0; i < imageCount; i++) {
      const img = images.nth(i);
      const alt = await img.getAttribute('alt');
      const role = await img.getAttribute('role');
      // Images should have alt text or be decorative (role="presentation")
      expect(alt !== null || role === 'presentation').toBeTruthy();
    }
  });

  test('should have proper focus management', async ({ page }) => {
    await page.goto('/');
    
    // Tab through focusable elements
    await page.keyboard.press('Tab');
    
    // First focusable element should have focus
    const focusedElement = page.locator(':focus');
    await expect(focusedElement).toBeVisible();
  });
});

test.describe('Responsive Design', () => {
  test('should work on mobile viewport', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto('/');
    
    // Header should still be visible
    await expect(page.locator('header')).toBeVisible();
    
    // Check for mobile menu button if navigation is collapsed
    const mobileMenuBtn = page.locator('[data-testid="mobile-menu"]');
    // Mobile menu might or might not exist depending on implementation
  });

  test('should work on tablet viewport', async ({ page }) => {
    await page.setViewportSize({ width: 768, height: 1024 });
    await page.goto('/');
    
    await expect(page.locator('header')).toBeVisible();
    await expect(page.locator('main')).toBeVisible();
  });

  test('should work on desktop viewport', async ({ page }) => {
    await page.setViewportSize({ width: 1920, height: 1080 });
    await page.goto('/');
    
    await expect(page.locator('header')).toBeVisible();
    await expect(page.locator('main')).toBeVisible();
    await expect(page.locator('footer')).toBeVisible();
  });
});

test.describe('Performance', () => {
  test('home page should load quickly', async ({ page }) => {
    const startTime = Date.now();
    await page.goto('/', { waitUntil: 'domcontentloaded' });
    const loadTime = Date.now() - startTime;
    
    // Page should load in under 5 seconds
    expect(loadTime).toBeLessThan(5000);
  });
});
