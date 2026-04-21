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
Generates Swift files from component design token JSON files:

  packages/InstUI/Sources/Component/Generated/InstUI.Component.<Name>.swift
    — Heterogeneous public struct + build() for each component

Each component JSON file has a flat (occasionally nested) token tree under a
single root key. Token types are mixed — color, sizing, spacing, fontWeights,
etc. — so each struct has properties of different Swift types.

CSS-only token types (boxShadow, lineHeights, text, number, etc.) are pruned
and never appear in the generated output.
*/

const fs = require('fs')
const path = require('path')
const { fileHeader, isLeaf, genStructBlock, genInitLines } = require('./sd.config.shared')

// ---------------------------------------------------------------------------
// DTCG type mappings
// ---------------------------------------------------------------------------

// Maps DTCG token type → Swift type.
// Types absent here are CSS-only (boxShadow, lineHeights, text, etc.) and are skipped.
const DTCG_TO_SWIFT = {
  color:        'Color',
  sizing:       'CGFloat',
  spacing:      'CGFloat',
  borderRadius: 'CGFloat',
  borderWidth:  'CGFloat',
  fontSizes:    'CGFloat',
  opacity:      'Double',
  fontWeights:  'Font.Weight',
  fontFamilies: 'String',
}

// Swift type → parameter name used in the generated build() function
const SWIFT_TYPE_CLOSURE = {
  'Color':       'color',
  'CGFloat':     'dimension',
  'Double':      'opacity',
  'Font.Weight': 'fontWeight',
  'String':      'fontFamily',
}

// Swift type → required Swift import
const SWIFT_TYPE_IMPORT = {
  'Color':       'import SwiftUI',
  'CGFloat':     'import CoreGraphics',
  'Double':      'import Foundation',
  'Font.Weight': 'import SwiftUI',
  'String':      'import Foundation',
}

// ---------------------------------------------------------------------------
// Tree builder
// ---------------------------------------------------------------------------

// Like buildTree (semantic) but for component token JSON:
//   - Carries swiftType on each leaf (derived from DTCG "type" field)
//   - Prunes leaves whose DTCG type has no Swift equivalent (CSS-only tokens)
//   - Prunes numeric leaves whose values are CSS shorthands (multi-part strings)
//   - Prunes nodes that become empty after pruning
function buildComponentTree(obj, path = '') {
  if (isLeaf(obj)) {
    const swiftType = DTCG_TO_SWIFT[obj.type]
    if (!swiftType) return null
    // Prune numeric tokens whose values can't be resolved to a scalar CGFloat/Double:
    //   - CSS shorthands (multi-value strings with spaces, e.g. "0 0 0.5rem 0")
    //   - CSS percentage values (context-relative, e.g. "50%")
    if ((swiftType === 'CGFloat' || swiftType === 'Double') &&
        typeof obj.value === 'string' &&
        !obj.value.startsWith('{') &&
        (obj.value.includes(' ') || obj.value.includes('%'))) {
      console.warn(`  ⚠ Skipped "${path}" (${obj.type}): CSS value not representable as ${swiftType}: "${obj.value}"`)
      return null
    }
    return { type: 'leaf', swiftType }
  }
  if (typeof obj !== 'object' || obj === null) return null
  const children = {}
  for (const [k, v] of Object.entries(obj)) {
    if (typeof v === 'object' && v !== null) {
      const child = buildComponentTree(v, path ? `${path}.${k}` : k)
      if (child !== null) children[k] = child
    }
  }
  if (Object.keys(children).length === 0) return null
  return { type: 'node', children }
}

// Returns the sorted list of distinct Swift types present in a component tree.
function collectSwiftTypes(tree) {
  const types = new Set()
  function walk(node) {
    if (node.type === 'leaf') { types.add(node.swiftType); return }
    for (const child of Object.values(node.children)) walk(child)
  }
  walk(tree)
  return [...types].sort()
}

// ---------------------------------------------------------------------------
// File generator
// ---------------------------------------------------------------------------

