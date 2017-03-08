// @flow

import React, { Component } from 'react'
import ReactNative, {
  View,
  StyleSheet,
  Image,
  Text,
  TouchableHighlight,
} from 'react-native'

type Props = {
  course: Course,
  color: string,
  style: StyleSheet,
  onPress: Function,
}

export default class extends Component<*, Props, *> {
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

  render (): React.Element<View> {
    let { course } = this.props
    return (
       <TouchableHighlight style={[styles.card, this.props.style]} onPress={this.props.onPress}>
        <View style={styles.cardContainer}>
            <View style={styles.imageWrapper}>
              <View style={this.createImageStyles()} />
              {course.image_download_url &&
                <Image source={{ uri: course.image_download_url }} style={styles.image} />
              }
              <Image style={styles.kabob} source={require('../../../images/kabob.png')} />
            </View>
            <View style={styles.titleWrapper}>
              <Text numberOfLines={2} style={this.createTitleStyles()}>{course.name}</Text>
              <Text style={styles.code}>{course.course_code}</Text>
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
  },
  cardContainer: {
    flex: 1,
    backgroundColor: 'white',
  },
  imageWrapper: {
    flex: 2,
    justifyContent: 'space-between',
  },
  image: {
    height: 80,
    opacity: 0.2,
    top: -80,
  },
  imageColor: {
    height: 80,
  },
  kabob: {
    position: 'absolute',
    top: 10,
    right: 5,
  },
  titleWrapper: {
    flex: 2,
    marginTop: 20,
    marginHorizontal: 10,
  },
  title: {
    fontSize: 14,
    fontWeight: '500',
  },
  code: {
    fontSize: 11,
    color: '#8B969D',
    fontWeight: '500',
  },
})

