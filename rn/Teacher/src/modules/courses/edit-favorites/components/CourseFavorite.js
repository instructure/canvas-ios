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

import React, { Component } from 'react'
import {
  TouchableHighlight,
  View,
  StyleSheet,
  Image,
} from 'react-native'
import colors from '../../../../common/colors'
import Images from '../../../../images/'
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
        accessibilityTraits={this.props.isFavorite ? ['selected', 'button'] : ['button']}
      >
        <View style={styles.courseWrapper}>
          <Image
            source={this.props.isFavorite ? Images.starFilled : Images.starLined}
            style={[styles.favoritesImage, { tintColor: colors.primaryBrandColor }]}
          />
          <Text style={styles.courseName}>{this.props.course.name}</Text>
        </View>
      </TouchableHighlight>
    )
  }
}

const styles = StyleSheet.create({
  courseRow: {
    borderBottomWidth: 1,
    borderBottomColor: '#e3e3e3',
  },
  courseWrapper: {
    paddingHorizontal: 16,
    paddingVertical: 16,
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'white',
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
})
