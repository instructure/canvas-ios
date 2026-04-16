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
Generates two Swift files from the rebrandLight.json token tree:

  packages/InstUI/Sources/Semantic/InstUISemanticColors.swift
    — Nested Swift struct hierarchy (compile-time type safety, no values)

  packages/InstUI/Sources/Semantic/InstUISemanticColorLoader.swift
    — Runtime load() function that reads JSON + resolves token references
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
function genStructBlock(structName, tree, indentLevel) {
  const pad = '    '.repeat(indentLevel)
  const inner = '    '.repeat(indentLevel + 1)
  const lines = []

  lines.push(`${pad}public struct ${structName}: Sendable {`)

  // 1. Property declarations
  for (const [key, child] of Object.entries(tree.children)) {
    if (child.type === 'leaf') {
      lines.push(`${inner}public let ${key}: Color`)
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
      lines.push(genStructBlock(toTypeName(key), child, indentLevel + 1))
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
// Top-level file generators
// ---------------------------------------------------------------------------

function generateStructFile(colorTree) {
  const lines = []
  lines.push(fileHeader)
  lines.push('')
  lines.push('import SwiftUI')
  lines.push('')
  lines.push("// DO NOT EDIT — Auto-generated by `yarn build-instui`")
  lines.push('extension InstUI {')
  lines.push('')
  lines.push('    public enum Semantic {')
  lines.push('')
  lines.push(genStructBlock('Colors', colorTree, 2))
  lines.push('    }')
  lines.push('}')
  lines.push('')
  return lines.join('\n')
}

function generateBuildFile(colorTree) {
  const lines = []
  lines.push(fileHeader)
  lines.push('')
  lines.push('import SwiftUI')
  lines.push('')
  lines.push("// DO NOT EDIT — Auto-generated by `yarn build-instui`")
  lines.push('extension InstUI.Semantic.Colors {')
  lines.push('')
  lines.push('    static func build(_ token: (String) throws -> Color) throws -> InstUI.Semantic.Colors {')

  const retLines = []
  retLines.push('        return try InstUI.Semantic.Colors(')

  const entries = Object.entries(colorTree.children)
  for (let i = 0; i < entries.length; i++) {
    const [key, child] = entries[i]
    const isLast = i === entries.length - 1

    if (child.type === 'leaf') {
      retLines.push(`            ${key}: token("${key}")${isLast ? '' : ','}`)
    } else {
      const subLines = genInitLines(child, key, 3)
      retLines.push(`            ${key}: ${subLines[0].trimStart()}`)
      for (let j = 1; j < subLines.length - 1; j++) {
        retLines.push(subLines[j])
      }
      retLines.push(subLines[subLines.length - 1] + (isLast ? '' : ','))
    }
  }

  retLines.push('        )')
  lines.push(...retLines)
  lines.push('    }')
  lines.push('')
  lines.push('    public var all: [(name: String, color: Color)] {')
  lines.push('        [')
  lines.push(...genAllEntries(colorTree, '', '', 3))
  lines.push('        ]')
  lines.push('    }')
  lines.push('}')
  lines.push('')
  return lines.join('\n')
}

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

// ---------------------------------------------------------------------------
// Module export
// ---------------------------------------------------------------------------

module.exports = function buildSemantic(light, dark) {
  // Use light JSON for the tree structure (dark has identical structure)
  const colorTree = buildTree(light.color)

  const structSwift = generateStructFile(colorTree)
  const buildSwift = generateBuildFile(colorTree)

  const sourcesDir = path.join(__dirname, '../../packages/InstUI/Sources/Semantic/Generated')
  fs.mkdirSync(sourcesDir, { recursive: true })
  fs.writeFileSync(path.join(sourcesDir, 'InstUI.Semantic.Colors.swift'), structSwift)
  fs.writeFileSync(path.join(sourcesDir, 'InstUI.Semantic.Colors+Build.swift'), buildSwift)
}
