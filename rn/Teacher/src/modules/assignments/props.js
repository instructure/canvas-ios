// @flow

export type AssignmentListState = {
  +assignmentGroups: AssignmentGroup[],
  +pending: number,
  +error?: string,
}

export type AssignmentListActionProps = {
  +refreshAssignmentList: () => Promise<AssignmentGroup[]>,
}

export type AssignmentProps = AssignmentListState & AssignmentListActionProps

export interface AppState {
  assignments: AssignmentListState,
}

export function stateToProps (state: AppState): AssignmentListState {
  return state.assignments
}
