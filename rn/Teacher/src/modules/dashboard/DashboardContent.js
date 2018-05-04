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

// @flow

import * as React from 'react'
import {
  View,
  StyleSheet,
} from 'react-native'

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

const styles = StyleSheet.create({
  shadow: {
    shadowColor: '#000',
    shadowRadius: 1,
    shadowOpacity: 0.2,
    shadowOffset: {
      width: 0,
      height: 1,
    },
    backgroundColor: '#ffffff01',
  },
  content: {
    borderColor: '#e3e3e3',
    borderWidth: StyleSheet.hairlineWidth,
    borderRadius: 4,
    overflow: 'hidden',
    flex: 1,
    backgroundColor: 'white',
  },
})
