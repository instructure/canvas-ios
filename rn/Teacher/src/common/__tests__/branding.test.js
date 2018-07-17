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

describe('setupBrandingFromNativeBrandingInfo', () => {
  it('uses defaults', () => {
    const expected = { ...branding }
    setupBrandingFromNativeBrandingInfo({})
    expect(branding).toEqual(expected)
  })

  it('parses native branding info', () => {
    let expected = {
      navBarColor: 'navBarColor',
      primaryButtonTextColor: 'primaryButtonTextColor',
      primaryButtonColor: 'primaryButtonColor',
      fontColorDark: 'fontColorDark',
      headerImage: './src/images/canvas-logo.png',
      navBarButtonColor: 'navBarButtonColor',
      navBarTextColor: 'navBarTextColor',
      primaryBrandColor: '#374A59',
    }

    let input = {
      'ic-brand-global-nav-bgd': 'navBarColor',
      'ic-brand-button--primary-text': 'primaryButtonTextColor',
      'ic-brand-button--primary-bgd': 'primaryButtonColor',
      'ic-brand-font-color-dark': 'fontColorDark',
      'ic-brand-header-image': './src/images/canvas-logo.png',
      'ic-brand-global-nav-ic-icon-svg-fill': 'navBarButtonColor',
      'ic-brand-global-nav-menu-item__text-color': 'navBarTextColor',
    }
    setupBrandingFromNativeBrandingInfo(input)

    expect(branding).toEqual(expected)
  })

  it('updates created StyleSheet', () => {
    setupBrandingFromNativeBrandingInfo({ 'ic-brand-primary': 'red' })
    const sheet = createStyleSheet(colors => ({
      test: { color: colors.primaryBrandColor },
    }))
    // $FlowFixMe StyleSheet doesn't convert to number in tests
    expect(sheet.test.color).toBe('red')
    setupBrandingFromNativeBrandingInfo({ 'ic-brand-primary': 'blue' })
    // $FlowFixMe StyleSheet doesn't convert to number in tests
    expect(sheet.test.color).toBe('blue')
  })
})

describe('createStyleSheet', () => {
  it('calls the passed function with colors', () => {
    const factory = jest.fn(() => ({}))
    createStyleSheet(factory)
    expect(factory).toHaveBeenCalledWith(colors)
    setupBrandingFromNativeBrandingInfo({})
    expect(factory).toHaveBeenCalledTimes(2)
  })
})
