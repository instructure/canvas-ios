// @flow

import React, { Component } from 'react'
import {
  View,
  Image,
  Text,
  StyleSheet,
} from 'react-native'
import colors from '../colors'

type Props = {
  avatarURL?: string,
  userName: string,
}

export default class Avatar extends Component<any, Props, any> {
  render () {
    if (this.props.avatarURL) {
      return (
        <View style={styles.imageContainer}>
          <Image
            source={{ uri: this.props.avatarURL }}
            style={styles.image}
          />
        </View>
      )
    } else {
      const altText = this.props.userName
      .split(' ')
      .map((word) => word[0])
      .filter((c) => c)
      .reduce((m, c) => m + c)
      .substring(0, 4)
      .toUpperCase()
      return (
        <View style={styles.altImage}>
          <Text style={styles.altImageText}>{altText}</Text>
        </View>
      )
    }
  }
}

const styles = StyleSheet.create({
  imageContainer: {
    height: 40,
    width: 40,
    overflow: 'hidden',
    borderRadius: 20,
  },
  image: {
    height: 40,
    width: 40,
  },
  altImage: {
    height: 40,
    width: 40,
    borderRadius: 20,
    borderColor: colors.seperatorColor,
    borderWidth: StyleSheet.hairlineWidth,
    overflow: 'hidden',
    marginRight: global.style.defaultPadding,
    justifyContent: 'center',
    alignItems: 'center',
  },
})
