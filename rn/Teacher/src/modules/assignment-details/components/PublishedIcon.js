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

/**
 * @flow
 */

import React from 'react'
import { View, Image } from 'react-native'
import Images from '../../../images'
import i18n from 'format-message'
import { Text } from '../../../common/text'
import { createStyleSheet } from '../../../common/stylesheet'

export default class PublishedIcon extends React.Component<Object> {
  render () {
    let { published, style, iconSize } = this.props

    const publishedIcon = published ? Images.published : Images.unpublished

    let iconStyle = published ? internalStyle.publishedIcon : internalStyle.unpublishedIcon
    let statusID = published ? 'published' : 'unpublished'
    let customStyle = {}
    if (iconSize) {
      customStyle = { width: iconSize, height: iconSize }
    }

    let unpublishedText = i18n('Unpublished')

    let publishedText = i18n('Published')

    return (
      <View style={[ style, internalStyle.container ]}>
        <Image
          source={publishedIcon}
          style={[iconStyle, customStyle]}
          testID={`assignment-details.published-icon.${statusID}-status-img`}
        />
        <Text
          style={[internalStyle.text, published ? internalStyle.publishedTextStyle : internalStyle.unPublishedTextStyle]}
          testID='assignment-details.published-icon.publish-status-lbl'
        >
          {(published) ? publishedText : unpublishedText}
        </Text>
      </View>
    )
  }
}

const iconSize = 21

const internalStyle = createStyleSheet(colors => ({
  container: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
  },
  text: {
    marginLeft: 6,
    fontWeight: '500',
    color: colors.textDark,
  },
  publishedTextStyle: { color: colors.textSuccess },
  unPublishedTextStyle: { color: colors.textDark },
  publishedIcon: {
    height: iconSize,
    width: iconSize,
    tintColor: colors.textSuccess,
  },
  unpublishedIcon: {
    height: iconSize,
    width: iconSize,
    tintColor: colors.textDark,
  },
}))
