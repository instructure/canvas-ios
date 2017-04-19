// @flow

import type { CourseListActionProps } from '../course-prop-types'

type RoutingParams = {
  +courseID: string,
}

export type CourseDetailsDataProps = {
  +pending: number,
  +error?: ?string,
  +tabs: Array<Tab>,
  +course: Course,
  +color: string,
}

export type CourseDetailsProps = CourseDetailsDataProps
  & CourseListActionProps
  & RoutingParams
  & RefreshProps

export default function mapStateToProps (state: AppState, { courseID }: RoutingParams): CourseDetailsDataProps {
  let courseState = state.entities.courses[courseID]

  const {
    course,
    color,
  } = courseState

  const pending = state.favoriteCourses.pending +
    courseState.tabs.pending
  const tabs = courseState.tabs.tabs
  const error = state.favoriteCourses.error ||
    courseState.tabs.error

  return {
    course,
    color,
    tabs,
    pending,
    error,
  }
}
