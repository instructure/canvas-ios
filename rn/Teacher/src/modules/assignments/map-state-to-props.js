// @flow

import localeSort from '../../utils/locale-sort'

export type AssignmentListState = {
  +assignmentGroups: AssignmentGroup[],
  +course: Course,
  +pending: number,
  +error?: string,
}

export type AssignmentListProps = {
  courseID: string,
  course: CourseState,
  refreshAssignmentList: Function,
  refreshGradingPeriods: Function,
  assignmentGroups: AssignmentGroup[],
  gradingPeriods: Array<GradingPeriod & { assignmentRefs: [number] }>,
  refresh: Function,
  pending: number,
  navigator: ReactNavigator,
}

export type AssignmentListActionProps = {
  +refreshAssignmentList: () => Promise<AssignmentGroup[]>,
  +updateAssignment: (courseID: string, updatedAssignment: Assignment, originalAssignment: Assignment) => Promise<Assignment>,
}

export function mapStateToProps (state: AppState, ownProps: AssignmentListProps): AssignmentListState {
  const course = state.entities.courses[ownProps.courseID]
  const assignmentGroupsState = course.assignmentGroups
  const assignmentGroupRefs = assignmentGroupsState.refs
  const assignmentGroups = assignmentGroupRefs.map((ref) => state.entities.assignmentGroups[ref]).sort((a, b) => a.position - b.position)

  let gradingPeriods = Object.keys(state.entities.gradingPeriods)
    .map(id => ({
      ...state.entities.gradingPeriods[id].gradingPeriod,
      assignmentRefs: state.entities.gradingPeriods[id].assignmentRefs,
    }))
    .sort((gp1, gp2) => localeSort(gp1.title, gp2.title))

  return {
    ...assignmentGroupsState,
    assignmentGroups,
    course,
    gradingPeriods,
  }
}
