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

/* @flow */

import { mapStateToProps, type AssignmentDueDatesProps } from '../map-state-to-props'

const template = {
  ...require('../../../__templates__/assignments'),
  ...require('../../../__templates__/course'),
  ...require('../../../__templates__/users'),
  ...require('../../../redux/__templates__/app-state'),
  ...require('../../../__templates__/helm'),
}

test('map state to props should work', async () => {
  const user = template.user()
  const course = template.course()
  const dateID = '123344556666'
  const date = template.assignmentDueDate({ id: dateID })
  const override = template.assignmentOverride({
    id: dateID,
    student_ids: [user.id],
  })
  const assignment = template.assignment({
    all_dates: [date],
    overrides: [override],
  })

  let state: AppState = template.appState({
    entities: {
      assignments: {
        [assignment.id]: { data: assignment },
      },
      users: {
        [user.id]: {
          data: user,
        },
      },
      courses: {
        [course.id]: course,
      },
      assignmentGroups: {},
      gradingPeriods: {},
    },
    favoriteCourses: [],
  })

  const props: AssignmentDueDatesProps = {
    courseID: course.id,
    assignment,
    assignmentID: assignment.id,
    users: {},
    refreshUsers: jest.fn(),
    navigator: template.navigator(),
    courseColor: null,
    onEditPressed: jest.fn(),
  }

  let result = mapStateToProps(state, props)
  expect(result).toMatchObject({
    assignment,
    users: {
      [user.id]: user,
    },
  })

  state.entities.users = {}
  result = mapStateToProps(state, props)
  expect(result).toMatchObject({
    assignment,
    users: {},
  })

  state.entities.assignments[assignment.id] = null
  result = mapStateToProps(state, props)
  expect(result).toMatchObject({
    assignment: undefined,
    users: {},
  })
})
