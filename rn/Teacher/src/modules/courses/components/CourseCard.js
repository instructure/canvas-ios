// @flow

import React, { Component } from 'react'
import ReactNative, {
  View,
  StyleSheet,
  Image,
  TouchableHighlight,
} from 'react-native'
import i18n from 'format-message'
import { Text } from '../../../common/text'
import Images from '../../../images'

type Props = {
  course: Course,
  color: string,
  style: any,
  onPress: Function,
  initialHeight?: number,
  onCoursePreferencesPressed: (courseId: string) => void,
}

type State = {
  height: number,
}

export default class CourseCard extends Component {
  props: Props
  state: State

  constructor (props: Props) {
    super(props)

    this.state = {
      height: props.initialHeight || 0,
    }
  }

  createImageStyles () {
    return StyleSheet.flatten([styles.imageColor, {
      backgroundColor: this.props.color,
      opacity: this.props.course.image_download_url ? 0.8 : 1,
    }])
  }

  createTitleStyles () {
    return StyleSheet.flatten([styles.title, {
      color: this.props.color,
    }])
  }

  onLayout = (event: any) => {
    this.setState({
      height: event.nativeEvent.layout.width,
    })
  }

  onPress = (event: ReactNative.NativeSyntheticEvent): void => {
    this.props.onPress(this.props.course)
  }

  onCoursePreferencesPressed = (): void => {
    this.props.onCoursePreferencesPressed(this.props.course.id)
  }

  render () {
    let { course } = this.props
    let style = {
      ...this.props.style,
      height: this.state.height,
    }
    return (
      <TouchableHighlight
        onLayout={this.onLayout}
        style={[styles.card, style]}
        testID={course.course_code}
        onPress={this.onPress}
        accessible={false}
      >
        <View style={styles.cardContainer}>
            <View style={styles.imageWrapper}>
              {Boolean(course.image_download_url) &&
                <Image source={{ uri: course.image_download_url }} style={styles.image} />
              }
              <View style={this.createImageStyles()}
                accessible={true}
                accessibilityTraits='button'
                accessibilityLabel={course.name}
              />
              <TouchableHighlight
                style={styles.kabobButton}
                onPress={this.onCoursePreferencesPressed}
                accessibilityTraits='button'
                accessible={true}
                accessibilityLabel={i18n('Open {courseName} user preferences', { courseName: course.name })}
                underlayColor='#ffffff00'
                testID={`courseCard.kabob_${course.id}`}
              >
                <Image style={styles.kabob} source={Images.kabob} />
              </TouchableHighlight>
            </View>
            <View style={styles.titleWrapper} accessible={false}>
              <Text numberOfLines={2} style={this.createTitleStyles()} accessible={false}>{course.name}</Text>
              <Text numberOfLines={1} style={styles.code} accessible={false}>{course.course_code}</Text>
            </View>
          </View>
        </TouchableHighlight>
    )
  }
}

const styles = StyleSheet.create({
  card: {
    borderColor: '#e3e3e3',
    borderWidth: StyleSheet.hairlineWidth,
    height: 160,
    shadowColor: '#000',
    shadowRadius: 1,
    shadowOpacity: 0.2,
    shadowOffset: {
      width: 0,
      height: 1,
    },
    borderRadius: 4,
    overflow: 'hidden',
    backgroundColor: '#000',
  },
  cardContainer: {
    flex: 1,
    backgroundColor: 'white',
  },
  imageWrapper: {
    flex: 1,
  },
  image: {
    flex: 1,
  },
  imageColor: {
    position: 'absolute',
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
  },
  kabobButton: {
    position: 'absolute',
    top: 0,
    right: 0,
    width: 43,
    height: 43,
  },
  kabob: {
    position: 'absolute',
    top: 10,
    right: 8,
    width: 18,
    height: 18,
  },
  titleWrapper: {
    flex: 1,
    paddingHorizontal: 10,
  },
  title: {
    marginTop: 8,
    fontWeight: '600',
  },
  code: {
    fontSize: 12,
    color: '#8B969D',
    marginTop: 2,
    fontWeight: '600',
  },
})

