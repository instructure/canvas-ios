// @flow

export type AssignmentDetailsState = {
  +assignmentDetails: Assignment,
  +pending: number,
  +error?: string,
}

export type AssignmentDetailsActionProps = {
  +refreshAssignmentDetails: (courseID: number, assignmentID: number) => Promise<Assignment>,
}

export type AssignmentProps = AssignmentDetailsState & AssignmentDetailsActionProps

export interface AppState {
  assignmentDetails: AssignmentDetailsState,
}

export function stateToProps (state: AppState): AssignmentDetailsState {
  return state.assignmentDetails
}
