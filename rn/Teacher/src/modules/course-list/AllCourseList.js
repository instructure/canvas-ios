// @flow

import React, { Component, PropTypes } from 'react'
import { Dimensions } from 'react-native'
import { stateToProps } from './props'
import { connect } from 'react-redux'
import CourseList from './components/CourseList'

const { width: deviceWidth } = Dimensions.get('window')

type Props = {
  navigator: ReactNavigator,
  courses: Array<Course>,
  customColors: { [string]: string },
  error?: string,
  pending?: number,
}

export class AllCourseList extends Component {
  props: Props

  selectCourse = (course: Course) => {
    this.props.navigator.push({
      screen: 'teacher.CourseDetails',
      passProps: { course },
      title: course.course_code,
    })
  }

  render (): React.Element<*> {
    return (
      <CourseList
        {...this.props}
        selectCourse={this.selectCourse}
        width={deviceWidth}
      />
    )
  }
}

const courseListShape = PropTypes.shape({
  id: PropTypes.number.isRequired,
  name: PropTypes.string.isRequired,
  course_code: PropTypes.string.isRequired,
  short_name: PropTypes.string,
  color: PropTypes.string,
  image_download_url: PropTypes.string,
}).isRequired

AllCourseList.propTypes = {
  courses: PropTypes.arrayOf(courseListShape).isRequired,
  pending: PropTypes.number,
  error: PropTypes.string,
}

export default connect(stateToProps)(AllCourseList)
