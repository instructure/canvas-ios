//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
import { Text } from '../../../common/text'
import icon from '../../../images/inst-icons'
import { createStyleSheet } from '../../../common/stylesheet'
import A11yGroup from '../../../common/components/A11yGroup'
import { type CourseGradeInfo } from '../../../utils/course-grades'

type Props = {
  course: Course,
  grade: ?CourseGradeInfo,
  showGrade?: boolean,
  color: string,
  hideOverlay: boolean,
  style: ViewStyleProp,
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
    let opacity = 1
    let backgroundColor = this.props.color

    if (this.props.course.image_download_url) {
      if (this.props.hideOverlay) {
        backgroundColor = undefined
      } else {
        opacity = 0.8
      }
    }

    return StyleSheet.flatten([styles.imageColor, {
      backgroundColor,
      opacity,
    }])
  }

  createTitleStyles () {
    return StyleSheet.flatten([styles.title, {
      color: this.props.color,
    }])
  }

  createKabobWrapperStyles () {
    return StyleSheet.flatten([styles.kabobWrapper, {
      backgroundColor: this.props.hideOverlay ? this.props.color : undefined,
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
    const enrollment = course.enrollments && course.enrollments.find(e => e.type === 'student')
    const hideTotalGrade = course.hide_final_grades || (
      enrollment && enrollment.has_grading_periods &&
      enrollment.totals_for_all_grading_periods_option === false &&
      enrollment.current_grading_period_id == null
    )
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
          style={[styles.card, this.props.style, { height: this.state.height }]}
          testID={'DashboardCourseCell.' + course.id}
          onPress={this.onPress}
          accessibilityTraits='button'
          accessibilityLabel={`${course.name} ${gradeDisplay || ''}`.trim()}
          underlayColor='transparent'
        >
          <View style={styles.cardContainer}>
            <View style={styles.imageWrapper}>
              {Boolean(course.image_download_url) &&
                <Image source={{ uri: course.image_download_url }} style={styles.image} />
              }
              <View style={this.createImageStyles()} />
              { showGrade &&
                <View style={styles.gradePill}>
                  {hideTotalGrade ? (
                    <Image
                      source={icon('lock', 'solid')}
                      style={[ styles.gradeLock, { tintColor: this.props.color } ]}
                      testID={`course-${course.id}-grades-locked`}
                    />
                  ) : (
                    <Text
                      numberOfLines={2}
                      style={[styles.gradeText, { color: this.props.color }]}>
                      { gradeDisplay }
                    </Text>
                  )}
                </View>
              }
            </View>
            <View style={styles.titleWrapper} accessible={false}>
              <Text numberOfLines={2} style={this.createTitleStyles()} accessible={false}>
                {course.name}
              </Text>
              <Text numberOfLines={1} style={styles.code} accessible={false}>{course.course_code}</Text>
            </View>
          </View>
        </TouchableHighlight>
        <TouchableHighlight
          style={styles.kabobButton}
          onPress={this.onCoursePreferencesPressed}
          accessibilityTraits='button'
          accessible={true}
          accessibilityLabel={i18n('Open {courseName} user preferences', { courseName: course.name })}
          underlayColor='#ffffff00'
          testID={`DashboardCourseCell.${course.id}.optionsButton`}
        >
          <View style={this.createKabobWrapperStyles()}>
            <Image style={styles.kabob} source={icon('more')} />
          </View>
        </TouchableHighlight>
      </A11yGroup>
    )
  }
}

const styles = createStyleSheet((colors, vars) => ({
  card: {
    height: 160,
  },
  cardContainer: {
    borderColor: colors.borderLight,
    borderWidth: vars.hairlineWidth,
    borderRadius: 4,
    shadowColor: '#000',
    shadowRadius: 1,
    shadowOpacity: 0.2,
    shadowOffset: {
      width: 0,
      height: 1,
    },
    flex: 1,
    backgroundColor: colors.backgroundLightest,
  },
  imageWrapper: {
    borderTopLeftRadius: 4,
    borderTopRightRadius: 4,
    overflow: 'hidden',
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
    top: 8,
    right: 8,
    width: 43,
    height: 43,
  },
  kabobWrapper: {
    position: 'absolute',
    top: 6,
    right: 4,
    padding: 4,
    borderRadius: 15,
  },
  kabob: {
    width: 18,
    height: 18,
    tintColor: colors.backgroundLightest,
  },
  titleWrapper: {
    flex: 1,
    paddingHorizontal: 10,
  },
  title: {
    marginTop: 8,
    fontSize: 18,
    fontWeight: '600',
  },
  code: {
    fontSize: 12,
    color: colors.textDark,
    marginTop: 2,
    fontWeight: '600',
  },
  gradePill: {
    flex: 1,
    maxWidth: 120,
    backgroundColor: colors.backgroundLightest,
    position: 'absolute',
    top: 8,
    left: 8,
    paddingLeft: 6,
    paddingRight: 6,
    borderRadius: 14,
  },
  gradeText: {
    fontSize: 14,
    fontWeight: '600',
  },
  gradeLock: {
    height: 14,
    marginVertical: 3,
    width: 14,
  },
}))
