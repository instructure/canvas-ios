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

// @flow

import React, { PureComponent } from 'react'
import { View, I18nManager } from 'react-native'
import { createStyleSheet } from '../stylesheet'

export default class DisclosureIndicator extends PureComponent<{}> {
  render () {
    return <View style={[styles.disclosureIndicator, { transform: [{ rotate: I18nManager.isRTL ? '-45deg' : '45deg' }] }]} />
  }
}

const styles = createStyleSheet(colors => ({
  disclosureIndicator: {
    width: 10,
    height: 10,
    marginLeft: 7,
    backgroundColor: 'transparent',
    borderTopWidth: 2,
    borderRightWidth: 2,
    borderColor: colors.borderMedium,
    alignSelf: 'center',
  },
}))
