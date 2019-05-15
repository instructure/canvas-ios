//
// Copyright (C) 2017-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow

import { StyleSheet } from 'react-native'
import color, { isDark } from '../common/colors'

export type Brand = {
  buttonPrimaryBackground: string,
  buttonPrimaryText: string,
  buttonSecondaryBackground: string,
  buttonSecondaryText: string,
  fontColorDark: string,
  headerImageBackground: string,
  headerImageUrl: ?string,
  linkColor: string,
  navBackground: string,
  navBadgeBackground: string,
  navBadgeText: string,
  navIconFill: string,
  navIconFillActive: string,
  navTextColor: string,
  navTextColorActive: string,
  primary: string,
}

export type BrandingConfiguration = {
  link: string,
  navBarColor: string,
  navBarButtonColor: string,
  navBarTextColor: string,
  primaryButtonColor: string,
  primaryButtonTextColor: string,
  primaryBrandColor: string,
  fontColorDark: string,
  headerImage?: any,
}

export const branding: BrandingConfiguration = {
  link: color.link,
  navBarColor: color.navBarColor,
  navBarButtonColor: color.primaryButtonText,
  navBarTextColor: color.primaryButtonText,
  primaryButtonTextColor: color.primaryButtonText,
  primaryButtonColor: color.primaryButton,
  fontColorDark: '#000',
  headerImage: require('../images/canvas-logo.png'),
  primaryBrandColor: color.navBarColor,
}

const updates = []
export function setupBrandingFromNativeBrandingInfo (obj: Brand) {
  branding.link = obj.linkColor
  branding.navBarColor = obj.navBackground
  branding.primaryButtonTextColor = obj.buttonPrimaryText
  branding.primaryButtonColor = obj.buttonPrimaryBackground
  branding.fontColorDark = obj.fontColorDark
  branding.navBarButtonColor = obj.navIconFill
  branding.navBarTextColor = obj.navTextColor
  branding.primaryBrandColor = obj.primary
  branding.headerImage = obj.headerImageUrl || branding.headerImage

  //  now that we have branding data, set colors object as well
  color.link = branding.link
  color.navBarColor = branding.navBarColor
  color.navBarButtonColor = branding.navBarButtonColor
  color.navBarTextColor = branding.navBarTextColor
  color.primaryButtonTextColor = branding.primaryButtonTextColor
  color.primaryButtonColor = branding.primaryButtonColor
  color.primaryBrandColor = branding.primaryBrandColor
  color.statusBarStyle = isDark(color.navBarColor) ? 'light' : 'default'

  // update style sheets
  for (const update of updates) update(color)
}

type Styles = {[string]: Object}
export function createStyleSheet<S: Styles> (factory: (typeof color) => S) {
  const sheet = StyleSheet.create(factory(color))
  updates.push(color => Object.assign(sheet, StyleSheet.create(factory(color))))
  return sheet
}

export default branding
