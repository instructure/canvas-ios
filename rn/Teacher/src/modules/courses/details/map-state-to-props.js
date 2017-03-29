// @flow

import type { TabsProps } from '../tabs/tabs-prop-types'
import type { CourseListActionProps } from '../course-prop-types'

type RoutingParams = {
  +courseID: string,
}

export type CourseDetailsProps = TabsProps & CourseListActionProps & RoutingParams & { refresh: Function, pending: number, course?: Course, color?: ?string }

export default function mapStateToProps (state: CoursesAppState, ownProps: RoutingParams): CourseDetailsProps {
  let courseState: CourseState & CourseContentState = state.entities.courses[ownProps.courseID] || { tabs: { tabs: [] } }

  const { course, color, tabs } = courseState
  return {
    course,
    color,
    ...tabs,
    pending: state.favoriteCourses.pending,
  }
}
