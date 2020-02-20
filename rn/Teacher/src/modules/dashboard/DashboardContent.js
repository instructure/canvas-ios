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

import * as React from 'react'
import {
  View,
} from 'react-native'
import { createStyleSheet } from '../../common/stylesheet'

export default ({ children, style, contentStyle, hideShadow, ...props }: {
  children?: React.Node,
  style?: any,
  contentStyle?: any,
  hideShadow?: boolean,
}) => (
  <View {...props} style={[!hideShadow && styles.shadow, style]}>
    <View style={[styles.content, contentStyle]}>
      {children}
    </View>
  </View>
)

const styles = createStyleSheet((colors, vars) => ({
  shadow: {
    shadowColor: '#000',
    shadowRadius: 1,
    shadowOpacity: 0.2,
    shadowOffset: {
      width: 0,
      height: 1,
    },
  },
  content: {
    borderColor: colors.borderLight,
    borderWidth: vars.hairlineWidth,
    borderRadius: 4,
    overflow: 'hidden',
    flex: 1,
    backgroundColor: colors.backgroundLightest,
  },
}))
