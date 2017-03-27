// @flow

export type AssignmentListState = {
  +assignmentGroups: AssignmentGroup[],
  +course: Course,
  +pending: number,
  +error?: string,
}

export type AssignmentListProps = {
  courseID: string,
  course: CourseState,
  assignmentGroups: AssignmentGroup[],
  refreshAssignmentList: Function,
  nextPage: Function,
  pending: number,
  navigator: ReactNavigator,
}

export type AssignmentListActionProps = {
  +refreshAssignmentList: () => Promise<AssignmentGroup[]>,
}

export type AssignmentProps = AssignmentListState & AssignmentListActionProps

export function mapStateToProps (state: AppState, ownProps: AssignmentListProps): AssignmentListState {
  const course = state.entities.courses[ownProps.courseID]
  const assignmentGroupsState = course.assignmentGroups
  const assignmentGroupRefs = assignmentGroupsState.refs
  const assignmentGroups = assignmentGroupRefs.map((ref) => state.entities.assignmentGroups[ref]).sort((a, b) => a.position - b.position)

  return {
    ...assignmentGroupsState,
    assignmentGroups,
    course,
  }
}
