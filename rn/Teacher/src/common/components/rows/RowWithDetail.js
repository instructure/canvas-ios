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

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
} from 'react-native'
import Row, { type RowProps } from './Row'
import { Text } from '../../text'
import branding from '../../branding'

type RowWithSwitchProps = RowProps & {
  detail: string,
  detailTestID?: string,
  detailSelected?: boolean,
}

export default class RowWithDetail extends Component<RowWithSwitchProps, any> {
  render () {
    let detailStyle = this.props.detailSelected ? { color: branding.primaryBrandColor } : {}
    const accessories = (
      <View style={style.accessories}>
        <Text style={detailStyle} numberOfLines={1} testID={this.props.detailTestID}>{this.props.detail}</Text>
        {this.props.accessories}
      </View>
    )
    const accessibilityLabel = this.props.accessibilityLabel || [this.props.title, this.props.detail].filter(l => l).join(', ')
    return <Row {...this.props} accessories={accessories} accessibilityLabel={accessibilityLabel} />
  }
}

const style = StyleSheet.create({
  accessories: {
    flexDirection: 'row',
    alignItems: 'center',
  },
})
