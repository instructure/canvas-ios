// @flow

import React, { Component } from 'react'
import ReactNative, {
  TouchableHighlight,
  View,
  Text,
  StyleSheet,
  Image,
} from 'react-native'
import branding from '../../../../common/branding'
import Images from '../../../../images/'

type Props = {
  course: Course,
  isFavorite: boolean,
  onPress: (courseID: string, favorited: boolean) => Promise<any>,
}

export default class CourseFavorite extends Component<void, Props, void> {
  onPress = (event: ReactNative.NativeSyntheticEvent<ReactNative.NativeTouchEvent>) => {
    this.props.onPress(this.props.course.id, !this.props.isFavorite)
  }

  render (): React.Element<TouchableHighlight> {
    return (
      <TouchableHighlight style={styles.courseRow} testID={this.props.course.course_code} onPress={this.onPress}>
        <View style={styles.courseWrapper}>
          <Image source={this.props.isFavorite ? Images.starFilled : Images.starLined} style={[styles.favoritesImage, { tintColor: branding.primaryBrandColor }]} />
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
    width: 20,
    height: 20,
  },
})
