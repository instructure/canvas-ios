//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
  Image,
  TouchableHighlight,
} from 'react-native'
import i18n from 'format-message'
import { Text, Heading1 } from '../../../common/text'
import Images from '../../../images'
import A11yGroup from '../../../common/components/A11yGroup'
import { type CourseGradeInfo } from '../../../utils/course-grades'

type Props = {
  course: Course,
  grade: ?CourseGradeInfo,
  showGrade?: boolean,
  color: string,
  style: any,
  onPress: Function,
  initialHeight?: number,
  onCoursePreferencesPressed: (courseId: string) => void,
}

type State = {
  height: number,
}

export default class CourseCard extends Component<Props, State> {
  state: State = {
    height: this.props.initialHeight || 0,
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
    // *if* we are supplied with height and width, no need to calculate our height
    if (this.props.height && this.props.width) { return }
    this.setState({
      height: event.nativeEvent.layout.width,
    })
  }

  onPress = () => {
    this.props.onPress(this.props.course)
  }

  onCoursePreferencesPressed = (): void => {
    this.props.onCoursePreferencesPressed(this.props.course.id)
  }

  render () {
    const { course, grade, showGrade } = this.props
    const style = {
      ...this.props.style,
      height: this.state.height,
    }
    let gradeDisplay = null
    if (showGrade) {
      if (grade && grade.currentDisplay) {
        gradeDisplay = grade.currentDisplay
      } else {
        gradeDisplay = i18n('N/A')
      }
    }
    return (
      <A11yGroup>
        <TouchableHighlight
          onLayout={this.onLayout}
          style={[styles.card, style]}
          testID={'course-' + course.id}
          onPress={this.onPress}
          accessible={false}
          underlayColor='transparent'
        >
          <View style={styles.cardContainer}>
            <View style={styles.imageWrapper}>
              {Boolean(course.image_download_url) &&
                <Image source={{ uri: course.image_download_url }} style={styles.image} />
              }
              <View style={this.createImageStyles()}
                accessible={true}
                accessibilityTraits='button'
                accessibilityLabel={`${course.name} ${gradeDisplay || ''}`}
              />
              { showGrade &&
                <View style={styles.gradePill}>
                  <Heading1
                    numberOfLines={2}
                    style={[styles.gradeText, { color: this.props.color }]}>
                    { gradeDisplay }
                  </Heading1>
                </View>
              }
              <TouchableHighlight
                style={styles.kabobButton}
                onPress={this.onCoursePreferencesPressed}
                accessibilityTraits='button'
                accessible={true}
                accessibilityLabel={i18n('Open {courseName} user preferences', { courseName: course.name })}
                underlayColor='#ffffff00'
                testID={`course-card.kabob-${course.id}`}
              >
                <Image style={styles.kabob} source={Images.kabob} />
              </TouchableHighlight>
            </View>
            <View style={styles.titleWrapper} accessible={false}>
              <Text numberOfLines={2} style={this.createTitleStyles()} accessible={false}>
                {course.name}
              </Text>
              <Text numberOfLines={1} style={styles.code} accessible={false}>{course.course_code}</Text>
            </View>
          </View>
        </TouchableHighlight>
      </A11yGroup>
    )
  }
}

const styles = StyleSheet.create({
  card: {
    height: 160,
  },
  cardContainer: {
    borderColor: '#e3e3e3',
    borderWidth: StyleSheet.hairlineWidth,
    borderRadius: 4,
    shadowColor: '#000',
    shadowRadius: 1,
    shadowOpacity: 0.2,
    shadowOffset: {
      width: 0,
      height: 1,
    },
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
    borderTopLeftRadius: 4,
    borderTopRightRadius: 4,
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
  gradePill: {
    flex: 1,
    maxWidth: 120,
    backgroundColor: 'white',
    position: 'absolute',
    top: 8,
    left: 8,
    paddingLeft: 6,
    paddingRight: 6,
    borderRadius: 8,
  },
  gradeText: {
    fontSize: 14,
  },
})
