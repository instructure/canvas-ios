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

import React, { PureComponent } from 'react'
import {
  View,
  Image,
  Text,
  TouchableHighlight,
} from 'react-native'
import { colors, createStyleSheet } from '../stylesheet'
import icon from '../../images/inst-icons'
import i18n from 'format-message'

type Props = {
  avatarURL?: ?string,
  userName: string,
  height?: number, // Width will always be equal to the height
  border?: boolean,
  onPress?: Function,
}

export default class Avatar extends PureComponent<Props, any> {
  // Checks for the crappy default profile picture from canvas
  // If it's one of those things, returns null
  imageURL = () => {
    const url = this.props.avatarURL
    if (!url) return null

    // There are a few different forms that the default picture can take
    const defaults = ['images/dotted_pic.png', 'images/messages/avatar-50.png']
    if (defaults.some(d => decodeURIComponent(url).includes(d))) {
      return null
    }

    return url
  }

  // Provides a replacement image if one exists for a url
  replacementImage = () => {
    const url = this.props.avatarURL
    if (!url) return null

    const group = 'images/messages/avatar-group-50.png'
    if (url.includes(group)) {
      return icon('group', 'line')
    }

    return null
  }

  render () {
    const uri = this.imageURL()
    const height = this.props.height || 40
    const width = height
    let borderRadius = Math.round(height / 2)
    const fontSize = Math.round(height / 2.25)
    const replacement = this.replacementImage()

    const style = {
      backgroundColor: replacement
        ? colors.backgroundLightest
        : colors.backgroundLight,
      borderRadius,
      height,
      width,
    }
    if (this.props.border) {
      style.borderColor = colors.backgroundLightest
      style.borderStyle = 'solid'
      style.borderWidth = 4
    }

    let comp
    if (replacement) {
      comp = (
        <View style={[styles.imageContainer, style]} accessibilityLabel=''>
          <View style={[styles.group, { height, width, borderRadius }]}>
            <Image
              source={replacement}
              style={{ height: height * 0.6, width: width * 0.6, tintColor: colors.textDark }}
            />
          </View>
        </View>
      )
    } else if (uri) {
      comp = (
        <View style={[styles.imageContainer, style]} accessibilityLabel=''>
          <Image
            source={{ uri }}
            style={{ height, width }}
          />
        </View>
      )
    } else {
      const altText = this.props.userName
        ? this.props.userName
          .split(' ')
          .map((word) => word[0])
          .filter((c) => c)
          .reduce((m, c) => m + c, '')
          .substring(0, 2)
          .toUpperCase()
        : ''

      comp = (
        <View style={[styles.altImage, { height, width, borderRadius }]}>
          <Text style={[styles.altImageText, { fontSize }]} accessible={false}>{altText}</Text>
        </View>
      )
    }

    if (!this.props.onPress) return comp
    return (
      <TouchableHighlight
        underlayColor='transparent'
        onPress={this.props.onPress}
        accessibilityLabel={i18n('{name} Profile', { name: this.props.userName || '' })}
        accessibilityTraits='button'
      >
        {comp}
      </TouchableHighlight>
    )
  }
}

const styles = createStyleSheet((colors, vars) => ({
  imageContainer: {
    overflow: 'hidden',
  },
  group: {
    borderColor: colors.borderMedium,
    borderWidth: vars.hairlineWidth,
    justifyContent: 'center',
    alignItems: 'center',
  },
  altImage: {
    borderColor: colors.borderMedium,
    borderWidth: vars.hairlineWidth,
    overflow: 'hidden',
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: colors.backgroundLightest,
  },
  altImageText: {
    color: colors.textDark,
    fontWeight: '600',
    backgroundColor: 'transparent',
  },
}))
