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

export default class CourseDetailsSplitViewPlaceholder extends Component {
  render (): React.Element<*> {
    const courseColor = this.props.courseColor
    const course = this.props.course

    return (
      <Screen
        navBarColor={courseColor}
        navBarStyle='dark'
      >
        <View style={style.container}>
          <Image source={Images.course.placeholder} style={style.icon} />
          <Text style={style.courseName}>{course.name}</Text>
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
  icon: {
    width: 80,
    height: 80,
    tintColor: colors.grey2,
  },
  courseName: {
    fontWeight: '500',
    fontSize: 24,
    marginTop: 24,
    color: colors.darkText,
  },
})
