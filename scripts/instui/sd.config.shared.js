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
Shared utilities used by sd.config.semantic.js and sd.config.primitives.js:
  - fileHeader        — AGPL license header for generated Swift files
  - isLeaf            — DTCG leaf node detection
  - toTypeName        — camelCase key → PascalCase Swift type name
  - genStructBlock    — recursive Swift struct definition generator
  - genInitLines      — .init(...) expression generator for build() bodies
  - genAllEntries     — ("path", swiftAccess), line generator for all arrays
*/

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
// leafType: the Swift type for homogeneous leaves (e.g. 'Color', 'CGFloat').
//   Pass null for heterogeneous component trees — each leaf then uses child.swiftType.
function genStructBlock(structName, tree, indentLevel, leafType = 'Color', extraProperties = []) {
  const pad = '    '.repeat(indentLevel)
  const inner = '    '.repeat(indentLevel + 1)
  const lines = []

  lines.push(`${pad}public struct ${structName}: Sendable {`)

  // 1. Property declarations
  for (const [key, child] of Object.entries(tree.children)) {
    if (child.type === 'leaf') {
      lines.push(`${inner}public let ${key}: ${leafType ?? child.swiftType}`)
    } else {
      lines.push(`${inner}public let ${key}: ${toTypeName(key)}`)
    }
  }
  for (const prop of extraProperties) {
    lines.push(`${inner}${prop}`)
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
//
// getClosure maps a leaf's swiftType to the closure parameter name used in build().
// Defaults to () => 'token' for homogeneous semantic files.
function genInitLines(tree, pathPrefix, baseIndent, getClosure = () => 'token') {
  const pad = '    '.repeat(baseIndent)
  const argPad = '    '.repeat(baseIndent + 1)
  const lines = [`${pad}.init(`]

  const entries = Object.entries(tree.children)
  for (let i = 0; i < entries.length; i++) {
    const [key, child] = entries[i]
    const isLast = i === entries.length - 1
    const fullPath = pathPrefix ? `${pathPrefix}.${key}` : key

    if (child.type === 'leaf') {
      const closure = getClosure(child.swiftType)
      lines.push(`${argPad}${key}: ${closure}("${fullPath}")${isLast ? '' : ','}`)
    } else {
      // Recurse one level deeper
      const subLines = genInitLines(child, fullPath, baseIndent + 1, getClosure)
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
// `all` array entry generator
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

module.exports = { fileHeader, isLeaf, toTypeName, genStructBlock, genInitLines, genAllEntries }
