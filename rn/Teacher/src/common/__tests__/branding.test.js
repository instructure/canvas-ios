//
// Copyright (C) 2017-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
