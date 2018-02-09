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
  TouchableWithoutFeedback,
  Animated,
  Dimensions,
} from 'react-native'
import { Text } from '../text'

const INITIAL_SCALE = 0.6

type State = {
  screenWidth: number,
  toolTipLayoutWidth?: number,
  sourcePoint?: { x: number, y: number },
  tip?: string,
}

export default class ToolTip extends Component<{}, State> {
  state: State = { screenWidth: Dimensions.get('window').width }
  opacity: Animated.Value = new Animated.Value(0)
  scale: Animated.Value = new Animated.Value(INITIAL_SCALE)

  onToolTipLayout = ({ nativeEvent }: { nativeEvent: { layout: { width: number }}}) => {
    if (this.state.toolTipLayoutWidth) {
      return // only need to get this once to get the max extent of the text
    }

    this.setState({
      toolTipLayoutWidth: nativeEvent.layout.width,
    })
    Animated.timing(
      this.opacity,
      { toValue: 1, duration: 200 }
    ).start()
    Animated.spring(
      this.scale,
      { toValue: 1, friction: 5, tension: 80 }
    ).start()
  }

  showToolTip = (sourcePoint: { x: number, y: number }, tip: string) => {
    this.setState({ sourcePoint, tip })
  }

  dismissToolTip = () => {
    Animated.timing(
      this.opacity,
      { toValue: 0, duration: 200 },
    ).start(() => {
      this.scale.setValue(INITIAL_SCALE)
      this.setState({
        toolTipLayoutWidth: undefined,
        sourcePoint: undefined,
        tip: undefined,
      })
    })
  }

  onContainerLayout = ({ nativeEvent }: { nativeEvent: { layout: { width: number }}}) => {
    this.setState({ screenWidth: nativeEvent.layout.width })
  }

  render () {
    if (this.state.sourcePoint == null || this.state.tip == null) {
      return null
    }

    let pad = global.style.defaultPadding
    const { x, y } = this.state.sourcePoint
    const { screenWidth, toolTipLayoutWidth } = this.state
    let left = pad - x
    let width // undefined until 1st layout
    if (toolTipLayoutWidth) {
      const tipWidth = Math.min(toolTipLayoutWidth, 600) // readable width
      const paddedWidth = screenWidth - 2 * global.style.defaultPadding
      width = Math.min(paddedWidth, tipWidth)

      if (tipWidth < paddedWidth) {
        const idealLeft = -(tipWidth / 2)
        const maxLeft = (screenWidth - pad - tipWidth) - x
        left = Math.max(left, idealLeft)
        left = Math.min(left, maxLeft)
      }
    }

    return (
      <TouchableWithoutFeedback
        testID='tool-tip.dismiss'
        onPress={this.dismissToolTip}
        onLayout={this.onContainerLayout}
      >
        <View style={styles.container}>
          <Animated.View style={[
            styles.origin,
            {
              left: x,
              top: y,
              transform: [{ scale: this.scale }],
            },
          ]}>
            <View style={styles.arrow} />
            <View style={[styles.toolTip, { left, width }]} onLayout={this.onToolTipLayout}>
              <Text
                numberOfLines={3}
                ellipsizeMode='tail'
                style={{ color: 'white' }}
              >
                {this.state.tip}
              </Text>
            </View>
          </Animated.View>
        </View>
      </TouchableWithoutFeedback>
    )
  }
}

const toolTipColor = '#2D3B45'
const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    zIndex: 2,
  },
  origin: {
    position: 'absolute',
    left: 20,
    right: 20,
    width: 0,
    height: 0,
  },
  arrow: {
    backgroundColor: toolTipColor,
    transform: [{ rotate: '45deg' }],
    position: 'absolute',
    bottom: 8,
    width: 16,
    height: 16,
    left: -8,
  },
  toolTip: {
    position: 'absolute',
    bottom: 9,
    left: -30,
    backgroundColor: toolTipColor,
    borderRadius: 5,
    padding: 4,
    paddingHorizontal: 8,
  },
})
