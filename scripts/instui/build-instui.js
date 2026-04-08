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
Downloads design tokens from instructure-ui and generates SwiftUI primitives
for the InstUI Swift package.

Run from the repo root:
  yarn build-instui
*/

const https = require('https')
const buildConfig = require('./sd.config')

const TOKEN_URL = 'https://raw.githubusercontent.com/instructure/instructure-ui/v11.7.1/packages/ui-scripts/lib/build/tokensStudio/primitives/default.json'

function download(url) {
  return new Promise((resolve, reject) => {
    https.get(url, res => {
      let data = ''
      res.on('data', chunk => { data += chunk })
      res.on('end', () => resolve(data))
      res.on('error', reject)
    }).on('error', reject)
  })
}

async function main() {
  console.log('Downloading tokens from instructure-ui...')
  const json = await download(TOKEN_URL)
  const tokens = JSON.parse(json)

  console.log('Building SwiftUI primitives...')
  const sd = buildConfig(tokens)
  sd.buildAllPlatforms()

  console.log('Done.')
}

main().catch(err => {
  console.error(err)
  process.exit(1)
})
