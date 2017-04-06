// @flow

type RoutingParams = {
  courseID: string,
}

export type CourseSettingsActionProps = {
  +updateCourse: () => Promise<Course>,
}

export type CourseSettingsProps = CourseState

export function mapStateToProps (state: AppState, ownProps: RoutingParams): CourseSettingsProps {
  let courseState: CourseState = state.entities.courses[ownProps.courseID]
  const { course, color, pending, error } = courseState
  return {
    pending,
    course,
    color,
    error,
  }
}
