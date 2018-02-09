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

import React, { PureComponent } from 'react'
import { Heading1 } from '../text'
import color from '../colors'
import {
  View,
  StyleSheet,
} from 'react-native'

export default class EditSectionHeader extends PureComponent<*> {
  render () {
    return (
      <View style={[style.container, this.props.style]}>
        <Heading1 style={style.header}>{this.props.title}</Heading1>
        {this.props.children}
      </View>
    )
  }
}

const style = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'flex-start',
    alignItems: 'center',
    height: 'auto',
    backgroundColor: '#F5F5F5',
  },
  header: {
    color: color.darkText,
    marginLeft: global.style.defaultPadding,
    marginTop: global.style.defaultPadding,
    marginBottom: global.style.defaultPadding / 2,
  },
})
