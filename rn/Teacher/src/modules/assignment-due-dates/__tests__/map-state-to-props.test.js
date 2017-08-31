//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
    courseColor: '',
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
})
