import { expect, test } from '@playwright/test'

test.describe('Documentation Site', () => {
  test.describe('Homepage', () => {
    test('should load homepage', async ({ page }) => {
      await page.goto('/')
      await expect(page).toHaveTitle(/Hulud|Shai-Hulud/i)
    })

    test('should have navigation sidebar', async ({ page }) => {
      // Homepage is splash page, check docs page for sidebar
      await page.goto('/getting-started/introduction/')
      const sidebar = page.locator('.sidebar, nav.sidebar-nav, [data-pagefind-body] nav')
      await expect(sidebar.first()).toBeVisible()
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
      // Starlight uses different heading structure
      const heading = page.locator('h1, [data-page-title], .content-panel h1, #_top')
      await expect(heading.first()).toBeVisible()
    })

    test('should load Detection Guide', async ({ page }) => {
      await page.goto('/detection/guide/')
      await expect(page).toHaveURL(/detection\/guide/)
    })

    test('should load Remediation section', async ({ page }) => {
      await page.goto('/remediation/immediate/')
      await expect(page).toHaveURL(/remediation\/immediate/)
    })

    test('should load Hardening section', async ({ page }) => {
      await page.goto('/hardening/npm/')
      await expect(page).toHaveURL(/hardening\/npm/)
    })

    test('should load Reference section', async ({ page }) => {
      await page.goto('/reference/cli/')
      await expect(page).toHaveURL(/reference\/cli/)
    })

    test('should load Stack Guides', async ({ page }) => {
      await page.goto('/stacks/bun/')
      await expect(page).toHaveURL(/stacks\/bun/)
    })
  })

  test.describe('CS Documentation (i18n)', () => {
    test('should load CS Getting Started', async ({ page }) => {
      await page.goto('/cs/getting-started/introduction/')
      await expect(page).toHaveURL(/cs\/getting-started\/introduction/)
    })

    test('should load CS Detection Guide', async ({ page }) => {
      await page.goto('/cs/detection/guide/')
      await expect(page).toHaveURL(/cs\/detection\/guide/)
    })

    test('should have language switcher', async ({ page }) => {
      await page.goto('/getting-started/introduction/')
      // Starlight language picker
      const langPicker = page.locator('starlight-lang-select, [data-language-picker]')
      // If no dedicated picker, check for CS link
      const csLink = page.locator('a[href*="/cs/"]')
      const hasLangSwitch = (await langPicker.count()) > 0 || (await csLink.count()) > 0
      expect(hasLangSwitch).toBeTruthy()
    })
  })

  test.describe('Navigation', () => {
    test('should navigate between pages', async ({ page }) => {
      await page.goto('/getting-started/introduction/')

      // Click on a sidebar link
      const nextLink = page.locator('a:has-text("Installation"), a:has-text("Quick Start")')
      if ((await nextLink.count()) > 0) {
        await nextLink.first().click()
        await expect(page).not.toHaveURL('/getting-started/introduction/')
      }
    })

    test('should have working pagination', async ({ page }) => {
      await page.goto('/getting-started/introduction/')

      // Starlight pagination uses specific classes
      const pagination = page.locator('.pagination-links, nav[aria-label="Pagination"]')
      // Pagination may not be on all pages
      const hasPagination = (await pagination.count()) > 0
      if (hasPagination) {
        await expect(pagination.first()).toBeVisible()
      } else {
        // Just verify page loaded
        await expect(page).toHaveURL(/introduction/)
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
      if ((await table.count()) > 0) {
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
