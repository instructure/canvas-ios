//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import React, { Component } from 'react'
import {
  View,
  Image,
  Text,
  TouchableOpacity,
} from 'react-native'
import { createStyleSheet } from '../../../common/stylesheet'
import icon from '../../../images/inst-icons'

export default class CommentAttachment extends Component {
  render () {
    let { attachment, from } = this.props
    let fromStyle = from === 'me' ? styles.mine : styles.theirs
    return (
      <TouchableOpacity
        testID={`CommentAttachment-${attachment.id}`}
        key={attachment.id} style={[styles.wrapper, fromStyle]}
        onPress={this.props.onPress}
      >
        <View style={styles.container}>
          <Image
            source={icon('paperclip')}
            resizeMode='contain'
            style={styles.icon}
          />
          <Text
            numberOfLines={1}
            ellipsizeMode='middle'
            style={styles.text}
          >
            {attachment.display_name}
          </Text>
        </View>
      </TouchableOpacity>
    )
  }
}

const styles = createStyleSheet(colors => ({
  mine: {
    justifyContent: 'flex-end',
  },
  theirs: {
    justifyContent: 'flex-start',
  },
  wrapper: {
    flex: 0,
    flexDirection: 'row',
  },
  container: {
    borderColor: colors.borderMedium,
    borderWidth: 1,
    borderRadius: 4,
    marginTop: 8,
    maxWidth: 300,
    tintColor: colors.linkColor,
    flex: 0,
    flexDirection: 'row',
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  icon: {
    flex: 0,
    width: 20,
    tintColor: colors.linkColor,
  },
  text: {
    color: colors.linkColor,
    fontSize: 14,
    fontWeight: '500',
    flex: 0,
    marginLeft: 8,
    marginRight: 12,
  },
}))
