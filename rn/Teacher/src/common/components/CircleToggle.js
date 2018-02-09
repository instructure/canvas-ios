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

import React, { PureComponent } from 'react'
import {
  TouchableOpacity,
  StyleSheet,
  View,
} from 'react-native'
import branding from '../branding'
import { Heading1 } from '../text'

type Props = {
  on: boolean,
  children?: any,
  style?: any,
  value: any,
  onPress: Function,
  onLongPress?: (value: any, buttonFrame: { x: number, y: number, width: number, height: number }) => void,
  accessibilityLabel?: string,
}

export default class CircleToggle extends PureComponent<Props> {
  buttonViewRef: any

  onPress = () => {
    this.props.onPress(this.props.value)
  }

  onLongPress = () => {
    if (this.buttonViewRef == null) {
      return
    }

    this.buttonViewRef.measure((vx: number, vy: number, width: number, height: number, x: number, y: number) => {
      if (this.props.value != null && this.props.onLongPress) {
        this.props.onLongPress(this.props.value, { x, y, width, height })
      }
    })
  }

  getRef = (ref: any) => {
    this.buttonViewRef = ref
  }

  render () {
    let viewStyle = [circleButtonStyles.container, this.props.style]
    let textStyle = {
      fontWeight: '500',
      color: '#8B969E',
    }
    if (this.props.on) {
      viewStyle.push({
        backgroundColor: branding.primaryBrandColor,
        borderWidth: 0,
      })
      textStyle.color = 'white'
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
            : <Heading1 style={textStyle} accessible={false}>{this.props.children}</Heading1>
          }
        </View>
      </TouchableOpacity>
    )
  }
}

const circleButtonStyles = StyleSheet.create({
  container: {
    borderColor: '#C7CDD1',
    borderWidth: StyleSheet.hairlineWidth,
    minWidth: 48,
    height: 48,
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: 24,
    flex: 1,
    paddingHorizontal: 8,
  },
})
