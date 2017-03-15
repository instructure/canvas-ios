/**
 * @flow
 */

import color from '../common/colors'

export type BrandingConfiguration = {
  linkColor?: string,
  navBgColor?: string,
  navButtonColor?: string,
  primaryButtonColor?: string,
  primaryButtonTextColor?: string,
  fontColorDark?: string,
  headerImage?: any,
}

export const branding: BrandingConfiguration = {
  linkColor: color.link,
  navBgColor: color.navBarBg,
  navButtonColor: color.primaryButtonText,
  primaryButtonTextColor: color.primaryButtonText,
  primaryButtonColor: color.primaryButton,
  fontColorDark: '#000',
  headerImage: './src/images/canvas-logo.png',
}

export function setupBrandingFromNativeBrandingInfo (obj: Object): void {
  branding.linkColor = obj[`ic-link-color`] || branding.linkColor
  branding.navBgColor = obj[`ic-brand-global-nav-bgd`] || branding.navBgColor
  branding.primaryButtonTextColor = obj[`ic-brand-button--primary-text`] || branding.primaryButtonTextColor
  branding.primaryButtonColor = obj[`ic-brand-button--primary-bgd`] || branding.primaryButtonColor
  branding.fontColorDark = obj[`ic-brand-font-color-dark`] || branding.fontColorDark
  branding.navButtonColor = obj[`ic-brand-global-nav-ic-icon-svg-fill`] || branding.navButtonColor
}

export default branding
