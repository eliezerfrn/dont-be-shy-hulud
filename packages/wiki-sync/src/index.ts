// packages/wiki-sync/src/index.ts

const CONTENT_DIR = '../docs-content'
const WIKI_DIR = '../../../dont-be-shy-hulud.wiki' // Wiki git repo

async function syncToWiki() {
  // 1. Read all markdown from docs-content
  // 2. Transform for Wiki format (capitalize, _Sidebar.md)
  // 3. Write to Wiki repo
  // 4. Git commit + push
}
