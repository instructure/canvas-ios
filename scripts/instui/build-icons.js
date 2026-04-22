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
Downloads and imports all SVG icons from instructure-ui into the InstUI Swift package.

Called by build-instui.js via buildIcons(version).

Outputs:
  packages/InstUI/Resources/Icons.xcassets/           — SVG asset catalog (cleared each run)
  packages/InstUI/Sources/Icon/Generated/InstUI.Icons.swift — Image.iui.* accessors
*/

const fs = require('fs')
const path = require('path')
const https = require('https')

const DOWNLOAD_TIMEOUT_MS = 30_000

function apiGet(url) {
  return new Promise((resolve, reject) => {
    const req = https.get(
      url,
      { headers: { Accept: 'application/vnd.github.v3+json', 'User-Agent': 'build-instui' } },
      res => {
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
      }
    )
    req.setTimeout(DOWNLOAD_TIMEOUT_MS, () => {
      req.destroy(new Error(`Timed out after ${DOWNLOAD_TIMEOUT_MS}ms: ${url}`))
    })
    req.on('error', reject)
  })
}

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

function toCamelCase(name) {
  const result = name.replace(/\W+(\w)/g, (_, c) => c.toUpperCase())
  return result.charAt(0).toLowerCase() + result.slice(1)
}

function capitalize(str) {
  return str.charAt(0).toUpperCase() + str.slice(1)
}

function transformSvg(svgSrc) {
  const svgTagAttrs = (svgSrc.match(/<svg([^>]*)>/) || ['', ''])[1]
  const viewBox = (svgTagAttrs.match(/\bviewBox="([^"]*)"/) || [])[1] ?? ''
  const svgFill = (svgTagAttrs.match(/\bfill="([^"]*)"/) || [])[1] ?? null
  const svgStroke = (svgTagAttrs.match(/\bstroke="([^"]*)"/) || [])[1] ?? null
  const iconColor = '#D852BE'
  const gFill = svgFill === 'none' ? 'none' : iconColor
  const gStrokeAttr = (svgStroke && svgStroke !== 'none') ? ` stroke="${iconColor}"` : ''
  let inner = svgSrc.replace(/<\/?svg[^>]*>/gi, '').trim()
  inner = inner.replace(/\bfill="(?!none")[^"]*"/g, `fill="${iconColor}"`)
  inner = inner.replace(/\bstroke="(?!none")[^"]*"/g, `stroke="${iconColor}"`)

  if (viewBox === '0 0 24 24') {
    return (
      `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">` +
      `<g fill="${gFill}"${gStrokeAttr}>${inner}</g></svg>`
    ).replace(/>\s+</, '><')
  }

  const scale = 20 / 1920
  return (
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">` +
    `<g fill="${gFill}"${gStrokeAttr} transform="matrix(${scale} 0 0 ${scale} 2 2)">` +
    `${inner}</g></svg>`
  ).replace(/>\s+</, '><')
}

function needsRTLMirror(name) {
  return /right|left|list|play|forward|reply|start|miniArrowEnd/i.test(name)
}

const fileHeader =
`//
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
//`

async function buildIcons(version) {
  const apiBase = `https://api.github.com/repos/instructure/instructure-ui/contents/packages/ui-icons/svg`
  const rawBase = `https://raw.githubusercontent.com/instructure/instructure-ui/${version}/packages/ui-icons/svg`

  const packageRoot = path.join(__dirname, '../../packages/InstUI')
  const xcassetsDir = path.join(packageRoot, 'Resources/Icons.xcassets')
  const generatedDir = path.join(packageRoot, 'Sources/Icon/Generated')

  console.log('Building InstUI icons...')
  fs.rmSync(xcassetsDir, { recursive: true, force: true })
  fs.mkdirSync(xcassetsDir, { recursive: true })
  fs.mkdirSync(generatedDir, { recursive: true })

  fs.writeFileSync(path.join(xcassetsDir, 'Contents.json'), JSON.stringify(
    { info: { author: 'xcode', version: 1 } },
    null, 2
  ) + '\n')

  console.log('Discovering icon subdirectories...')
  const rootEntries = await apiGet(`${apiBase}?ref=${version}`)
  const subdirs = rootEntries.filter(e => e.type === 'dir').map(e => e.name)
  console.log(`Found: ${subdirs.join(', ')}`)

  const icons = []
  for (const subdir of subdirs) {
    const entries = await apiGet(`${apiBase}/${subdir}?ref=${version}`)
    const suffix = capitalize(subdir)
    for (const entry of entries.filter(e => e.type === 'file' && e.name.endsWith('.svg'))) {
      const baseName = entry.name.slice(0, -4)
      const iconName = toCamelCase(baseName) + suffix
      icons.push({ name: iconName, url: `${rawBase}/${subdir}/${entry.name}` })
    }
  }

  console.log(`Downloading ${icons.length} icons...`)
  await Promise.all(icons.map(async ({ name, url }) => {
    const svgSrc = await download(url)
    const transformed = transformSvg(svgSrc)

    const imagesetDir = path.join(xcassetsDir, `${name}.imageset`)
    fs.mkdirSync(imagesetDir, { recursive: true })
    fs.writeFileSync(path.join(imagesetDir, `${name}.svg`), transformed)

    const imageEntry = {
      idiom: 'universal',
      filename: `${name}.svg`,
      ...(needsRTLMirror(name) ? { 'language-direction': 'left-to-right' } : {})
    }
    fs.writeFileSync(
      path.join(imagesetDir, 'Contents.json'),
      JSON.stringify({
        images: [imageEntry],
        info: { version: 1, author: 'xcode' },
        properties: {
          'template-rendering-intent': 'template',
          'preserves-vector-representation': true
        }
      }, null, 2) + '\n'
    )
  }))

  const sortedNames = icons.map(i => i.name).sort()
  const accessors = sortedNames
    .map(name => `    public static var ${name}: Image { Image("${name}", bundle: .module) }`)
    .join('\n')

  const allEntries = sortedNames
    .map(name => `        ("${name}", Image.iui.${name}),`)
    .join('\n')

  fs.writeFileSync(
    path.join(generatedDir, 'InstUI.Icons.swift'),
    `${fileHeader}

// DO NOT EDIT — Auto-generated by \`yarn build-instui\`

import SwiftUI

extension Image.iui {
${accessors}
}

extension Image.iui {
    internal static let all: [(name: String, image: Image)] = [
${allEntries}
    ]
}
`
  )

  console.log(`Generated ${sortedNames.length} icon accessors in InstUI.Icons.swift`)
}

module.exports = { buildIcons }
