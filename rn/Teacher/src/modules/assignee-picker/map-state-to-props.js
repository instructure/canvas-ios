// @flow

export type AssigneeSearchProps = {
  courseID: string,
  sections: Section[],
  enrollments: Enrollment[],
  onSelection: Function,
  navigator: ReactNavigator,
  refreshSections: Function,
  refreshEnrollments: Function,
}

export default function mapStateToProps (state: AppState, ownProps: AssigneeSearchProps): any {
  const courseID = ownProps.courseID
  const enrollments = Object.values(state.entities.enrollments).filter((item) => {
    // $FlowFixMe
    if (item.course_id !== courseID) return false
    // $FlowFixMe
    if (item.type !== 'StudentEnrollment') return false
    return true
  })

  const sections = Object.values(state.entities.sections).filter((item) => {
    // $FlowFixMe
    return item.course_id === courseID
  })

  return {
    sections,
    enrollments,
  }
}
