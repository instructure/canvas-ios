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

// @flow

import {
  branding,
  createStyleSheet,
  setupBrandingFromNativeBrandingInfo,
} from '../branding'
import colors from '../colors'

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

describe('setupBrandingFromNativeBrandingInfo', () => {
  it('parses native branding info', () => {
    let expected = {
      link: 'linkColor',
      navBarColor: 'navBarColor',
      primaryButtonTextColor: 'primaryButtonTextColor',
      primaryButtonColor: 'primaryButtonColor',
      fontColorDark: 'fontColorDark',
      headerImage: './src/images/canvas-logo.png',
      navBarButtonColor: 'navBarButtonColor',
      navBarTextColor: 'navBarTextColor',
      primaryBrandColor: '#374A59',
    }

    setupBrandingFromNativeBrandingInfo({
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

    expect(branding).toEqual(expected)
  })

  it('updates created StyleSheet', () => {
    setupBrandingFromNativeBrandingInfo({ ...emptyBrand, primary: 'red' })
    const sheet = createStyleSheet(colors => ({
      test: { color: colors.primaryBrandColor },
    }))
    // $FlowFixMe StyleSheet doesn't convert to number in tests
    expect(sheet.test.color).toBe('red')
    setupBrandingFromNativeBrandingInfo({ ...emptyBrand, primary: 'blue' })
    // $FlowFixMe StyleSheet doesn't convert to number in tests
    expect(sheet.test.color).toBe('blue')
  })
})

describe('createStyleSheet', () => {
  it('calls the passed function with colors', () => {
    const factory = jest.fn(() => ({}))
    createStyleSheet(factory)
    expect(factory).toHaveBeenCalledWith(colors)
    setupBrandingFromNativeBrandingInfo(emptyBrand)
    expect(factory).toHaveBeenCalledTimes(2)
  })
})
