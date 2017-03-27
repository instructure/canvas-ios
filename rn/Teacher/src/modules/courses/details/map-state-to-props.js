// @flow

import type { TabsProps } from '../tabs/tabs-prop-types'

type RoutingParams = {
  +courseID: string,
}

export type CourseDetailsProps = TabsProps & CourseState

export default function mapStateToProps (state: CoursesAppState, ownProps: RoutingParams): CourseDetailsProps {
  let courseState: CourseState & CourseContentState = state.entities.courses[ownProps.courseID]
  if (!courseState) {
    throw new Error('A Course with id ' + ownProps.courseID + ' was expected')
  }
  const { course, color, tabs } = courseState
  return {
    course,
    color,
    ...tabs,
  }
}
