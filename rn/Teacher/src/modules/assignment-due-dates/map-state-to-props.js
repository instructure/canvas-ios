// @flow

import AssignmentDates from '../../common/AssignmentDates'

export type AssignmentDueDatesState = {
  +assignment: Assignment,
  +users: {},
}

export type AssignmentDueDatesProps = {
  assignmentID: string,
  assignment: Assignment,
  users: {},
  refreshUsers: Function,
}

export type AssignmentDueDatesActionProps = {
  +refreshUsers: () => Promise<User[]>,
}

export function mapStateToProps (state: AppState, ownProps: AssignmentDueDatesProps): AssignmentDueDatesState {
  const assignment = state.entities.assignments[ownProps.assignmentID].assignment
  const dates = new AssignmentDates(assignment)
  const users = {}

  dates.studentIDs().forEach((id) => {
    const user = state.entities.users[id]
    if (user) {
      users[id] = user
    }
  })

  return {
    assignment,
    users,
  }
}
