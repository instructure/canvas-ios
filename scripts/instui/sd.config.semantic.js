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
Generates four Swift files from the design token JSON trees:

  packages/InstUI/Sources/Semantic/Generated/InstUI.Semantic.Colors.swift
  packages/InstUI/Sources/Semantic/Generated/InstUI.Semantic.Colors+Build.swift
    — Nested Swift struct hierarchy + build() for semantic Color tokens

  packages/InstUI/Sources/Semantic/Generated/InstUI.Semantic.Layout.swift
  packages/InstUI/Sources/Semantic/Generated/InstUI.Semantic.Layout+Build.swift
    — Nested Swift struct hierarchy + build() for semantic CGFloat layout tokens
    — Includes sections: size (excluding breakpoints/media), spacing,
      borderRadius, borderWidth, fontSize
*/

const fs = require('fs')
const path = require('path')

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

// Returns true if a JSON node is a design token leaf ({value, type})
function isLeaf(obj) {
  return obj !== null &&
    typeof obj === 'object' &&
    'value' in obj &&
    'type' in obj
}

// Build a lightweight tree from the JSON subtree.
// Each node is either:
//   {type: 'leaf'}
//   {type: 'node', children: {key: subtree, ...}}  (plain object, insertion-ordered)
function buildTree(obj) {
  if (isLeaf(obj)) {
    return { type: 'leaf' }
  }
  if (typeof obj !== 'object' || obj === null) {
    return { type: 'leaf' }
  }
  const children = {}
  for (const [k, v] of Object.entries(obj)) {
    if (typeof v === 'object' && v !== null) {
      children[k] = buildTree(v)
    }
  }
  return { type: 'node', children }
}

// Convert a camelCase JSON key to a PascalCase Swift type name.
// Special overrides avoid collisions with SwiftUI built-in types.
const TYPE_NAME_OVERRIDES = {
  text: 'TextTokens' // Avoids collision with SwiftUI.Text
}
function toTypeName(key) {
  return TYPE_NAME_OVERRIDES[key] ?? (key.charAt(0).toUpperCase() + key.slice(1))
}

// ---------------------------------------------------------------------------
// Struct definition generator
// ---------------------------------------------------------------------------

// Recursively generates the full `public struct <Name>: Sendable { ... }` block.
// Returns a single string (multiline).
// leafType controls the Swift type used for leaf token properties (e.g. 'Color', 'CGFloat').
function genStructBlock(structName, tree, indentLevel, leafType = 'Color') {
  const pad = '    '.repeat(indentLevel)
  const inner = '    '.repeat(indentLevel + 1)
  const lines = []

  lines.push(`${pad}public struct ${structName}: Sendable {`)

  // 1. Property declarations
  for (const [key, child] of Object.entries(tree.children)) {
    if (child.type === 'leaf') {
      lines.push(`${inner}public let ${key}: ${leafType}`)
    } else {
      lines.push(`${inner}public let ${key}: ${toTypeName(key)}`)
    }
  }

  // 2. Nested struct definitions
  let addedBlank = false
  for (const [key, child] of Object.entries(tree.children)) {
    if (child.type === 'node') {
      if (!addedBlank) {
        lines.push('')
        addedBlank = true
      }
      lines.push(genStructBlock(toTypeName(key), child, indentLevel + 1, leafType))
    }
  }

  lines.push(`${pad}}`)
  return lines.join('\n')
}

// ---------------------------------------------------------------------------
// Loader init-expression generator
// ---------------------------------------------------------------------------

// Generates the `.init(...)` lines for a tree node, suitable for use inside
// a Swift function call argument list.
//
// Returns an array of line strings. The first line is the `.init(` opener
// (indented at baseIndent spaces). Arguments are at baseIndent+1. The last
// line is the closing `)` at baseIndent.
//
// Callers trim the first line and prepend `argPad + key + ": "` to it so
// that the nested structure aligns correctly.
function genInitLines(tree, pathPrefix, baseIndent) {
  const pad = '    '.repeat(baseIndent)
  const argPad = '    '.repeat(baseIndent + 1)
  const lines = [`${pad}.init(`]

  const entries = Object.entries(tree.children)
  for (let i = 0; i < entries.length; i++) {
    const [key, child] = entries[i]
    const isLast = i === entries.length - 1
    const fullPath = pathPrefix ? `${pathPrefix}.${key}` : key

    if (child.type === 'leaf') {
      lines.push(`${argPad}${key}: token("${fullPath}")${isLast ? '' : ','}`)
    } else {
      // Recurse one level deeper
      const subLines = genInitLines(child, fullPath, baseIndent + 1)
      // Prepend `key: ` to the first sub-line (which starts with argPad+".init(")
      lines.push(`${argPad}${key}: ${subLines[0].trimStart()}`)
      // Middle lines are unchanged
      for (let j = 1; j < subLines.length - 1; j++) {
        lines.push(subLines[j])
      }
      // Closing `)` — add comma if there are more entries
      lines.push(subLines[subLines.length - 1] + (isLast ? '' : ','))
    }
  }

  lines.push(`${pad})`)
  return lines
}

// ---------------------------------------------------------------------------
// Unified file generator — one file per JSON section, struct + build merged
// ---------------------------------------------------------------------------