// Generates a single `InstUI.Component.<typeName>.swift` containing:
//   • A heterogeneous public struct (leaf Swift types derived from DTCG "type" field)
//   • A static build() with one typed closure parameter per Swift type present
//   • A static load(using:) that loads the component from the bundle using ComponentResolver
function generateComponentFile({ typeName, tree, fileResource, rootKey }) {
  const swiftTypes = collectSwiftTypes(tree)
  const imports = [...new Set(['import Foundation', ...swiftTypes.map(t => SWIFT_TYPE_IMPORT[t])])].sort()
  const getClosure = swiftType => SWIFT_TYPE_CLOSURE[swiftType]

  const lines = []
  lines.push(fileHeader)
  lines.push('')
  lines.push(...imports)
  lines.push('')
  lines.push("// DO NOT EDIT — Auto-generated by `yarn build-instui`")

  lines.push('extension InstUI.Component {')
  lines.push('')
  lines.push(genStructBlock(typeName, tree, 1, null))
  lines.push('}')
  lines.push('')

  const closureParams = swiftTypes
    .map(t => `        ${SWIFT_TYPE_CLOSURE[t]}: (InstUI.TokenKey) throws -> ${t}`)
    .join(',\n')
  lines.push(`extension InstUI.Component.${typeName} {`)
  lines.push('')
  lines.push(`    static func build(`)
  lines.push(closureParams)
  lines.push(`    ) throws -> InstUI.Component.${typeName} {`)

  const retLines = [`        try InstUI.Component.${typeName}(`]
  const entries = Object.entries(tree.children)
  for (let i = 0; i < entries.length; i++) {
    const [key, child] = entries[i]
    const isLast = i === entries.length - 1
    if (child.type === 'leaf') {
      retLines.push(`            ${key}: ${getClosure(child.swiftType)}("${key}")${isLast ? '' : ','}`)
    } else {
      const subLines = genInitLines(child, key, 3, getClosure)
      retLines.push(`            ${key}: ${subLines[0].trimStart()}`)
      for (let j = 1; j < subLines.length - 1; j++) retLines.push(subLines[j])
      retLines.push(subLines[subLines.length - 1] + (isLast ? '' : ','))
    }
  }
  retLines.push('        )')
  lines.push(...retLines)
  lines.push('    }')
  lines.push('}')
  lines.push('')

  // load(using:) extension
  const loadClosureArgs = swiftTypes
    .map(t => `            ${SWIFT_TYPE_CLOSURE[t]}: resolver.${SWIFT_TYPE_CLOSURE[t]}`)
    .join(',\n')
  lines.push(`extension InstUI.Component.${typeName} {`)
  lines.push('')
  lines.push(`    static func load(using theme: InstUI.Theme) throws -> Self {`)
  lines.push(`        guard let url = Bundle.module.url(forResource: "${fileResource}", withExtension: "json") else {`)
  lines.push(`            throw InstUI.TokenLoadError.missingFile("${fileResource}.json not found in bundle")`)
  lines.push(`        }`)
  lines.push(`        let data = try Data(contentsOf: url)`)
  lines.push(`        let leaves = try InstUI.TokenExtractor.extractLeaves(from: data, section: "${rootKey}")`)
  lines.push(`        let resolver = InstUI.ComponentResolver(theme: theme, leaves: leaves)`)
  lines.push(`        return try .build(`)
  lines.push(loadClosureArgs)
  lines.push(`        )`)
  lines.push(`    }`)
  lines.push(`}`)
  lines.push('')
  return lines.join('\n')
}

// ---------------------------------------------------------------------------
// Theme.Components collector generator
// ---------------------------------------------------------------------------

