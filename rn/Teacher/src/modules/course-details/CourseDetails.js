/**
* Launching pad for navigation for a single course
* @flow
*/

import React, { Component } from 'react'
import {
  View,
  Text,
  StyleSheet,
} from 'react-native'

import i18n from 'format-message'

type Props = {
  course: Course,
}

export default class CourseDetails extends Component<any, Props, any> {

  static navigatorStyle = {
    drawUnderNavBar: true,
    navBarTranslucent: true,
    navBarTransparent: true,
  }

  static navigatorButtons = {
    rightButtons: [{
      title: i18n({
        default: 'Edit',
        description: 'Shown at the top of the course details screen.',
      }),
    }],
  }
  editCourse () {
  }

  render (): React.Element<View> {
    return (
      <View style={styles.container}>
        <View style={styles.header}>
          <View style={styles.headerImageContainer}>
            <View style={[styles.headerImageOverlay, { backgroundColor: this.props.course.color }]} />
          </View>

          <Text style={styles.headerTitle}>{this.props.course.name}</Text>
          <Text style={styles.headerSubtitle}>{this.props.course.course_code}</Text>
        </View>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: 10,
    paddingTop: 64,
    height: 200,
  },
  headerTitle: {
    flex: 1,
    backgroundColor: 'transparent',
    color: 'white',
    fontWeight: 'bold',
    fontSize: 24,
    textAlign: 'center',
  },
  headerSubtitle: {
    flex: 1,
    color: 'white',
    backgroundColor: 'transparent',
    fontWeight: '200',
  },
  headerImageContainer: {
    position: 'absolute',
    backgroundColor: 'green',
    right: 0,
    left: 0,
    top: 0,
    bottom: 0,
  },
  headerImageOverlay: {
    position: 'absolute',
    opacity: 0.75,
    right: 0,
    left: 0,
    top: 0,
    bottom: 0,
  },
  editCourseButton: {
    backgroundColor: 'transparent',
    position: 'absolute',
    right: 100,
  },
})
