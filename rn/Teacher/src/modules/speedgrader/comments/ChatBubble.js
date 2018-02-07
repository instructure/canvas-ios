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
  Image,
} from 'react-native'
import {
  Text,
} from '../../../common/text'
import images from '../../../images'
import colors from '../../../common/colors'

type BubbleProps = {
  message: string,
  from: 'me' | 'them',
}

export default class ChatBubble extends Component<BubbleProps, any> {
  render () {
    let image
    let fromStyle
    let messageContainer
    if (this.props.from === 'me') {
      image = images.speedGrader.chatBubbleMe
      fromStyle = styles.myText
      messageContainer = styles.myMessageContainer
    } else {
      image = images.speedGrader.chatBubbleThem
      fromStyle = styles.theirText
      messageContainer = styles.theirMessageContainer
    }

    return (
      <View style={messageContainer}>
        <Image
          source={image}
          style={styles.bubble}
          capInsets={{ left: 18, right: 18, top: 24, bottom: 16 }}
          resizeMode='stretch'
        />
        <Text style={[styles.message, fromStyle]}>
          {this.props.message}
        </Text>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  myText: {
    color: 'white',
  },
  theirText: {
    color: colors.darkText,
  },
  myMessageContainer: {
    flex: 1,
    maxWidth: 300,
  },
  theirMessageContainer: {
    flex: 1,
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
})
