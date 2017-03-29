// @flow

export type AssignmentDetailsState = {
  +assignmentDetails: Assignment,
  +pending: number,
  +error?: string,
}

export type AssignmentDetailsProps = {
  assignmentDetails: Assignment,
  navigator: ReactNavigator,
  courseID: string,
  assignmentID: string,
  error?: string,
  pending?: number,
  refresh: Function,
}

export type AssignmentDetailsActionProps = {
  +refreshAssignmentDetails: (courseID: number, assignmentID: string) => Promise<Assignment>,
}

export function mapStateToProps (state: AppState, ownProps: AssignmentDetailsProps): AssignmentDetailsState {
  const assignment = state.entities.assignments[ownProps.assignmentID]

  return {
    assignmentDetails: assignment,
    ...assignment,
    pending: state.entities.courses[ownProps.courseID].assignmentGroups.pending,
  }
}