// Generates `InstUI.Theme.Components.swift` — a single struct that holds one instance
// of every component token type and provides a batch load() factory.
function generateThemeComponentsFile(components, outputDir) {
  const semanticParams = [
    'colors: InstUI.Semantic.Color',
    'size: InstUI.Semantic.Size',
    'spacing: InstUI.Semantic.Spacing',
    'borderRadius: InstUI.Semantic.BorderRadius',
    'borderWidth: InstUI.Semantic.BorderWidth',
    'fontSize: InstUI.Semantic.FontSize',
    'opacity: InstUI.Semantic.Opacity',
    'fontWeights: InstUI.Semantic.FontWeight',
    'fontFamilies: InstUI.Semantic.FontFamily',
  ]
  const baseResolverArgs = [
    'colors: colors',
    'size: size',
    'spacing: spacing',
    'borderRadius: borderRadius',
    'borderWidth: borderWidth',
    'fontSize: fontSize',
    'opacity: opacity',
    'fontWeights: fontWeights',
    'fontFamilies: fontFamilies',
    'leaves: [:]',
  ]

  const lines = []
  lines.push(fileHeader)
  lines.push('')
  lines.push('import CoreGraphics')
  lines.push('import Foundation')
  lines.push('import SwiftUI')
  lines.push('')
  lines.push("// DO NOT EDIT — Auto-generated by `yarn build-instui`")
  lines.push('// swiftlint:disable function_body_length')
  lines.push('')

  // Struct definition
  lines.push('extension InstUI.Theme {')
  lines.push('')
  lines.push('    public struct Components: Sendable {')
  for (const { typeName, propName } of components) {
    lines.push(`        public let ${propName}: InstUI.Component.${typeName}`)
  }
  lines.push('    }')
  lines.push('}')
  lines.push('')

  // Loader extensions
  lines.push('extension InstUI.Theme.Components {')
  lines.push('')

  // Designated load — takes individual semantic values to avoid circular Theme init dependency
  lines.push('    static func load(')
  for (let i = 0; i < semanticParams.length; i++) {
    const isLast = i === semanticParams.length - 1
    lines.push(`        ${semanticParams[i]}${isLast ? '' : ','}`)
  }
  lines.push('    ) throws -> Self {')

  // Build one base resolver — lookup maps are expensive to build and shared across all components
  lines.push('        let base = InstUI.ComponentResolver(')
  for (let i = 0; i < baseResolverArgs.length; i++) {
    const isLast = i === baseResolverArgs.length - 1
    lines.push(`            ${baseResolverArgs[i]}${isLast ? '' : ','}`)
  }
  lines.push('        )')

  // Nested helper function that reuses the base resolver's pre-built lookup maps
  lines.push('        func resolveComponent<T>(')
  lines.push('            _ resource: String,')
  lines.push('            _ section: String,')
  lines.push('            _ build: (InstUI.ComponentResolver) throws -> T')
  lines.push('        ) throws -> T {')
  lines.push('            guard let url = Bundle.module.url(forResource: resource, withExtension: "json") else {')
  lines.push('                throw InstUI.TokenLoadError.missingFile("\\(resource).json not found in bundle")')
  lines.push('            }')
  lines.push('            let data = try Data(contentsOf: url)')
  lines.push('            let leaves = try InstUI.TokenExtractor.extractLeaves(from: data, section: section)')
  lines.push('            return try build(base.withLeaves(leaves))')
  lines.push('        }')
  lines.push('')

  // Per-component load lines
  for (const { typeName, propName, fileResource, rootKey, swiftTypes } of components) {
    const buildArgs = swiftTypes.map(t => `${SWIFT_TYPE_CLOSURE[t]}: resolver.${SWIFT_TYPE_CLOSURE[t]}`).join(', ')
    lines.push(`        let ${propName} = try resolveComponent("${fileResource}", "${rootKey}") { resolver in`)
    lines.push(`            try InstUI.Component.${typeName}.build(${buildArgs})`)
    lines.push(`        }`)
  }
  lines.push('')

  // Return Self initializer
  lines.push('        return Self(')
  for (let i = 0; i < components.length; i++) {
    const { propName } = components[i]
    const isLast = i === components.length - 1
    lines.push(`            ${propName}: ${propName}${isLast ? '' : ','}`)
  }
  lines.push('        )')
  lines.push('    }')
  lines.push('')

  // Convenience overload that accepts a full Theme (for external/test use)
  lines.push('    static func load(using theme: InstUI.Theme) throws -> Self {')
  lines.push('        try load(')
  lines.push('            colors: theme.colors,')
  lines.push('            size: theme.size,')
  lines.push('            spacing: theme.spacing,')
  lines.push('            borderRadius: theme.borderRadius,')
  lines.push('            borderWidth: theme.borderWidth,')
  lines.push('            fontSize: theme.fontSize,')
  lines.push('            opacity: theme.opacity,')
  lines.push('            fontWeights: theme.fontWeights,')
  lines.push('            fontFamilies: theme.fontFamilies')
  lines.push('        )')
  lines.push('    }')
  lines.push('}')
  lines.push('')

  fs.writeFileSync(
    path.join(outputDir, 'InstUI.Theme.Components.swift'),
    lines.join('\n')
  )
}

// ---------------------------------------------------------------------------
// Module export
// ---------------------------------------------------------------------------

module.exports = {
  buildComponentTree,
  generateComponentFile,
  generateThemeComponentsFile,
  buildComponent: function buildComponent(componentDir, outputDir) {
    fs.rmSync(outputDir, { recursive: true, force: true })
    fs.mkdirSync(outputDir, { recursive: true })
    const components = []
    for (const file of fs.readdirSync(componentDir).sort()) {
      if (!file.endsWith('.json')) continue
      const fileResource = file.replace(/\.json$/, '')
      const json = JSON.parse(fs.readFileSync(path.join(componentDir, file), 'utf8'))
      const rootKey = Object.keys(json)[0]
      const tree = buildComponentTree(json[rootKey], rootKey)
      if (!tree) continue
      const typeName = rootKey.charAt(0).toUpperCase() + rootKey.slice(1)
      const propName = rootKey.charAt(0).toLowerCase() + rootKey.slice(1)
      const swiftTypes = collectSwiftTypes(tree)
      fs.writeFileSync(
        path.join(outputDir, `InstUI.Component.${typeName}.swift`),
        generateComponentFile({ typeName, tree, fileResource, rootKey })
      )
      components.push({ typeName, propName, fileResource, rootKey, swiftTypes })
    }
    generateThemeComponentsFile(components, outputDir)
  }
}
