// @flow

import React, { Component } from 'react'
import ReactNative, {
  TouchableHighlight,
  View,
  StyleSheet,
  Image,
} from 'react-native'
import colors from '../../../../common/colors'
import Images from '../../../../images/'
import { Text } from '../../../../common/text'

type Props = {
  course: Course,
  isFavorite: boolean,
  onPress: (courseID: string, favorited: boolean) => Promise<any>,
}

export default class CourseFavorite extends Component<void, Props, void> {
  onPress = (event: ReactNative.NativeSyntheticEvent<ReactNative.NativeTouchEvent>) => {
    this.props.onPress(this.props.course.id, !this.props.isFavorite)
  }

  render () {
    return (
      <TouchableHighlight style={styles.courseRow} testID={'edit-fav-courses.' + this.props.course.id + (this.props.isFavorite ? '-favorited' : '-not-favorited') } onPress={this.onPress}>
        <View style={styles.courseWrapper}>
          <Image source={this.props.isFavorite ? Images.starFilled : Images.starLined} style={[styles.favoritesImage, { tintColor: colors.primaryBrandColor }]} />
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
