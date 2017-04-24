// @flow

export type AssignmentDetailsState = {
  +assignmentDetails: Assignment,
  +pending: number,
  +error?: ?string,
}

export type AssignmentDetailsProps = {
  assignmentDetails: Assignment,
  navigator: ReactNavigator,
  courseID: string,
  assignmentID: string,
  error?: any,
  pending?: number,
  updateAssignment: Function,
  refreshAssignment: (courseID: string, assignmentID: string) => Promise<Assignment>,
} & RefreshProps

export function mapStateToProps (state: AppState, ownProps: AssignmentDetailsProps): AssignmentDetailsState {
  const assignment = state.entities.assignments[ownProps.assignmentID].data

  return {
    assignmentDetails: assignment,
    pending: state.entities.courses[ownProps.courseID].assignmentGroups.pending,
  }
}

export function updateMapStateToProps (state: AppState, ownProps: AssignmentDetailsProps): AssignmentDetailsState {
  const assignment = state.entities.assignments[ownProps.assignmentID].data

  return {
    assignmentDetails: assignment,
    pending: state.entities.assignments[ownProps.assignmentID].pending,
    error: state.entities.assignments[ownProps.assignmentID].error,
  }
}
