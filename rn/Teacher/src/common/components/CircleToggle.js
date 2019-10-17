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
  TouchableOpacity,
  View,
} from 'react-native'
import { colors, createStyleSheet } from '../stylesheet'
import { Text } from '../text'

type Props = {
  on: boolean,
  children?: any,
  style?: any,
  itemID?: string,
  value: any,
  onPress: Function,
  onLongPress?: (itemID: string, buttonFrame: { x: number, y: number, width: number, height: number }) => void,
  accessibilityLabel?: string,
}

export default class CircleToggle extends PureComponent<Props> {
  buttonViewRef: any

  onPress = () => {
    this.props.onPress(this.props.value, this.props.itemID)
  }

  onLongPress = () => {
    if (this.buttonViewRef == null) {
      return
    }

    this.buttonViewRef.measure((vx: number, vy: number, width: number, height: number, x: number, y: number) => {
      if (this.props.itemID && this.props.onLongPress) {
        this.props.onLongPress(this.props.itemID, { x, y, width, height })
      }
    })
  }

  getRef = (ref: any) => {
    this.buttonViewRef = ref
  }

  render () {
    let viewStyle = [circleButtonStyles.container, this.props.style]
    let textStyle = {
      fontSize: 20,
      fontWeight: '500',
      color: colors.textDark,
    }
    if (this.props.on) {
      viewStyle.push({
        backgroundColor: colors.primary,
        borderWidth: 0,
      })
      textStyle.color = colors.white
    }

    // don't set the longPress if the consumer didn't provide a handler
    const longPress = this.props.onLongPress
      ? this.onLongPress
      : undefined

    let traits = ['button']
    if (this.props.on) {
      traits.push('selected')
    }

    return (
      <TouchableOpacity
        {...this.props}
        accessible
        accessibilityTraits={traits}
        onPress={this.onPress}
        onLongPress={longPress}
      >
        <View style={viewStyle} ref={this.getRef}>
          {typeof this.props.children === 'object'
            ? this.props.children
            : <Text style={textStyle} accessible={false}>{this.props.children}</Text>
          }
        </View>
      </TouchableOpacity>
    )
  }
}

const circleButtonStyles = createStyleSheet((colors, vars) => ({
  container: {
    borderColor: colors.borderMedium,
    borderWidth: vars.hairlineWidth,
    minWidth: 48,
    height: 48,
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: 24,
    flex: 1,
    paddingHorizontal: 8,
  },
}))
