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
  packages/InstUI/Sources/Primitives/Generated/InstUI.Primitives.Colors.swift
  packages/InstUI/Sources/Primitives/Generated/InstUI.Primitives.Sizes.swift
  packages/InstUI/Sources/Primitives/Generated/InstUI.Primitives.FontWeights.swift
  packages/InstUI/Sources/Primitives/Generated/InstUI.Primitives.FontFamilies.swift
  packages/InstUI/Sources/Primitives/Generated/InstUI.Primitives.Opacities.swift

To update to a newer version of instructure-ui, bump INSTUI_VERSION below and re-run.
*/

const https = require('https')
const buildPrimitivesConfig = require('./sd.config.primitives')

const INSTUI_VERSION = 'v11.7.1'
const TOKENS_BASE_URL = `https://raw.githubusercontent.com/instructure/instructure-ui/${INSTUI_VERSION}/packages/ui-scripts/lib/build/tokensStudio`

function download(url) {
  return new Promise((resolve, reject) => {
    https.get(url, res => {
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
    }).on('error', reject)
  })
}

async function buildPrimitives() {
  const url = `${TOKENS_BASE_URL}/primitives/default.json`
  console.log('Downloading primitive tokens...')
  const primitives = JSON.parse(await download(url))
  console.log('Building SwiftUI primitives...')
  buildPrimitivesConfig(primitives).buildAllPlatforms()
}

async function main() {
  await buildPrimitives()
  console.log('Done.')
}

main().catch(err => {
  console.error(err)
  process.exit(1)
})
