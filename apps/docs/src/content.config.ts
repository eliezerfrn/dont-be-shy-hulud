import { defineCollection, z } from 'astro:content'
import { i18nLoader } from '@astrojs/starlight/loaders'
import { docsSchema, i18nSchema } from '@astrojs/starlight/schema'
import { glob } from 'astro/loaders'
import { dirname, join } from 'path'
import { fileURLToPath } from 'url'

// Get absolute path to docs-content package
const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)
const docsContentPath = join(__dirname, '../../../packages/docs-content')

const ctaSection = defineCollection({
  loader: glob({
    pattern: '**/*.{md,mdx}',
    base: 'src/content/sections',
  }),
  schema: z.object({
    title: z.string().optional(),
    description: z.string().optional(),
    enable: z.boolean().optional(),
    fill_button: z.object({
      label: z.string().optional(),
      link: z.string().optional(),
      enable: z.boolean().optional(),
    }),
    outline_button: z.object({
      label: z.string().optional(),
      link: z.string().optional(),
      enable: z.boolean().optional(),
    }),
  }),
})

// All docs content from packages/docs-content (root=EN, cs/=Czech)
export const collections = {
  docs: defineCollection({
    loader: glob({
      pattern: ['**/*.{md,mdx}', '!**/meta/**', '!package.json'],
      base: docsContentPath,
    }),
    schema: docsSchema(),
  }),
  i18n: defineCollection({ loader: i18nLoader(), schema: i18nSchema() }),
  ctaSection,
}
