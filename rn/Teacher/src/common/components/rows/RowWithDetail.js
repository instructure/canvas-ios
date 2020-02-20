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

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
} from 'react-native'
import Row, { type RowProps } from './Row'
import { Text } from '../../text'
import { colors } from '../../stylesheet'

type RowWithSwitchProps = RowProps & {
  detail: string,
  detailTestID?: string,
  detailSelected?: boolean,
}

export default class RowWithDetail extends Component<RowWithSwitchProps, any> {
  render () {
    let detailStyle = this.props.detailSelected ? { color: colors.primary } : {}
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
