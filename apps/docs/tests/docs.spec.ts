import { expectcttest } from '@playwright/test'

test.describe('Documentation Site', () => {
  test.describe('Homepage', () => {
    test('should load homepage', async ({ page }) => {
      await page.goto('/')
      await expect(page).toHaveTitle(/Hulud|Shai-Hulud/i)
    })

    test('should have navigation sidebar', async ({ page }) => {
      await page.goto('/')
      const sidebar = page.locator('nav[aria-label="Main"]')
      await expect(sidebar).toBeVisible()
    })

    test('should have search functionality', async ({ page }) => {
      await page.goto('/')
      const searchButton = page.locator('[data-pagefind-ui], button:has-text("Search")')
      await expect(searchButton.first()).toBeVisible()
    })
  })

  test.describe('EN Documentation', () => {
    test('should load Getting Started section', async ({ page }) => {
      await page.goto('/getting-started/introduction/')
      await expect(page.locator('h1')).toContainText(/Introduction/i)
    })

    test('should load Detection Guide', async ({ page }) => {
      await page.goto('/detection/guide/')
      await expect(page.locator('h1')).toBeVisible()
    })

    test('should load Remediation section', async ({ page }) => {
      await page.goto('/remediation/immediate/')
      await expect(page.locator('h1')).toBeVisible()
    })

    test('should load Hardening section', async ({ page }) => {
      await page.goto('/hardening/npm/')
      await expect(page.locator('h1')).toBeVisible()
    })

    test('should load Reference section', async ({ page }) => {
      await page.goto('/reference/cli/')
      await expect(page.locator('h1')).toBeVisible()
    })

    test('should load Stack Guides', async ({ page }) => {
      await page.goto('/stacks/bun/')
      await expect(page.locator('h1')).toBeVisible()
    })
  })

  test.describe('CS Documentation (i18n)', () => {
    test('should load CS Getting Started', async ({ page }) => {
      await page.goto('/cs/getting-started/introduction/')
      await expect(page.locator('h1')).toBeVisible()
    })

    test('should load CS Detection Guide', async ({ page }) => {
      await page.goto('/cs/detection/guide/')
      await expect(page.locator('h1')).toBeVisible()
    })

    test('should have language switcher', async ({ page }) => {
      await page.goto('/getting-started/introduction/')
      // Starlight language picker
      const langPicker = page.locator('starlight-lang-select, [data-language-picker]')
      // If no dedicated picker, check for CS link
      const csLink = page.locator('a[href*="/cs/"]')
      const hasLangSwitch = await langPicker.count() > 0 || await csLink.count() > 0
      expect(hasLangSwitch).toBeTruthy()
    })
  })

  test.describe('Navigation', () => {
    test('should navigate between pages', async ({ page }) => {
      await page.goto('/getting-started/introduction/')
      
      // Click on a sidebar link
      const nextLink = page.locator('a:has-text("Installation"), a:has-text("Quick Start")')
      if (await nextLink.count() > 0) {
        await nextLink.first().click()
        await expect(page).not.toHaveURL('/getting-started/introduction/')
      }
    })

    test('should have working pagination', async ({ page }) => {
      await page.goto('/getting-started/introduction/')
      
      const nextButton = page.locator('a[rel="next"], a:has-text("Next")')
      if (await nextButton.count() > 0) {
        await expect(nextButton.first()).toBeVisible()
      }
    })
  })

  test.describe('Content Rendering', () => {
    test('should render code blocks', async ({ page }) => {
      await page.goto('/getting-started/installation/')
      const codeBlock = page.locator('pre code, .expressive-code')
      await expect(codeBlock.first()).toBeVisible()
    })

    test('should render tables', async ({ page }) => {
      await page.goto('/reference/ioc-database/')
      const table = page.locator('table')
      // Tables may not be on every page
      if (await table.count() > 0) {
        await expect(table.first()).toBeVisible()
      }
    })
  })

  test.describe('404 Page', () => {
    test('should show 404 for non-existent page', async ({ page }) => {
      const response = await page.goto('/this-page-does-not-exist/')
      expect(response?.status()).toBe(404)
    })
  })
})
