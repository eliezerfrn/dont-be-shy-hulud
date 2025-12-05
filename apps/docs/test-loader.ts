import { glob } from 'astro/loaders'
import { dirname, join } from 'path'
import { fileURLToPath } from 'url'

const __dirname = dirname(fileURLToPath(import.meta.url))
const rootDir = join(__dirname, '../..')

console.log('Current dir:', __dirname)
console.log('Root dir:', rootDir)
console.log('Packages dir:', join(rootDir, 'packages/docs-content/en'))
