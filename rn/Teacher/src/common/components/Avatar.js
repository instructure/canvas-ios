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

import React, { PureComponent } from 'react'
import {
  View,
  Image,
  Text,
  TouchableHighlight,
  StyleSheet,
} from 'react-native'
import colors from '../colors'
import Images from '../../images'

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
    if (defaults.filter(d => decodeURIComponent(url).includes(d)).length) {
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
      return Images.group
    }

    return null
  }

  render () {
    const url = this.imageURL()
    let source = { uri: url }
    const height = this.props.height || 40
    const width = height
    let borderRadius = Math.round(height / 2)
    const fontSize = Math.round(height / 2.25)
    const replacement = this.replacementImage()
    if (replacement) {
      source = replacement
      borderRadius = 0
    }

    let border = { borderRadius }
    if (this.props.border) {
      border = {
        ...border,
        borderColor: 'white',
        borderStyle: 'solid',
        borderWidth: 4,
      }
    }

    const containerStyles = [styles.imageContainer, { height, width }, { ...border }]
    if (!replacement) {
      containerStyles.push({ backgroundColor: '#F5F5F5' })
    }

    let comp

    if (url) {
      comp = (
        <View style={containerStyles} accessibilityLabel=''>
          <Image
            source={source}
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
        <View style={[styles.altImage, { height, width, borderRadius }]} accessibilityLabel=''>
          <Text style={[styles.altImageText, { fontSize }]} accessible={false}>{altText}</Text>
        </View>
      )
    }

    if (!this.props.onPress) return comp
    return (
      <TouchableHighlight underlayColor='transparent' onPress={this.props.onPress}>
        {comp}
      </TouchableHighlight>
    )
  }
}

const styles = StyleSheet.create({
  imageContainer: {
    overflow: 'hidden',
  },
  altImage: {
    borderColor: colors.seperatorColor,
    borderWidth: StyleSheet.hairlineWidth,
    overflow: 'hidden',
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'white',
  },
  altImageText: {
    color: colors.secondaryButton,
    fontWeight: '600',
    backgroundColor: 'transparent',
  },
})
