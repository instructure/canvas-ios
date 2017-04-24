// @flow

import localeSort from '../../utils/locale-sort'

export type AssignmentListDataProps = {
  +pending: number,
  +error?: ?string,
  +courseColor: string,
  +assignmentGroups: AssignmentGroup[],
  +gradingPeriods: Array<GradingPeriod & { assignmentRefs: [string] }>,
}

export type AssignmentListActionProps = {
  +refreshAssignmentList: () => Promise<AssignmentGroup[]>,
  +refreshAssignment: () => Promise<Assignment>,
  +updateAssignment: (courseID: string, updatedAssignment: Assignment, originalAssignment: Assignment) => Promise<Assignment>,
}

export type AssignmentListProps = AssignmentListDataProps
  & RoutingProps
  & AssignmentListActionProps
  & NavProps
  & RefreshProps

type RoutingProps = { +courseID: string }

export function mapStateToProps ({ entities }: AppState, { courseID }: RoutingProps): AssignmentListDataProps {
  const course = entities.courses[courseID]

  if (!course) {
    return {
      assignmentGroups: [],
      pending: 0,
      course: null,
      gradingPeriods: [],
      courseColor: '',
    }
  }

  const courseColor = course.color
  const { refs, pending, error } = course.assignmentGroups
  const groupsByID: AssignmentGroupsState = entities.assignmentGroups
  const assignmentGroupsState = refs
    .map((ref) => groupsByID[ref])
    .sort((a, b) => a.group.position - b.group.position)

  const assignmentGroups: AssignmentGroup[] = assignmentGroupsState.map((groupState) => {
    const groupWithAssignments = Object.assign({}, groupState.group)
    groupWithAssignments.assignments = groupState.assignmentRefs.map((id) => entities.assignments[id].data)
    return groupWithAssignments
  })

  let gradingPeriods = Object.keys(entities.gradingPeriods)
    .map(id => ({
      ...entities.gradingPeriods[id].gradingPeriod,
      assignmentRefs: entities.gradingPeriods[id].assignmentRefs,
    }))
    .sort((gp1, gp2) => localeSort(gp1.title, gp2.title))

  return {
    pending,
    error,
    assignmentGroups,
    gradingPeriods,
    courseColor,
  }
}
