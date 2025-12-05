import { glob } from 'astro/loaders'
import { fileURLToPath } from 'url'
import { dirname, join } from 'path'

const __dirname = dirname(fileURLToPath(import.meta.url))
const rootDir = join(__dirname, '../..')

console.log('Current dir:', __dirname)
console.log('Root dir:', rootDir)
console.log('Packages dir:', join(rootDir, 'packages/docs-content/en'))
