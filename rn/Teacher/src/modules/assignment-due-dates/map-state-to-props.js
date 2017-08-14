// @flow

import AssignmentDates from '../../common/AssignmentDates'
import Navigator from '../../routing/Navigator'

export type AssignmentDueDatesState = {
  +assignment: Assignment,
  +users: {},
  +courseColor: string,
}

export type AssignmentDueDatesProps = {
  courseID: string,
  assignmentID: string,
  assignment: Assignment,
  users: {},
  refreshUsers: Function,
  navigator: Navigator,
  courseColor: string,
  quizID?: ?string,
}

export type AssignmentDueDatesActionProps = {
  +refreshUsers: () => Promise<User[]>,
}

export function mapStateToProps (state: AppState, ownProps: AssignmentDueDatesProps): AssignmentDueDatesState {
  const assignment = state.entities.assignments[ownProps.assignmentID].data
  const dates = new AssignmentDates(assignment)
  const users = {}
  const courseColor = state.entities.courses[ownProps.courseID].color

  dates.studentIDs().forEach((id) => {
    const user = state.entities.users[id]
    if (user) {
      users[id] = user.data
    }
  })

  return {
    assignment,
    users,
    courseColor,
  }
}
