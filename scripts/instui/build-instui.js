#!/usr/bin/env node
//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

/*
yarn build-instui

Downloads design tokens from the instructure-ui repository (pinned to INSTUI_VERSION)
and generates the SwiftUI source files for the InstUI Swift package.

Generated files (DO NOT EDIT manually):

  Primitives:
  packages/InstUI/Sources/Primitive/Generated/InstUI.Primitive.Color.swift
  packages/InstUI/Sources/Primitive/Generated/InstUI.Primitive.Size.swift
  packages/InstUI/Sources/Primitive/Generated/InstUI.Primitive.FontWeight.swift
  packages/InstUI/Sources/Primitive/Generated/InstUI.Primitive.FontFamily.swift
  packages/InstUI/Sources/Primitive/Generated/InstUI.Primitive.Opacity.swift

  Semantic Swift types:
  packages/InstUI/Sources/Semantic/Generated/InstUI.Semantic.Color.swift
  packages/InstUI/Sources/Semantic/Generated/InstUI.Semantic.Size.swift
  packages/InstUI/Sources/Semantic/Generated/InstUI.Semantic.Spacing.swift
  packages/InstUI/Sources/Semantic/Generated/InstUI.Semantic.BorderRadius.swift
  packages/InstUI/Sources/Semantic/Generated/InstUI.Semantic.BorderWidth.swift
  packages/InstUI/Sources/Semantic/Generated/InstUI.Semantic.FontSize.swift
  packages/InstUI/Sources/Semantic/Generated/InstUI.Semantic.Opacity.swift
  packages/InstUI/Sources/Semantic/Generated/InstUI.Semantic.FontWeight.swift
  packages/InstUI/Sources/Semantic/Generated/InstUI.Semantic.FontFamily.swift

  Component Swift types (one file per component, sync'd from upstream):
  packages/InstUI/Sources/Component/Generated/InstUI.Component.<Name>.swift

  Component collector (generated from the component list):
  packages/InstUI/Sources/Component/Generated/InstUI.Theme.Components.swift

  Token values (bundled JSON):
  packages/InstUI/Resources/Tokens/Semantic/Color/rebrandLight.json
  packages/InstUI/Resources/Tokens/Semantic/Color/rebrandDark.json
  packages/InstUI/Resources/Tokens/Semantic/Layout/default.json
  packages/InstUI/Resources/Tokens/Component/<Name>.json

To update to a newer version of instructure-ui, bump INSTUI_VERSION below and re-run.
Components are sync'd automatically: the Generated/ directory is wiped and rebuilt on each
run, so any component removed upstream will also be removed from this repo.
*/

const https = require('https')
const fs = require('fs')
const path = require('path')
const buildPrimitivesConfig = require('./sd.config.primitives')
const buildSemanticConfig = require('./sd.config.semantic')
const { buildComponent: buildComponentConfig } = require('./sd.config.component')
const { buildIcons } = require('./build-icons')

const INSTUI_VERSION = 'v11.7.1'
const TOKENS_BASE_URL = `https://raw.githubusercontent.com/instructure/instructure-ui/${INSTUI_VERSION}/packages/ui-scripts/lib/build/tokensStudio`

const DOWNLOAD_TIMEOUT_MS = 30_000

function download(url) {
  return new Promise((resolve, reject) => {
    const req = https.get(url, res => {
      let data = ''
      res.on('data', chunk => { data += chunk })
      res.on('end', () => {
        if (res.statusCode !== 200) {
          reject(new Error(`HTTP ${res.statusCode} for ${url}`))
        } else {
          resolve(data)
        }
      })
      res.on('error', reject)
    })
    req.setTimeout(DOWNLOAD_TIMEOUT_MS, () => {
      req.destroy(new Error(`Timed out after ${DOWNLOAD_TIMEOUT_MS}ms: ${url}`))
    })
    req.on('error', reject)
  })
}

