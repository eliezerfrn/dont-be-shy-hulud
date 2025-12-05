#!/usr/bin/env bun
/**
 * Remove duplicate h1 headings from markdown files
 * Starlight displays the frontmatter title as h1, so we don't need # Title in content
 * Run: bun run scripts/remove-duplicate-h1.ts
 */

import { readdir, readFile, writeFile } from 'node:fs/promises'
import { join } from 'node:path'

const DOCS_DIR = 'packages/docs-content'

async function* walkDir(dir: string): AsyncGenerator<string> {
  const entries = await readdir(dir, { withFileTypes: true })
  for (const entry of entries) {
    const path = join(dir, entry.name)
    if (entry.isDirectory()) {
      yield* walkDir(path)
    } else if (entry.name.endsWith('.md') || entry.name.endsWith('.mdx')) {
      yield path
    }
  }
}

function extractTitle(content: string): string | null {
  const match = content.match(/^---\n[\s\S]*?title:\s*["']?([^"'\n]+)["']?[\s\S]*?\n---/)
  return match ? match[1].trim() : null
}

function removeDuplicateH1(content: string, title: string): string {
  // Match # Title at the start of content (after frontmatter)
  // The h1 might have slight variations (extra spaces, etc.)
  const h1Pattern = new RegExp(
    `^(---\\n[\\s\\S]*?\\n---\\n\\s*)#\\s*${escapeRegex(title)}\\s*\\n`,
    'm',
  )

  if (h1Pattern.test(content)) {
    return content.replace(h1Pattern, '$1')
  }

  // Also try without frontmatter match (simpler pattern)
  const lines = content.split('\n')
  const frontmatterEnd = lines.findIndex((line, i) => i > 0 && line === '---')

  if (frontmatterEnd > 0) {
    // Find first non-empty line after frontmatter
    for (let i = frontmatterEnd + 1; i < lines.length; i++) {
      const line = lines[i].trim()
      if (line === '') continue

      // Check if it's an h1 matching the title
      if (line.startsWith('# ')) {
        const h1Title = line.slice(2).trim()
        if (h1Title === title || h1Title.toLowerCase() === title.toLowerCase()) {
          lines.splice(i, 1)
          return lines.join('\n')
        }
      }
      break // Only check the first non-empty line
    }
  }

  return content
}

function escapeRegex(str: string): string {
  return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
}

async function main() {
  let processed = 0
  let modified = 0

  for await (const filePath of walkDir(DOCS_DIR)) {
    processed++
    const content = await readFile(filePath, 'utf-8')
    const title = extractTitle(content)

    if (!title) {
      console.log(`⚠️  No title found: ${filePath}`)
      continue
    }

    const newContent = removeDuplicateH1(content, title)

    if (newContent !== content) {
      await writeFile(filePath, newContent)
      console.log(`✅ Fixed: ${filePath}`)
      modified++
    }
  }

  console.log(`\n📊 Processed ${processed} files, modified ${modified}`)
}

main().catch(console.error)
