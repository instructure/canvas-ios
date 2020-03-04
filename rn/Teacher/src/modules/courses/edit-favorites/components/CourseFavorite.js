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

import React, { Component } from 'react'
import {
  TouchableHighlight,
  View,
  Image,
} from 'react-native'
import { colors, createStyleSheet } from '../../../../common/stylesheet'
import icon from '../../../../images/inst-icons'
import { Text } from '../../../../common/text'

type Props = {
  course: Course | Group,
  isFavorite: boolean,
  onPress: (contextID: string, favorited: boolean) => Promise<any>,
}

export default class CourseFavorite extends Component<Props> {
  onPress = () => {
    this.props.onPress(this.props.course.id, !this.props.isFavorite)
  }

  render () {
    return (
      <TouchableHighlight
        style={styles.courseRow}
        testID={'edit-favorites.course-favorite.' + this.props.course.id + (this.props.isFavorite ? '-favorited' : '-not-favorited') }
        onPress={this.onPress}
        accessibilityRole='button'
        accessibilityStates={ this.props.isFavorite ? [ 'selected' ] : []}
      >
        <View style={styles.courseWrapper}>
          <Image
            source={icon('star', this.props.isFavorite ? 'solid' : 'line')}
            style={[styles.favoritesImage, { tintColor: colors.primary }]}
          />
          <Text style={styles.courseName}>{this.props.course.name}</Text>
        </View>
      </TouchableHighlight>
    )
  }
}

const styles = createStyleSheet(colors => ({
  courseRow: {
    borderBottomWidth: 1,
    borderBottomColor: colors.borderMedium,
  },
  courseWrapper: {
    paddingHorizontal: 16,
    paddingVertical: 16,
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.backgroundLightest,
  },
  courseName: {
    marginRight: 16,
    fontWeight: '500',
  },
  favoritesImage: {
    marginRight: 10,
    width: 20,
    height: 20,
  },
}))
