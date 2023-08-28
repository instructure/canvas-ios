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
const electric  = { normal: '#008EE2', high: '#1283C4' }
const shamrock  = { normal: '#00AC18', high: '#127A1B' }
const barney    = { normal: '#BF32A4', high: '#C74BAF' }
const crimson   = { normal: '#EE0612', high: '#E73A4E' }
const fire      = { normal: '#FC5E13', high: '#E36327' }
const licorice  = { normal: '#2D3B45', high: '#2D3B45' }
const oxford    = { normal: '#394B58', high: '#394B58' }
const ash       = { normal: '#556572', high: '#556572' }
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
  dark: { normal: '#394B58', high: '#394B58' },
}
const light = {
  light: porcelain,
  dark: { normal: '#6B7780', high: '#6B7780' },
}
const lightest = {
  light: white,
  dark: white,
}

const colors = {
  electric: { light: electric, dark: electric },
  electricHighContrast: {
  light: { normal: '#0770A3', high: '#0770A3' },
  dark: { normal: '#0770A3', high: '#0770A3' },
  },
  shamrock: {
  light: { normal: shamrock.high, high: shamrock.high },
  dark: { normal: shamrock.normal, high: shamrock.normal },
  },
  barney: { light: barney, dark: barney },
  crimson: { light: crimson, dark: crimson },
  fire: { light: fire, dark: fire },

  licorice: { light: licorice, dark: licorice },
  oxford: { light: oxford, dark: oxford },
  ash: { light: ash, dark: ash },
  tiara: { light: tiara, dark: tiara },
  porcelain: { light: porcelain, dark: ash },
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
    dark: { normal: '#121212', high: '#121212' },
  },
  backgroundGroupedCell: {
    light: white,
    dark: { normal: '#252525', high: '#252525' },
  },
  backgroundDarkest: {
    light: licorice,
    dark: licorice,
  },
  backgroundDark: {
    light: ash,
    dark: ash,
  },
  backgroundMedium: {
    light: tiara,
    dark: { normal: '#242426', high: '#242426' },
  },
  backgroundLight: {
    light: porcelain,
    dark: { normal: '#1D1E1F', high: '#1D1E1F' },
  },
  backgroundLightest: {
    light: white,
    dark: { normal: '#121212', high: '#121212' },
  },
  tabBarBackground: {
  	light: white,
  	dark: { normal: '#1D1E1F', high: '#1D1E1F' },
  },
  get backgroundAlert () { return colors.barney },
  get backgroundInfo () { return colors.electricHighContrast },
  get backgroundDanger () { return colors.crimson },
  get backgroundWarning () { return colors.fire },

  backgroundSuccess: {
  light: { normal: shamrock.high, high: shamrock.high },
  dark: { normal: shamrock.high, high: shamrock.high },
  },

  borderDarkest: darkest,
  borderDark: dark,
  borderMedium: medium,
  borderLight: light,
  borderLightest: lightest,
  get borderAlert () { return colors.barney },
  get borderInfo () { return colors.electricHighContrast },
  get borderDanger () { return colors.crimson },
  get borderWarning () { return colors.fire },

  borderSuccess: {
  light: { normal: shamrock.high, high: shamrock.high },
  dark: { normal: shamrock.high, high: shamrock.high },
  },
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

class InstColorExtensionTests: XCTestCase {
    func testUIColor() {
        ${colorArray.filter(color => color != 'white').map(name =>
          `XCTAssertEqual(UIColor.${name}, UIColor(named: "${name}", in: .core, compatibleWith: nil))`
        ).join('\n        ')}
    }

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
