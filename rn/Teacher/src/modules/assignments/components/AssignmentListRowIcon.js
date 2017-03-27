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
import i18n from 'format-message'

type Props = {
  published: true,
  tintColor: string,
}

export default class AssignmentListRowIcon extends Component<any, Props, any> {
  render (): Element<View> {
    const published = this.props.published
    const icon = published ? Images.assignments.published : Images.assignments.unpublished
    const iconStyle = published ? styles.publishedIcon : styles.unpublishedIcon
    const accessibilityLabel = published ? i18n('Published') : i18n('Not Published')
    return (
      <View style={styles.container} accessibilityLabel={accessibilityLabel}>
        <Image source={Images.course.assignments} style={[styles.assignmentIcon, { tintColor: this.props.tintColor }]} />
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
    width: 46,
    alignItems: 'center',
  },
  assignmentIcon: {
    position: 'absolute',
  },
  publishedIconContainer: {
    justifyContent: 'center',
    alignItems: 'center',
    position: 'absolute',
    top: 10,
    left: 20,
    backgroundColor: 'white',
    height: 16,
    width: 16,
    borderRadius: 8,
  },
  publishedIcon: {
    height: 12,
    width: 12,
    tintColor: '#00AC18',
  },
  unpublishedIcon: {
    height: 12,
    width: 12,
    tintColor: '#8B969E',
  },
})
