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
  Image,
} from 'react-native'
import {
  Text,
} from '../../../common/text'
import { colors, createStyleSheet } from '../../../common/stylesheet'

type BubbleProps = {
  message: string,
  from: 'me' | 'them',
  testID: string,
}

export default class ChatBubble extends Component<BubbleProps, any> {
  render () {
    let tintColor
    let fromStyle
    let messageContainer
    let transform = []
    if (this.props.from === 'me') {
      tintColor = colors.electric
      fromStyle = styles.myText
      messageContainer = styles.myMessageContainer
    } else {
      tintColor = colors.backgroundLight
      fromStyle = styles.theirText
      messageContainer = styles.theirMessageContainer
      transform = [{ scaleX: -1 }]
    }

    return (
      <View style={messageContainer}>
        <Image
          source={{ uri: 'chatBubble' }}
          style={[styles.bubble, { tintColor, transform }]}
          capInsets={{ left: 18, right: 18, top: 24, bottom: 16 }}
          resizeMode='stretch'
        />
        <Text style={[styles.message, fromStyle]} testID={this.props.testID}>
          {this.props.message}
        </Text>
      </View>
    )
  }
}

const styles = createStyleSheet(colors => ({
  myText: {
    color: colors.textLightest,
  },
  theirText: {
    color: colors.textDarkest,
  },
  myMessageContainer: {
    maxWidth: 300,
  },
  theirMessageContainer: {
    maxWidth: 300,
  },
  message: {
    paddingHorizontal: 12,
    paddingTop: 12,
    paddingBottom: 8,
    backgroundColor: 'transparent',
  },
  bubble: {
    position: 'absolute',
    margin: 0,
    padding: 0,
    top: -4,
    bottom: 0,
    left: 0,
    right: 0,
    width: null,
    height: null,
  },
}))
