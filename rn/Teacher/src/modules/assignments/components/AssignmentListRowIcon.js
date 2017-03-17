/**
* @flow
*/

import React, { Component, Element } from 'react'
import {
  View,
  Image,
  StyleSheet,
} from 'react-native'

import Images from '../../../images'

type Props = {
  published: true,
}

export default class AssignmentListRowIcon extends Component<any, Props, any> {
  render (): Element<View> {
    const published = this.props.published
    const icon = published ? Images.assignments.published : Images.assignments.unpublished
    const iconStyle = published ? styles.publishedIcon : styles.unpublishedIcon
    return (
      <View style={styles.container}>
        <Image source={Images.course.assignments} style={styles.assignmentIcon} />
        <View style={styles.publishedIconContainer}>
          <Image source={icon} style={iconStyle} />
        </View>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 0,
    height: 32,
    width: 32,
  },
  assignmentIcon: {
    position: 'absolute',
  },
  publishedIconContainer: {
    justifyContent: 'center',
    alignItems: 'center',
    position: 'absolute',
    top: 12,
    left: 12,
    backgroundColor: 'white',
    height: 16,
    width: 16,
    borderRadius: 8,
  },
  publishedIcon: {
    height: 12,
    width: 12,
    tintColor: 'green',
  },
  unpublishedIcon: {
    height: 12,
    width: 12,
    tintColor: 'grey',
  },
})
