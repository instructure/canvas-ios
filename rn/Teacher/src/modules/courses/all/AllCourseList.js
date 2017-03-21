// @flow

import React, { Component, PropTypes } from 'react'
import { Dimensions } from 'react-native'
import i18n from 'format-message'
import mapStateToProps from './map-state-to-props'
import { connect } from 'react-redux'
import CourseList from '../components/CourseList'
import type { CourseProps } from '../course-prop-types'
import { route } from '../../../routing/'

const { width: deviceWidth } = Dimensions.get('window')

type Props = {
  navigator: ReactNavigator,
  courses: Array<CourseProps>,
  error?: string,
  pending?: number,
}

export class AllCourseList extends Component {
  props: Props

  constructor (props: Props) {
    super(props)

    props.navigator.setTitle({
      title: i18n({
        default: 'All Courses',
        description: `The title of the screen showing all of a teacher's courses`,
      }),
    })
  }

  selectCourse = (course: Course) => {
    this.props.navigator.push(route(`/courses/${course.id}`))
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

const coursePropsShape = PropTypes.shape({
  id: PropTypes.number.isRequired,
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

let Connected = connect(mapStateToProps)(AllCourseList)
export default (Connected: Component<any, Props, any>)
