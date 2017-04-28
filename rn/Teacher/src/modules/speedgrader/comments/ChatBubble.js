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

export default class ChatBubble extends Component<any, BubbleProps, any> {
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
    maxWidth: 300,
    alignSelf: 'flex-end',
  },
  theirMessageContainer: {
    maxWidth: 300,
    alignSelf: 'flex-start',
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
