/**
 * @flow
 */

import color from '../common/colors'

export type BrandingConfiguration = {
  navBgColor: string,
  navButtonColor: string,
  primaryButtonColor: string,
  primaryButtonTextColor: string,
  primaryBrandColor: string,
  fontColorDark: string,
  headerImage?: any,
}

export const branding: BrandingConfiguration = {
  navBgColor: color.navBarBg,
  navButtonColor: color.primaryButtonText,
  primaryButtonTextColor: color.primaryButtonText,
  primaryButtonColor: color.primaryButton,
  fontColorDark: '#000',
  headerImage: './src/images/canvas-logo.png',
  primaryBrandColor: color.navBarBg,
}

export function setupBrandingFromNativeBrandingInfo (obj: Object): void {
  branding.navBgColor = obj[`ic-brand-global-nav-bgd`] || branding.navBgColor
  branding.primaryButtonTextColor = obj[`ic-brand-button--primary-text`] || branding.primaryButtonTextColor
  branding.primaryButtonColor = obj[`ic-brand-button--primary-bgd`] || branding.primaryButtonColor
  branding.fontColorDark = obj[`ic-brand-font-color-dark`] || branding.fontColorDark
  branding.navButtonColor = obj[`ic-brand-global-nav-ic-icon-svg-fill`] || branding.navButtonColor
  branding.primaryBrandColor = obj[`ic-brand-primary`] || branding.primaryBrandColor

  //  now that we have branding data, set colors object as well
  color.navBgColor = branding.navBgColor
  color.navButtonColor = branding.navButtonColor
  color.primaryButtonTextColor = branding.primaryButtonTextColor
  color.primaryButtonColor = branding.primaryButtonColor
  color.primaryBrandColor = branding.primaryBrandColor
}

export default branding
