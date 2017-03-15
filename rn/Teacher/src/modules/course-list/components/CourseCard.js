// @flow

import React, { Component } from 'react'
import ReactNative, {
  View,
  StyleSheet,
  Image,
  Text,
  TouchableHighlight,
} from 'react-native'

import Images from '../../../images'

type Props = {
  course: Course,
  color: string,
  style: StyleSheet,
  onPress: Function,
  initialHeight?: number,
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

  createImageStyles (): ReactNative.StyleSheet {
    return StyleSheet.flatten([styles.imageColor, {
      backgroundColor: this.props.color,
    }])
  }

  createTitleStyles (): ReactNative.StyleSheet {
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

  render (): React.Element<View> {
    let { course } = this.props
    let style = {
      ...this.props.style,
      height: this.state.height,
    }
    return (
       <TouchableHighlight onLayout={this.onLayout} style={[styles.card, style]} testID={course.course_code} onPress={this.onPress}>
        <View style={styles.cardContainer}>
            <View style={styles.imageWrapper}>
              {course.image_download_url &&
                <Image source={{ uri: course.image_download_url }} style={styles.image} />
              }
              <View style={this.createImageStyles()} />
              <Image style={styles.kabob} source={Images.kabob} />
            </View>
            <View style={styles.titleWrapper}>
              <Text numberOfLines={2} style={this.createTitleStyles()}>{course.name}</Text>
              <Text numberOfLines={1} style={styles.code}>{course.course_code}</Text>
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
    opacity: 0.8,
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
    fontSize: 16,
    fontWeight: '600',
  },
  code: {
    fontSize: 12,
    color: '#8B969D',
    fontWeight: '600',
    marginTop: 2,
  },
})

