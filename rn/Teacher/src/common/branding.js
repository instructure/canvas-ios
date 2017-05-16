/**
 * @flow
 */

import color from '../common/colors'

export type BrandingConfiguration = {
  navBarColor: string,
  navBarButtonColor: string,
  primaryButtonColor: string,
  primaryButtonTextColor: string,
  primaryBrandColor: string,
  fontColorDark: string,
  headerImage?: any,
}

export const branding: BrandingConfiguration = {
  navBarColor: color.navBarColor,
  navBarButtonColor: color.primaryButtonText,
  primaryButtonTextColor: color.primaryButtonText,
  primaryButtonColor: color.primaryButton,
  fontColorDark: '#000',
  headerImage: require('../images/canvas-logo.png'),
  primaryBrandColor: color.navBarColor,
}

export function setupBrandingFromNativeBrandingInfo (obj: Object): void {
  branding.navBarColor = obj[`ic-brand-global-nav-bgd`] || branding.navBarColor
  branding.primaryButtonTextColor = obj[`ic-brand-button--primary-text`] || branding.primaryButtonTextColor
  branding.primaryButtonColor = obj[`ic-brand-button--primary-bgd`] || branding.primaryButtonColor
  branding.fontColorDark = obj[`ic-brand-font-color-dark`] || branding.fontColorDark
  branding.navBarButtonColor = obj[`ic-brand-global-nav-ic-icon-svg-fill`] || branding.navBarButtonColor
  branding.primaryBrandColor = obj[`ic-brand-primary`] || branding.primaryBrandColor
  branding.headerImage = obj[`ic-brand-header-image`] || branding.headerImage

  //  now that we have branding data, set colors object as well
  color.navBarColor = branding.navBarColor
  color.navBarButtonColor = branding.navBarButtonColor
  color.primaryButtonTextColor = branding.primaryButtonTextColor
  color.primaryButtonColor = branding.primaryButtonColor
  color.primaryBrandColor = branding.primaryBrandColor
}

export default branding
