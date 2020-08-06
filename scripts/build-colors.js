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
Generates all the color assets & extension.

Depends on node
 brew install node

Run this script from the repo root directory
 yarn build-colors
*/

const fs = require('fs')
const { dirname } = require('path')

// Canvas Styleguide colors
const electric  = { normal: '#008EE2', high: '#0770A3' }
const shamrock  = { normal: '#00AC18', high: '#127A1B' }
const barney    = { normal: '#BF32A4', high: '#B8309E' }
const crimson   = { normal: '#EE0612', high: '#D01A19' }
const fire      = { normal: '#FC5E13', high: '#C23C0D' }
const licorice  = { normal: '#2D3B45', high: '#2D3B45' }
const oxford    = { normal: '#394B58', high: '#394B58' }
const ash       = { normal: '#8B969E', high: '#556572' }
const tiara     = { normal: '#C7CDD1', high: '#556572' }
const porcelain = { normal: '#F5F5F5', high: '#FFFFFF' }
const white     = { normal: '#FFFFFF', high: '#FFFFFF' }

const darkest = {
  light: licorice,
  dark: white,
}
const dark = {
  light: ash,
  dark: { normal: '#C7CDD1', high: '#C7CDD1' },
}
const medium = {
  light: tiara,
  dark: { normal: '#556572', high: '#C7CDD1' },
}
const light = {
  light: porcelain,
  dark: oxford,
}
const lightest = {
  light: white,
  dark: { normal: '#000000', high: '#000000' },
}

const colors = {
  electric: { light: electric, dark: electric },
  shamrock: { light: shamrock, dark: shamrock },
  barney: { light: barney, dark: barney },
  crimson: { light: crimson, dark: crimson },
  fire: { light: fire, dark: fire },

  licorice: { light: licorice, dark: licorice },
  oxford: { light: oxford, dark: oxford },
  ash: { light: ash, dark: ash },
  tiara: { light: tiara, dark: tiara },
  porcelain: { light: porcelain, dark: porcelain },
  white: { light: white, dark: white },

  textDarkest: darkest,
  textDark: dark,
  textLight: light,
  textLightest: lightest,
  get textAlert () { return colors.barney },
  get textInfo () { return colors.electric },
  get textSuccess () { return colors.shamrock },
  get textDanger () { return colors.crimson },
  get textWarning () { return colors.fire },

  backgroundGrouped: {
    light: { normal: porcelain.normal, high: ash.normal },
    dark: lightest.dark,
  },
  backgroundGroupedCell: {
    light: white,
    dark: { normal: '#1C1C1E', high: '#242426' },
  },
  backgroundDarkest: darkest,
  backgroundDark: dark,
  backgroundMedium: medium,
  backgroundLight: light,
  backgroundLightest: lightest,
  get backgroundAlert () { return colors.barney },
  get backgroundInfo () { return colors.electric },
  get backgroundSuccess () { return colors.shamrock },
  get backgroundDanger () { return colors.crimson },
  get backgroundWarning () { return colors.fire },

  borderDarkest: darkest,
  borderDark: dark,
  borderMedium: medium,
  borderLight: light,
  borderLightest: lightest,
  get borderAlert () { return colors.barney },
  get borderInfo () { return colors.electric },
  get borderSuccess () { return colors.shamrock },
  get borderDanger () { return colors.crimson },
  get borderWarning () { return colors.fire },
}

const root = './Core/Core/Assets.xcassets/Colors/'
require('child_process').execSync(`rm -rf ${root}`)
write(`${root}/Contents.json`, {
  info: {
    version: 1,
    author: 'xcode',
  }
})
for (const name of Object.keys(colors)) {
  let color = colors[name]
  write(`${root}/${name}.colorset/Contents.json`, {
    info: {
      version: 1,
      author: 'xcode',
    },
    colors: [
      {
        idiom: 'universal',
        color: colorJSON(color.light.normal),
      },
      {
        idiom: 'universal',
        appearances: [
          { appearance: 'luminosity', value: 'dark' },
        ],
        color: colorJSON(color.dark.normal),
      },
      {
        idiom: 'universal',
        appearances: [
          { appearance: 'contrast', value: 'high' },
        ],
        color: colorJSON(color.light.high),
      },
      {
        idiom: 'universal',
        appearances: [
          { appearance: 'luminosity', value: 'dark' },
          { appearance: 'contrast', value: 'high' },
        ],
        color: colorJSON(color.dark.high),
      },
    ],
  })
}

const colorArray = Array.from(Object.keys(colors)).sort()
fs.writeFileSync('./Core/Core/Extensions/InstColorExtensions.swift', `//
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

// DO NOT EDIT: this file was generated by build-colors.js

import SwiftUI
import UIKit

public extension UIColor {
    ${colorArray.filter(color => color != 'white').map(name =>
      `static let ${name} = UIColor(named: "${name}", in: .core, compatibleWith: nil)!`
    ).join('\n    ')}
}

@available(iOSApplicationExtension 13, *)
public extension Color {
    ${colorArray.filter(color => color != 'white').map(name =>
      `static let ${name} = Color("${name}", bundle: .core)`
    ).join('\n    ')}
}
`)
fs.writeFileSync('./Core/CoreTests/Extensions/InstColorExtensionsTests.swift', `//
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

class InstColorsExtensionTests: XCTestCase {
    func testUIColor() {
        ${colorArray.filter(color => color != 'white').map(name =>
          `XCTAssertEqual(UIColor.${name}, UIColor(named: "${name}", in: .core, compatibleWith: nil))`
        ).join('\n        ')}
    }

    @available(iOS 13, *)
    func testColor() {
        ${colorArray.filter(color => color != 'white').map(name =>
          `XCTAssertEqual(Color.${name}, Color("${name}", bundle: .core))`
        ).join('\n        ')}
    }
}
`)

fs.writeFileSync('./rn/Teacher/src/common/inst-colors.js', `//
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

// DO NOT EDIT: this file was generated by build-colors.js

const instColors = {
  ${colorArray.map(name => {
    return `${name}: [ '${
      colors[name].light.normal}', '${
      colors[name].light.high}', '${
      colors[name].dark.normal}', '${
      colors[name].dark.high}' ],`
  }).join('\n  ')}
}

export const updateColors = (colors, style, contrast) => {
  let i = (contrast === 'high' ? 1 : 0) + (style === 'dark' ? 2 : 0)
  for (const name of Object.keys(instColors)) {
    colors[name] = instColors[name][i]
  }
}
`)

function colorJSON(value) {
  return {
    'color-space': 'srgb',
    components: {
      red: `0x${value.slice(1, 3)}`,
      alpha: '1.000',
      blue: `0x${value.slice(5, 7)}`,
      green: `0x${value.slice(3, 5)}`,
    },
  }
}

function write(path, object) {
  fs.mkdirSync(dirname(path), { mode: 0o755, recursive: true })
  fs.writeFileSync(
    path,
    // match Xcode's JSON style
    JSON.stringify(object, null, '  ').replace(/":/g, '" :'),
    { mode: 0o644 }
  )
}
