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

import React, { PureComponent } from 'react'
import { FormLabel } from '../text'
import {
  View,
  StyleSheet,
} from 'react-native'

/*
  This component is for a form header with a label and additional components to
  the side. If only a label is needed, use FormLabel directly.
*/
export default class EditSectionHeader extends PureComponent<*> {
  render () {
    return (
      <View style={[style.container, this.props.style]}>
        <FormLabel>{this.props.title}</FormLabel>
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
})
