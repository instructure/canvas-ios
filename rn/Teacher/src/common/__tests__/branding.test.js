/**
 * @flow
 */

import 'react-native'
import { branding, setupBrandingFromNativeBrandingInfo } from '../branding'

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
})
