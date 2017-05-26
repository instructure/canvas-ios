/**
 * @flow
 */

import React from 'react'
import { View, Image, StyleSheet } from 'react-native'
import Images from '../../../images'
import i18n from 'format-message'
import { Text } from '../../../common/text'
import colors from '../../../common/colors'

export default class PublishedIcon extends React.Component {
  render (): React.Element<*> {
    let { published, style, iconSize } = this.props

    const publishedIcon = published ? Images.published : Images.unpublished

    let iconStyle = published ? internalStyle.publishedIcon : internalStyle.unpublishedIcon
    let customStyle = {}
    if (iconSize) {
      customStyle = { width: iconSize, height: iconSize }
    }

    let unpublishedText = i18n('Unpublished')

    let publishedText = i18n('Published')

    return (
      <View style={[ style, internalStyle.container ]}>
        <Image source={publishedIcon} style={[iconStyle, customStyle]}/>
        <Text style={[internalStyle.text, published ? internalStyle.publishedTextStyle : internalStyle.unPublishedTextStyle]}>{(published) ? publishedText : unpublishedText}</Text>
      </View>
    )
  }
}

const iconSize = 21

const internalStyle = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
  },
  text: {
    marginLeft: 5,
    fontWeight: '500',
    color: colors.grey4,
  },
  publishedTextStyle: { color: colors.checkmarkGreen },
  unPublishedTextStyle: { color: colors.grey4 },
  publishedIcon: {
    height: iconSize,
    width: iconSize,
    tintColor: colors.checkmarkGreen,
  },
  unpublishedIcon: {
    height: iconSize,
    width: iconSize,
    tintColor: colors.grey4,
  },
})
