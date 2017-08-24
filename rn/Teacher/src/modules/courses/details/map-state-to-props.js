// @flow

import type { CourseListActionProps } from '../course-prop-types'
import Navigator from '../../../routing/Navigator'

type RoutingParams = {
  +courseID: string,
}

export type CourseDetailsDataProps = {
  +pending: number,
  +error?: ?string,
  +tabs: Array<Tab>,
  +course: Course,
  +color: string,
  +attendanceTabID: ?string,
}

export type CourseDetailsProps = CourseDetailsDataProps
  & CourseListActionProps
  & RoutingParams
  & RefreshProps
  & { navigator: Navigator }

export default function mapStateToProps (state: AppState, { courseID }: RoutingParams): CourseDetailsDataProps {
  let courseState = state.entities.courses[courseID]

  const {
    course,
    color,
  } = courseState

  const pending = state.favoriteCourses.pending +
    courseState.tabs.pending +
    courseState.attendanceTool.pending

  const attendanceTabID = courseState.attendanceTool.tabID

  const availableCourseTabs = ['assignments', 'quizzes', 'discussions', 'announcements', 'people']
  const tabs = courseState.tabs.tabs
    .filter((tab) => availableCourseTabs.includes(tab.id) || (attendanceTabID && tab.id === attendanceTabID && global.v12))
    .sort((t1, t2) => (t1.position - t2.position))
  const error = state.favoriteCourses.error ||
    courseState.tabs.error

  return {
    course,
    color,
    tabs,
    pending,
    error,
    attendanceTabID,
  }
}
