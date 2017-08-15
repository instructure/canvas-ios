// @flow

import React, { PureComponent } from 'react'
import { View, Image, StyleSheet } from 'react-native'
import { Text } from '../../common/text'
import images from '../../images'
import i18n from 'format-message'

export default class EmptyAttachments extends PureComponent {
  render () {
    return (
      <View style={styles.container}>
        <Image style={styles.image} source={images.attachment80} />
        <Text style={styles.title}>{i18n('No Attachments')}</Text>
        <Text style={styles.text}>
          {i18n('Add an attachment by tapping the plus at the top right.')}
        </Text>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 50,
    height: 400,
  },
  image: {
    marginBottom: 36,
  },
  title: {
    fontSize: 24,
    fontWeight: '600',
    textAlign: 'center',
    marginBottom: 4,
  },
  text: {
    color: '#8B969E',
    fontSize: 16,
    textAlign: 'center',
  },
})

