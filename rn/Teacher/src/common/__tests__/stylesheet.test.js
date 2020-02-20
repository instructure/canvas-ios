//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

import {
  colors,
  createStyleSheet,
  vars,
  setupBranding,
} from '../stylesheet'

const emptyBrand = {
  buttonPrimaryBackground: 'white',
  buttonPrimaryText: 'white',
  buttonSecondaryBackground: 'white',
  buttonSecondaryText: 'white',
  fontColorDark: 'white',
  headerImageBackground: 'white',
  headerImageUrl: null,
  linkColor: 'white',
  navBackground: 'white',
  navBadgeBackground: 'white',
  navBadgeText: 'white',
  navIconFill: 'white',
  navIconFillActive: 'white',
  navTextColor: 'white',
  navTextColorActive: 'white',
  primary: 'white',
}

describe('setupBranding', () => {
  it('parses native branding info', () => {
    let expected = {
      buttonPrimaryBackground: 'primaryButtonColor',
      buttonPrimaryText: 'primaryButtonTextColor',
      fontColorDark: 'fontColorDark',
      linkColor: 'linkColor',
      navBackground: 'navBarColor',
      navIconFill: 'navBarButtonColor',
      navTextColor: 'navBarTextColor',
      primary: '#374A59',
    }

    setupBranding({
      ...emptyBrand,
      buttonPrimaryBackground: 'primaryButtonColor',
      buttonPrimaryText: 'primaryButtonTextColor',
      fontColorDark: 'fontColorDark',
      headerImageUrl: './src/images/canvas-logo.png',
      linkColor: 'linkColor',
      navBackground: 'navBarColor',
      navIconFill: 'navBarButtonColor',
      navTextColor: 'navBarTextColor',
      primary: '#374A59',
    })

    expect(colors).toMatchObject(expected)
    expect(vars.headerImageURL).toBe('./src/images/canvas-logo.png')
  })

  it('updates created StyleSheet', () => {
    setupBranding({ ...emptyBrand, primary: 'red' })
    const sheet = createStyleSheet(colors => ({
      test: { color: colors.primary },
    }))
    expect(sheet.test.color).toBe('red')
    setupBranding({ ...emptyBrand, primary: 'blue' })
    expect(sheet.test.color).toBe('blue')
  })
})

describe('createStyleSheet', () => {
  it('calls the passed function with colors', () => {
    const factory = jest.fn(() => ({}))
    createStyleSheet(factory)
    expect(factory).toHaveBeenCalledWith(colors, vars)
    setupBranding(emptyBrand)
    expect(factory).toHaveBeenCalledTimes(2)
  })
})
