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
import PropTypes from 'prop-types'
import { Dimensions } from 'react-native'
import i18n from 'format-message'
import mapStateToProps from './map-state-to-props'
import { connect } from 'react-redux'
import CourseList from '../components/CourseList'
import type { CourseProps } from '../course-prop-types'
import CoursesActions from '../actions'
import refresh from '../../../utils/refresh'
import Navigator from '../../../routing/Navigator'
import Screen from '../../../routing/Screen'
import branding from '../../../common/branding'

const { width: deviceWidth } = Dimensions.get('window')

type Props = {
  navigator: Navigator,
  courses: Array<CourseProps>,
  error?: string,
  pending?: number,
} & RefreshProps

export class AllCourseList extends Component {
  props: Props

  openUserPreferences = (courseId: string) => {
    this.props.navigator.show(`/courses/${courseId}/user_preferences`, { modal: true })
  }

  selectCourse = (course: Course) => {
    this.props.navigator.show(`/courses/${course.id}`, { modal: true })
  }

  render () {
    return (
      <Screen
        navBarColor={branding.navBarColor}
        navBarStyle='dark'
        title={i18n('All Courses')}>
        <CourseList
          {...this.props}
          selectCourse={this.selectCourse}
          width={deviceWidth}
          onCoursePreferencesPressed={this.openUserPreferences}
          onRefresh={this.props.refresh}
        />
      </Screen>
    )
  }
}

const coursePropsShape = PropTypes.shape({
  id: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  course_code: PropTypes.string.isRequired,
  short_name: PropTypes.string,
  color: PropTypes.string,
  image_download_url: PropTypes.string,
})

AllCourseList.propTypes = {
  courses: PropTypes.arrayOf(coursePropsShape).isRequired,
  pending: PropTypes.number,
  error: PropTypes.string,
}

let Refreshed = refresh(
  props => props.refreshCourses(),
  props => props.courses.length === 0,
  props => Boolean(props.pending)
)(AllCourseList)
let Connected = connect(mapStateToProps, CoursesActions)(Refreshed)
export default (Connected: Component<Props, any>)
