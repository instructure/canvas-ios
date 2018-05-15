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
  View,
  StyleSheet,
  Image,
} from 'react-native'
import { Text } from '../../../../common/text'
import Screen from '../../../../routing/Screen'
import Images from '../../../../images/'
import colors from '../../../../common/colors'

export default class CourseDetailsSplitViewPlaceholder extends Component<*> {
  render () {
    const courseColor = this.props.courseColor
    const course = this.props.course || {}
    const courseCode = course.course_code || ''

    return (
      <Screen
        navBarColor={courseColor}
        navBarStyle='dark'
      >
        <View style={style.container}>
          <View style={style.subContainer}>
            <Image source={Images.course.placeholder} style={style.icon} resizeMode='contain' />
            <Text style={style.courseName}>{course.name}</Text>
            <Text style={style.term}>{courseCode}</Text>
          </View>
        </View>
      </Screen>
    )
  }
}

const style = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    flexDirection: 'column',
  },
  subContainer: {
    marginTop: -64,
    alignItems: 'center',
    justifyContent: 'center',
    flexDirection: 'column',
  },
  icon: {
    width: 80,
    height: 80,
    tintColor: colors.grey2,
  },
  courseName: {
    fontWeight: '500',
    fontSize: 24,
    marginTop: 32,
    color: colors.darkText,
  },
  term: {
    marginTop: 4,
    color: colors.grey4,
    fontWeight: '600',
  },
})
