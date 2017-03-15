/**
 * @flow
 */

import 'react-native'
import { branding, setupBrandingFromNativeBrandingInfo } from '../branding'

test('parses native branding info', () => {
  let expected = {
    linkColor: 'linkColor',
    navBgColor: 'navBgColor',
    primaryButtonTextColor: 'primaryButtonTextColor',
    primaryButtonColor: 'primaryButtonColor',
    fontColorDark: 'fontColorDark',
    headerImage: './src/images/canvas-logo.png',
    navButtonColor: 'navButtonColor',
  }

  let input =
    {
      id: 0,
      'ic-link-color': 'linkColor',
      'ic-brand-global-nav-bgd': 'navBgColor',
      'ic-brand-button--primary-text': 'primaryButtonTextColor',
      'ic-brand-button--primary-bgd': 'primaryButtonColor',
      'ic-brand-font-color-dark': 'fontColorDark',
      'ic-brand-header-image': 'headerImage',
      'ic-brand-global-nav-ic-icon-svg-fill': 'navButtonColor',
    }

  setupBrandingFromNativeBrandingInfo(input)

  expect(branding).toEqual(expected)
})
