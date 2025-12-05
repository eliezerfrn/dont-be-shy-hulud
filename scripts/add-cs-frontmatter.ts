#!/usr/bin/env bun
/**
 * Script to add frontmatter to CS docs based on EN docs
 * Run: bun run scripts/add-cs-frontmatter.ts
 */

import { readdir, readFile, writeFile } from 'node:fs/promises'
import { join, relative } from 'node:path'

const EN_DIR = 'packages/docs-content/en'
const CS_DIR = 'packages/docs-content/cs'

// Czech translations for common terms
const translations: Record<string, string> = {
  'Detection Guide': 'Průvodce detekcí',
  'Common Issues & False Positives': 'Časté problémy a falešné poplachy',
  'macOS Detection': 'Detekce na macOS',
  Introduction: 'Úvod',
  Installation: 'Instalace',
  'Quick Start': 'Rychlý start',
  'Threat Overview': 'Přehled hrozby',
  'Immediate Response': 'Okamžitá reakce',
  'Cleanup Guide': 'Průvodce čištěním',
  'Credential Rotation': 'Rotace přihlašovacích údajů',
  'Remediation Guide': 'Průvodce nápravou',
  'npm Hardening': 'Zabezpečení npm',
  'GitHub Actions Security': 'Zabezpečení GitHub Actions',
  'GitHub Repository Security': 'Zabezpečení GitHub repozitáře',
  'CI/CD Security': 'Zabezpečení CI/CD',
  'Prevention Best Practices': 'Nejlepší postupy prevence',
  'Bun Security Guide': 'Průvodce zabezpečením Bun',
  'Monorepo Security': 'Zabezpečení Monorepa',
  'TypeScript & Astro Security': 'Zabezpečení TypeScript & Astro',
  'Expo & React Native Security': 'Zabezpečení Expo & React Native',
  'Rust, Go & Tauri Security': 'Zabezpečení Rust, Go & Tauri',
  'CLI Reference': 'Reference CLI',
  'Configuration Reference': 'Reference konfigurace',
  'IOC Database': 'Databáze IOC',
  'Socket.dev Case Study': 'Případová studie Socket.dev',
  'Release Workflow': 'Workflow vydání',
}

function translateTitle(enTitle: string): string {
  return translations[enTitle] || enTitle
}

function extractFrontmatter(content: string): { frontmatter: string; body: string } | null {
  const match = content.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/)
  if (!match) return null
  return { frontmatter: match[1], body: match[2] }
}

function parseFrontmatter(fm: string): Record<string, unknown> {
  const result: Record<string, unknown> = {}
  const lines = fm.split('\n')
  let currentKey = ''
  let currentIndent = 0
  let nestedObj: Record<string, unknown> = {}

  for (const line of lines) {
    const keyMatch = line.match(/^(\w+):\s*(.*)$/)
    if (keyMatch) {
      if (currentKey && Object.keys(nestedObj).length > 0) {
        result[currentKey] = nestedObj
        nestedObj = {}
      }
      currentKey = keyMatch[1]
      const value = keyMatch[2].trim()
      if (value) {
        result[currentKey] = value
        currentKey = ''
      }
      currentIndent = 0
    } else {
      const nestedMatch = line.match(/^\s+(\w+):\s*(.*)$/)
      if (nestedMatch && currentKey) {
        nestedObj[nestedMatch[1]] = nestedMatch[2].trim()
      }
    }
  }
  if (currentKey && Object.keys(nestedObj).length > 0) {
    result[currentKey] = nestedObj
  }

  return result
}

function buildFrontmatter(data: Record<string, unknown>, csTitle?: string): string {
  const lines: string[] = ['---']

  // Title (translated)
  const title = csTitle || translateTitle((data.title as string) || '')
  lines.push(`title: ${title}`)

  // Description (keep English or translate if available)
  if (data.description) {
    lines.push(`description: ${data.description}`)
  }

  // Sidebar
  if (data.sidebar && typeof data.sidebar === 'object') {
    lines.push('sidebar:')
    const sidebar = data.sidebar as Record<string, unknown>
    if (sidebar.order !== undefined) {
      lines.push(`  order: ${sidebar.order}`)
    }
    if (sidebar.badge && typeof sidebar.badge === 'object') {
      lines.push('  badge:')
      const badge = sidebar.badge as Record<string, string>
      if (badge.text) lines.push(`    text: ${badge.text}`)
      if (badge.variant) lines.push(`    variant: ${badge.variant}`)
    }
  }

  // Last updated
  if (data.lastUpdated) {
    lines.push(`lastUpdated: ${data.lastUpdated}`)
  }

  lines.push('---')
  return lines.join('\n')
}

async function* walkDir(dir: string): AsyncGenerator<string> {
  const entries = await readdir(dir, { withFileTypes: true })
  for (const entry of entries) {
    const path = join(dir, entry.name)
    if (entry.isDirectory()) {
      // Skip meta directory
      if (entry.name === 'meta') continue
      yield* walkDir(path)
    } else if (entry.name.endsWith('.md') || entry.name.endsWith('.mdx')) {
      // Skip index files
      if (entry.name === 'index.mdx' || entry.name === 'index.md') continue
      yield path
    }
  }
}

async function processFile(csPath: string) {
  const relativePath = relative(CS_DIR, csPath)
  const enPath = join(EN_DIR, relativePath)

  try {
    const [csContent, enContent] = await Promise.all([
      readFile(csPath, 'utf-8'),
      readFile(enPath, 'utf-8'),
    ])

    // Check if CS already has frontmatter
    if (csContent.startsWith('---')) {
      console.log(`⏭️  Skipping (has frontmatter): ${relativePath}`)
      return
    }

    // Extract EN frontmatter
    const enParsed = extractFrontmatter(enContent)
    if (!enParsed) {
      console.log(`⚠️  No EN frontmatter: ${relativePath}`)
      return
    }

    const enData = parseFrontmatter(enParsed.frontmatter)
    const csFrontmatter = buildFrontmatter(enData)

    // Add frontmatter to CS content
    const newContent = `${csFrontmatter}\n\n${csContent.trim()}\n`
    await writeFile(csPath, newContent)

    console.log(`✅ Added frontmatter: ${relativePath}`)
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === 'ENOENT') {
      console.log(`⚠️  No EN equivalent: ${relativePath}`)
    } else {
      console.error(`❌ Error processing ${relativePath}:`, error)
    }
  }
}

async function main() {
  console.log('🔄 Adding frontmatter to CS docs...\n')

  for await (const csPath of walkDir(CS_DIR)) {
    await processFile(csPath)
  }

  console.log('\n✨ Done!')
}

main().catch(console.error)
