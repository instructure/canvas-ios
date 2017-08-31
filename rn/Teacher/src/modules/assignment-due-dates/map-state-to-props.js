//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

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
