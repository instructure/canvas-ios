#!/usr/bin/env node
//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
Downloads and generates all the icons from instructure.design.

Depends on node
 brew install node

Run this script from the repo root directory
 yarn build-icons
*/

const fs = require('fs')
const path = require('path')
const { execSync } = require('child_process')
const convert = require('./svg2pdf')

const echo = (out) => console.log(out)
const run = (cmd) => execSync(cmd, { stdio: 'inherit' })
const skipDownload = process.argv.includes('--skip-download')

// List of all icons we want to export from
// https://github.com/instructure/instructure-ui/tree/master/packages/ui-icons/svg/Line
// https://github.com/instructure/instructure-ui/tree/master/packages/ui-icons/svg/Solid
const whitelist = [
  'add',
  'address-book',
  'alerts',
  'announcement',
  'arrow-open-down',
  'arrow-open-left',
  'arrow-open-right',
  'assignment',
  'audio',
  'bold',
  'box',
  'bullet-list',
  'calendar-clock',
  'calendar-month',
  'check',
  'clock',
  'cloud-lock',
  'comment',
  'complete',
  'courses',
  'dashboard',
  'discussion',
  'document',
  'edit',
  'email',
  'empty',
  'exit-full-screen',
  'external-link',
  'eye',
  'folder',
  'forward',
  'full-screen',
  'gradebook',
  'group',
  'hamburger',
  'highlighter',
  'home',
  'image',
  'info',
  'instructure',
  'italic',
  'invitation',
  'link',
  'lock',
  'lti',
  'marker',
  'mastery-paths',
  'mini-arrow-down',
  'mini-arrow-end',
  'mini-arrow-start',
  'mini-arrow-up',
  'module',
  'more',
  'no',
  'note',
  'numbered-list',
  'off',
  'outcomes',
  'paint',
  'paperclip',
  'pause',
  'pdf',
  'peer-review',
  'play',
  'prerequisite',
  'publish',
  'question',
  'quiz',
  'refresh',
  'reply',
  'reply-all',
  'rubric',
  'settings',
  'star',
  'strikethrough',
  'text',
  'text-color',
  'trash',
  'trouble', // cancel
  'unlock',
  'user',
  'video',
  'warning',
  'x',
]

const getImages = (path) => fs.readdirSync(path, { withFileTypes: true }).flatMap(dir => {
  if (!dir.isDirectory()) { return [] }
  if (dir.name.endsWith('.imageset')) { return dir.name.slice(0, -9) }
  return getImages(`${path}/${dir.name}`)
})
const localIcons = getImages('./Core/Core/Assets.xcassets/icons').sort()

const overrides = {
  star: { Line: 'star-light' },
  'reply-all': { Line: 'reply-all-2', Solid: 'reply-all-2' },
}

const assetsFolder = './Core/Core/Assets.xcassets/InstIcons'

echo('Building Icons...')
run(`rm -rf ${assetsFolder}`)
run(`mkdir -p tmp ${assetsFolder}`)
fs.writeFileSync(`${assetsFolder}/Contents.json`, `{
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}
`)

