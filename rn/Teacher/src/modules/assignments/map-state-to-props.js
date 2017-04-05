// @flow

import localeSort from '../../utils/locale-sort'

export type AssignmentListDataProps = {
  +pending: number,
  +error?: ?string,
  +courseColor: string,
  +assignmentGroups: AssignmentGroup[],
  +gradingPeriods: Array<GradingPeriod & { assignmentRefs: [number] }>,
}

export type AssignmentListActionProps = {
  +refreshAssignmentList: () => Promise<AssignmentGroup[]>,
  +updateAssignment: (courseID: string, updatedAssignment: Assignment, originalAssignment: Assignment) => Promise<Assignment>,
}

type Refreshable = {
  refresh: () => void,
}

export type AssignmentListProps = AssignmentListDataProps
  & RoutingProps
  & AssignmentListActionProps
  & NavProps
  & Refreshable

type RoutingProps = { +courseID: string }

export function mapStateToProps ({ entities }: AppState, { courseID }: RoutingProps): AssignmentListDataProps {
  const course = entities.courses[courseID]
  const courseColor = course.color
  const { refs, pending, error } = course.assignmentGroups
  const groupsByID: AssignmentGroupsState = entities.assignmentGroups
  const assignmentGroups = refs
    .map((ref) => groupsByID[ref])
    .sort((a, b) => a.position - b.position)

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
