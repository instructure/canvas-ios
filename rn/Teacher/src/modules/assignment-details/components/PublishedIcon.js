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

/**
 * @flow
 */

import React from 'react'
import { View, Image, StyleSheet } from 'react-native'
import Images from '../../../images'
import i18n from 'format-message'
import { Text } from '../../../common/text'
import colors from '../../../common/colors'

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

const internalStyle = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
  },
  text: {
    marginLeft: 6,
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