// Recursively generates `("path", swiftAccess),` lines for the `all` array.
function genAllEntries(tree, pathPrefix, swiftPrefix, indentLevel) {
  const pad = '    '.repeat(indentLevel)
  const lines = []
  for (const [key, child] of Object.entries(tree.children)) {
    const fullPath = pathPrefix ? `${pathPrefix}.${key}` : key
    const swiftAccess = swiftPrefix ? `${swiftPrefix}.${key}` : key
    if (child.type === 'leaf') {
      lines.push(`${pad}("${fullPath}", ${swiftAccess}),`)
    } else {
      lines.push(...genAllEntries(child, fullPath, swiftAccess, indentLevel))
    }
  }
  return lines
}

// Generates a single `InstUI.Semantic.<typeName>.swift` containing:
//   • The public struct definition (via genStructBlock)
//   • A static build() function
//   • An optional `all` computed property (used by Colors for the Storybook)
function generateSemanticFile({ typeName, tree, swiftImport, leafType, includeAll = false }) {
  const lines = []
  lines.push(fileHeader)
  lines.push('')
  lines.push(swiftImport)
  lines.push('')
  lines.push("// DO NOT EDIT — Auto-generated by `yarn build-instui`")

  // Struct definition
  lines.push('extension InstUI.Semantic {')
  lines.push('')
  lines.push(genStructBlock(typeName, tree, 1, leafType))
  lines.push('}')
  lines.push('')

  // Build function + optional `all`
  lines.push(`extension InstUI.Semantic.${typeName} {`)
  lines.push('')
  lines.push(`    static func build(_ token: (InstUI.TokenKey) throws -> ${leafType}) throws -> InstUI.Semantic.${typeName} {`)

  const retLines = [`        try InstUI.Semantic.${typeName}(`]
  const entries = Object.entries(tree.children)
  for (let i = 0; i < entries.length; i++) {
    const [key, child] = entries[i]
    const isLast = i === entries.length - 1
    if (child.type === 'leaf') {
      retLines.push(`            ${key}: token("${key}")${isLast ? '' : ','}`)
    } else {
      const subLines = genInitLines(child, key, 3)
      retLines.push(`            ${key}: ${subLines[0].trimStart()}`)
      for (let j = 1; j < subLines.length - 1; j++) retLines.push(subLines[j])
      retLines.push(subLines[subLines.length - 1] + (isLast ? '' : ','))
    }
  }
  retLines.push('        )')
  lines.push(...retLines)
  lines.push('    }')

  if (includeAll) {
    lines.push('')
    lines.push(`    public var all: [(name: String, color: ${leafType})] {`)
    lines.push('        [')
    lines.push(...genAllEntries(tree, '', '', 3))
    lines.push('        ]')
    lines.push('    }')
  }

  lines.push('}')
  lines.push('')
  return lines.join('\n')
}

// ---------------------------------------------------------------------------
// Section configuration
// ---------------------------------------------------------------------------

// Each entry describes one top-level JSON section → one Swift file.
// excludeKeys removes sub-keys before building the tree (web-only values).
//
// Skipped sections (not included in LAYOUT_SECTIONS):
//   lineHeight  — mixed rem and % values; % lines can't be resolved without a base font size
//   breakpoints — CSS responsive breakpoints (em-based), no iOS equivalent
//   media       — CSS media query values (em-based), no iOS equivalent
//   visibleInCanvas / visibleInRebrand — design tool visibility flags, not runtime values
const COLOR_SECTION = {
  typeName: 'Colors', swiftImport: 'import SwiftUI', leafType: 'Color', includeAll: true
}

const LAYOUT_SECTIONS = [
  { key: 'size', typeName: 'Size', swiftImport: 'import CoreGraphics', leafType: 'CGFloat', excludeKeys: ['breakpoints', 'media'] }, // breakpoints/media are web-only em values
  { key: 'spacing', typeName: 'Spacing', swiftImport: 'import CoreGraphics', leafType: 'CGFloat' },
  { key: 'borderRadius', typeName: 'BorderRadius', swiftImport: 'import CoreGraphics', leafType: 'CGFloat' },
  { key: 'borderWidth', typeName: 'BorderWidth', swiftImport: 'import CoreGraphics', leafType: 'CGFloat' },
  { key: 'fontSize', typeName: 'FontSize', swiftImport: 'import CoreGraphics', leafType: 'CGFloat' },
  { key: 'opacity', typeName: 'Opacity', swiftImport: 'import Foundation', leafType: 'Double' },
  { key: 'fontWeight', typeName: 'FontWeights', swiftImport: 'import SwiftUI', leafType: 'Font.Weight' },
  { key: 'fontFamily', typeName: 'FontFamilies', swiftImport: 'import Foundation', leafType: 'String' },
]

// ---------------------------------------------------------------------------
// Module export
// ---------------------------------------------------------------------------

module.exports = function buildSemantic(light, dark, layout) {
  const sourcesDir = path.join(__dirname, '../../packages/InstUI/Sources/Semantic/Generated')
  fs.mkdirSync(sourcesDir, { recursive: true })

  // Color section — derived from light/dark JSON pair
  fs.writeFileSync(
    path.join(sourcesDir, 'InstUI.Semantic.Colors.swift'),
    generateSemanticFile({ ...COLOR_SECTION, tree: buildTree(light.color) })
  )

  // Layout sections — all derived from layout/default.json
  for (const section of LAYOUT_SECTIONS) {
    let json = layout[section.key]
    if (!json) continue
    if (section.excludeKeys) {
      json = { ...json }
      for (const k of section.excludeKeys) delete json[k]
    }
    fs.writeFileSync(
      path.join(sourcesDir, `InstUI.Semantic.${section.typeName}.swift`),
      generateSemanticFile({ ...section, tree: buildTree(json) })
    )
  }
}
