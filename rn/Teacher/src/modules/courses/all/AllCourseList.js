// @flow

import React, { Component, PropTypes } from 'react'
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
    this.props.navigator.show(`/courses/${course.id}`)
  }

  render (): React.Element<*> {
    return (
      <Screen
        navBarTranslucent={true}
        navBarColor={branding.navBarColor}
        navBarStyle='dark'
        title={i18n({
          default: 'All Courses',
          description: `The title of the screen showing all of a teacher's courses`,
        })}>
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
export default (Connected: Component<any, Props, any>)
