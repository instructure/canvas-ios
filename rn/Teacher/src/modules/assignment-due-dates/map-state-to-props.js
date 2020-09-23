//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
  const users = {}
  const assignment = state.entities.assignments[ownProps.assignmentID]?.data
  const dates = assignment && new AssignmentDates(assignment)
  const courseColor = state.entities.courses[ownProps.courseID]?.color

  dates?.studentIDs().forEach((id) => {
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
