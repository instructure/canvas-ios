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
  NativeEventEmitter,
  NativeModules,
  processColor,
  StyleSheet,
} from 'react-native'
import { updateColors } from './inst-colors'

export const colors = {}
// add all style guide colors
updateColors(colors, 'light', 'normal')
// add all branding colors
Object.assign(colors, {
  buttonPrimaryBackground: colors.electric,
  buttonPrimaryText: colors.white,
  buttonSecondaryBackground: colors.licorice,
  buttonSecondaryText: colors.white,
  fontColorDark: colors.licorice,
  headerImageBackground: colors.oxford,
  linkColor: colors.electric,
  navBackground: colors.oxford,
  navBadgeBackground: colors.electric,
  navBadgeText: colors.white,
  navIconFill: colors.white,
  navIconFillActive: colors.electric,
  navTextColor: colors.white,
  navTextColorActive: colors.electric,
  primary: colors.electric,
})

export const vars = {
  absoluteFill: StyleSheet.absoluteFill,
  absoluteFillObject: StyleSheet.absoluteFillObject,
  hairlineWidth: StyleSheet.hairlineWidth,
  padding: 16,
  tabBarHeight: 49,
}

export function isDark (color) {
  const c = processColor(color) || 0
  const yiq = (
    ((c >> 16) & 0xFF) * 299 +
    ((c >> 8) & 0xFF) * 587 +
    (c & 0xFF) * 114
  ) / 1000
  return yiq < 128
}

export function setupBranding (brand) {
  Object.assign(colors, brand)
  updateStyleSheets()
}

const updates = []
export function createStyleSheet (factory) {
  const sheet = StyleSheet.create(factory(colors, vars))
  updates.push(colors => Object.assign(sheet,
    StyleSheet.create(factory(colors, vars))
  ))
  return sheet
}

function updateStyleSheets () {
  for (const update of updates) update(colors)
}

const Manager = NativeModules.WindowTraitsManager
const emitter = new NativeEventEmitter(Manager)
const updater = traits => {
  const { style, contrast } = traits.window
  updateColors(colors, style, contrast)
  updateStyleSheets()
}
emitter.addListener('Update', updater)
Manager.currentWindowTraits(updater)