const icons = new Set()
for (const icon of whitelist) {
  for (const type of [ 'Line', 'Solid' ]) {
    const name = icon.replace(/\W+(\w)/g, (_, c) => c.toUpperCase())
    echo(name + type)
    icons.add(name)
    let slug = (overrides[icon] || {})[type] || icon
    const filepath = `tmp/${name}${type}.svg`
    const folder = `${assetsFolder}/${name}${type}.imageset`
    const sfolder = `${assetsFolder}/Symbols/${name}${type}Symbol.symbolset`
    if (!skipDownload) {
      run(`curl -sSL https://raw.githubusercontent.com/instructure/instructure-ui/c1c7d673/packages/ui-icons/svg/${type}/${slug}.svg > ${filepath}`)
    }
    run(`mkdir -p ${folder}`)
    // Icons in tab & nav bar need intrinsic size of 24x24 with 2px internal padding
    convert(filepath, `${folder}/${name}.pdf`, [ 24, 24 ], 2)
    fs.writeFileSync(`${folder}/Contents.json`, `{
  "images" : [
    {
      "idiom" : "universal",
      "filename" : "${name}.pdf"${ !/right|left|list|play|forward|reply|start|miniArrowEnd/i.test(name) ? '' : `,
      "language-direction" : "left-to-right"` }
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  },
  "properties" : {
    "template-rendering-intent" : "template",
    "preserves-vector-representation" : true
  }
}\n`)

    // Generate symbol image
    run(`mkdir -p ${sfolder}`)
    fs.writeFileSync(`${sfolder}/${name}.svg`,
`<svg version="1.1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
 <g id="Guides">
  <line id="Baseline-S" x1="0" x2="24" y1="18" y2="18"/>
  <line id="Capline-S"  x1="0" x2="24" y1="6"  y2="6"/>
  <line id="Baseline-M" x1="0" x2="24" y1="18" y2="18"/>
  <line id="Capline-M"  x1="0" x2="24" y1="6"  y2="6"/>
  <line id="Baseline-L" x1="0" x2="24" y1="18" y2="18"/>
  <line id="Capline-L"  x1="0" x2="24" y1="6"  y2="6"/>
  <line id="left-margin"  x1="0"  x2="0"  y1="0" y2="24"/>
  <line id="right-margin" x1="24" x2="24" y1="0" y2="24"/>
 </g>
 <g id="Symbols">
  <g id="Regular-M">
   <rect width="24" height="24" opacity="0" />
   <g transform="matrix(${20/1920} 0 0 ${20/1920} 2 2)">
     ${fs.readFileSync(filepath, 'utf8').replace(/<\/?svg[^>]*>/gi, '').trim()}
   </g>
  </g>
 </g>
</svg>
`)
    fs.writeFileSync(`${sfolder}/Contents.json`, JSON.stringify({
      "info" : {
        "author" : "xcode",
        "version" : 1
      },
      "symbols" : [
        {
          "filename" : `${name}.svg`,
          "idiom" : "universal",
          ... !/right|left|list|play|forward|reply|start|miniArrowEnd/i.test(name) ? {} : {
            "language-direction" : "left-to-right"
          }
        }
      ]
    }))
  }
}

fs.writeFileSync('./Core/Core/Extensions/InstIconExtensions.swift', `//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

// DO NOT EDIT: this file was generated by build-icons.js

import SwiftUI
import UIKit

public extension UIImage {
    ${Array.from(icons).sort().flatMap(name => [
      `static var ${name}Line: UIImage { UIImage(named: "${name}Line", in: .core, compatibleWith: nil)! }`,
      `static var ${name}Solid: UIImage { UIImage(named: "${name}Solid", in: .core, compatibleWith: nil)! }`,
    ]).join('\n    ')}

    ${localIcons.map(name =>
      `static var ${name}: UIImage { UIImage(named: "${name}", in: .core, compatibleWith: nil)! }`
    ).join('\n    ')}
}

public extension Icon {
    ${Array.from(icons).sort().flatMap(name => [
      `static var ${name}Line: Icon { Icon("${name}Line") }`,
      `static var ${name}Solid: Icon { Icon("${name}Solid") }`,
    ]).join('\n    ')}
}
`)
fs.writeFileSync('./Core/CoreTests/Extensions/InstIconExtensionsTests.swift', `//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

// DO NOT EDIT: this file was generated by build-colors.js

import XCTest
import SwiftUI
import UIKit
@testable import Core

class InstIconExtensionTests: XCTestCase {
    // swiftlint:disable function_body_length
    func testUIImage() {
        ${Array.from(icons).sort().flatMap(name => [
          `XCTAssertEqual(UIImage.${name}Line, UIImage(named: "${name}Line", in: .core, compatibleWith: nil))`,
          `XCTAssertEqual(UIImage.${name}Solid, UIImage(named: "${name}Solid", in: .core, compatibleWith: nil))`,
        ]).join('\n        ')}

        ${localIcons.map(name =>
          `XCTAssertEqual(UIImage.${name}, UIImage(named: "${name}", in: .core, compatibleWith: nil))`
        ).join('\n        ')}
    }

    func testImage() {
        ${Array.from(icons).sort().flatMap(name => [
          `XCTAssertEqual(Icon.${name}Line.image, Image("${name}LineSymbol", bundle: .core))`,
          `XCTAssertEqual(Icon.${name}Solid.image, Image("${name}SolidSymbol", bundle: .core))`,
        ]).join('\n        ')}
    }
    // swiftlint:enable function_body_length
}
`)

fs.writeFileSync('./rn/Teacher/src/images/inst-icons.js', `//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

// DO NOT EDIT: this file was generated by build-icons.js

export default function icon (name, type = 'line') {
  return { uri: \`\${name}\${type[0].toUpperCase()}\${type.slice(1)}\` }
}
`)
