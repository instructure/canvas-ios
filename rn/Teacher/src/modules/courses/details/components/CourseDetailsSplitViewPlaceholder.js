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
  View,
  Image,
} from 'react-native'
import { Text } from '../../../../common/text'
import Screen from '../../../../routing/Screen'
import instIcon from '../../../../images/inst-icons'
import { createStyleSheet } from '../../../../common/stylesheet'

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
            <Image source={instIcon('courses')} style={style.icon} resizeMode='contain' />
            <Text style={style.courseName}>{course.name}</Text>
            <Text style={style.term}>{courseCode}</Text>
          </View>
        </View>
      </Screen>
    )
  }
}

const style = createStyleSheet(colors => ({
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
    tintColor: colors.borderMedium,
  },
  courseName: {
    fontWeight: '500',
    fontSize: 24,
    marginTop: 32,
    color: colors.textDarkest,
  },
  term: {
    marginTop: 4,
    color: colors.textDark,
    fontWeight: '600',
  },
}))
