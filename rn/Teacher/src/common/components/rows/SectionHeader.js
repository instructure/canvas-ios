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
import {
  View,
  StyleSheet,
} from 'react-native'
import { Text } from '../../../common/text'
import color from '../../colors'

type Props = {
  title: string,
  top?: boolean, // Draw a line at the top of the section header. Usually used if the section header is the topmost of the list
  centered?: boolean,
}

export default class SectionHeader extends PureComponent<Props> {
  render () {
    const containerStyle = [
      styles.section,
      styles.bottomHairline,
      this.props.top ? styles.topHairline : undefined,
    ]

    const titleStyles = [
      styles.title,
      this.props.centered ? { textAlign: 'center' } : undefined,
    ]

    return (
      <View style={containerStyle} accessibilityTraits='header'>
        <Text style={titleStyles}>{this.props.title}</Text>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  section: {
    flex: 1,
    backgroundColor: color.grey1,
    justifyContent: 'center',
    paddingLeft: global.style.defaultPadding,
    paddingRight: global.style.defaultPadding / 2,
    paddingVertical: global.style.defaultPadding / 4,
  },
  title: {
    fontSize: 14,
    backgroundColor: color.grey1,
    color: color.grey5,
    fontWeight: '600',
  },
  topHairline: {
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: color.seperatorColor,
  },
  bottomHairline: {
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: color.seperatorColor,
  },
})
