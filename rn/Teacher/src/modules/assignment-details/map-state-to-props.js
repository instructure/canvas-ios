// @flow

export type AssignmentDetailsState = {
  +assignmentDetails: Assignment,
  +pending: number,
  +error?: string,
}

export type AssignmentDetailsProps = {
  assignmentDetails: Assignment,
  navigator: any,
  courseID: string,
  assignmentID: string,
  refreshAssignmentDetails: () => void,
  error?: string,
  pending?: number,
}

export type AssignmentDetailsActionProps = {
  +refreshAssignmentDetails: (courseID: number, assignmentID: string) => Promise<Assignment>,
}

export function mapStateToProps (state: AppState, ownProps: AssignmentDetailsProps): AssignmentDetailsState {
  const assignment = state.entities.assignments[ownProps.assignmentID]

  return {
    assignmentDetails: assignment,
    ...assignment,
  }
}

