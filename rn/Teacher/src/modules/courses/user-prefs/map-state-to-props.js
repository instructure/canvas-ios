// @flow

export type StateProps = {
  course: Course,
  color: string,
  pending: number,
  error: ?string,
}

export default function stateToProps (state: AppState, ownProps: {courseID: string}): StateProps {
  let course: CourseState = state.entities.courses[ownProps.courseID]
  return {
    course: course.course,
    color: course.color,
    pending: state.favoriteCourses.pending + course.pending,
    error: course.error,
  }
}
