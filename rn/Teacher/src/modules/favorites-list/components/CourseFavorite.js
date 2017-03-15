// @flow

import React, { Component } from 'react'
import ReactNative, {
  TouchableHighlight,
  View,
  Text,
  StyleSheet,
  Image,
} from 'react-native'
import colors from '../../../common/colors'

type Props = {
  course: Course,
  onPress: (courseId: string, favorited: boolean) => Promise<any>,
}

const STAR_FILLED = require('../../../images/star-filled.png')
const STAR_LINED = require('../../../images/star-lined.png')

export default class CourseFavorite extends Component<void, Props, void> {
  onPress = (event: ReactNative.NativeSyntheticEvent<ReactNative.NativeTouchEvent>) => {
    this.props.onPress(this.props.course.id.toString(), !this.props.course.is_favorite)
  }

  render (): React.Element<TouchableHighlight> {
    return (
      <TouchableHighlight style={styles.courseRow} testID={this.props.course.course_code} onPress={this.onPress}>
        <View style={styles.courseWrapper}>
          <Image source={this.props.course.is_favorite ? STAR_FILLED : STAR_LINED} style={styles.favoritesImage} />
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
    fontSize: 16,
    fontWeight: '400',
    marginRight: 16,
  },
  favoritesImage: {
    marginRight: 10,
    tintColor: colors.prettyBlue,
    width: 20,
    height: 20,
  },
})
