//
// Copyright (C) 2016-present Instructure, Inc.
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

/**
 * @flow
 */

import { processColor } from 'react-native'

const colors = {
  link: '#008EE2',
  tabBarBg: '#fff',
  tabBarTab: '#73818C',
  navBarBg: '#374A59',
  darkText: '#2D3B45',
  lightText: '#7F91A7',
  grey1: '#f5f5f5', //  procelain
  grey2: '#C7CDD1', //  tiara
  grey3: '#A5AFB5', //  heather
  grey4: '#8B969E', //  ash
  grey5: '#73818C', // some dark grey color
  primaryButton: '#368BD8',
  primaryButtonText: '#fff',
  secondaryButton: '#73818C',
  checkmarkGreen: '#00AC18',
  seperatorColor: '#C7CDD1',
  errorAnnouncementBg: '#EE0612',
  inviteAnnouncementBg: '#00AC18',
  warningAnnouncementBg: '#FC5E13',
  //  branding properties
  navBarColor: '#374A59',
  navBarButtonColor: '#374A59',
  navBarTextColor: '#374A59',
  primaryButtonTextColor: 'white',
  primaryButtonColor: '#374A59',
  primaryBrandColor: '#374A59',
  destructiveButtonColor: '#EE0612',
  statusBarStyle: 'light', // set to contrast with navBarColor
}

export default colors

export function isDark (color: string): boolean {
  const c = processColor(color) || 0
  const yiq = (
    ((c >> 16) & 0xFF) * 299 +
    ((c >> 8) & 0xFF) * 587 +
    (c & 0xFF) * 114
  ) / 1000
  return yiq < 128
}