function apiGet(url) {
  return new Promise((resolve, reject) => {
    const req = https.get(url, { headers: { 'Accept': 'application/vnd.github.v3+json', 'User-Agent': 'build-instui' } }, res => {
      let data = ''
      res.on('data', chunk => { data += chunk })
      res.on('end', () => {
        if (res.statusCode !== 200) {
          reject(new Error(`GitHub API HTTP ${res.statusCode} for ${url}`))
        } else {
          resolve(JSON.parse(data))
        }
      })
      res.on('error', reject)
    })
    req.setTimeout(DOWNLOAD_TIMEOUT_MS, () => {
      req.destroy(new Error(`Timed out after ${DOWNLOAD_TIMEOUT_MS}ms: ${url}`))
    })
    req.on('error', reject)
  })
}

async function buildPrimitives() {
  const url = `${TOKENS_BASE_URL}/primitives/default.json`
  console.log('Downloading primitive tokens...')
  const primitives = JSON.parse(await download(url))
  console.log('Building SwiftUI primitives...')
  buildPrimitivesConfig(primitives).buildAllPlatforms()
}

async function buildSemantic() {
  console.log('Downloading semantic tokens...')
  const [light, dark, layout] = await Promise.all([
    download(`${TOKENS_BASE_URL}/rebrand/semantic/color/rebrandLight.json`),
    download(`${TOKENS_BASE_URL}/rebrand/semantic/color/rebrandDark.json`),
    download(`${TOKENS_BASE_URL}/rebrand/semantic/layout/default.json`),
  ])

  const resourcesDir = path.join(__dirname, '../../packages/InstUI/Resources')
  const tokensDir = path.join(resourcesDir, 'Tokens')

  const versionMarker = `InstUI_${INSTUI_VERSION.replace(/\./g, '_')}`
  for (const entry of fs.readdirSync(resourcesDir)) {
    if (entry.startsWith('InstUI_v') && entry !== versionMarker) {
      fs.rmSync(path.join(resourcesDir, entry))
      console.log(`Removed old version marker: ${entry}`)
    }
  }
  fs.writeFileSync(path.join(resourcesDir, versionMarker), '')

  const colorDir = path.join(tokensDir, 'Semantic', 'Color')
  const layoutDir = path.join(tokensDir, 'Semantic', 'Layout')
  fs.rmSync(tokensDir, { recursive: true, force: true })
  fs.mkdirSync(colorDir, { recursive: true })
  fs.mkdirSync(layoutDir, { recursive: true })
  fs.writeFileSync(path.join(colorDir, 'rebrandLight.json'), light)
  fs.writeFileSync(path.join(colorDir, 'rebrandDark.json'), dark)
  fs.writeFileSync(path.join(layoutDir, 'default.json'), layout)
  console.log(`Saved color + layout tokens to Resources/Tokens/Semantic/`)

  console.log('Building SwiftUI semantic types...')
  buildSemanticConfig(JSON.parse(light), JSON.parse(dark), JSON.parse(layout))
  return tokensDir
}

async function buildComponents(tokensDir) {
  const apiUrl = `https://api.github.com/repos/instructure/instructure-ui/contents/packages/ui-scripts/lib/build/tokensStudio/rebrand/component?ref=${INSTUI_VERSION}`
  console.log('Fetching component token file listing...')
  const entries = await apiGet(apiUrl)
  const jsonFiles = entries.filter(e => e.type === 'file' && e.name.endsWith('.json'))

  console.log(`Downloading ${jsonFiles.length} component token files...`)
  const downloads = await Promise.all(jsonFiles.map(e => download(e.download_url).then(text => ({ name: e.name, text }))))

  const componentDir = path.join(tokensDir, 'Component')
  fs.mkdirSync(componentDir, { recursive: true })
  for (const { name, text } of downloads) {
    fs.writeFileSync(path.join(componentDir, name), text)
  }
  console.log(`Saved ${downloads.length} component JSONs to Resources/${path.basename(tokensDir)}/Component/`)

  const outputDir = path.join(__dirname, '../../packages/InstUI/Sources/Component/Generated')
  console.log('Building SwiftUI component types...')
  buildComponentConfig(componentDir, outputDir)
  console.log(`Generated ${downloads.length} component Swift files.`)
}

async function main() {
  await buildIcons(INSTUI_VERSION)
  await buildPrimitives()
  const tokensDir = await buildSemantic()
  await buildComponents(tokensDir)
  console.log('Done.')
}

main().catch(err => {
  console.error(err)
  process.exit(1)
})
