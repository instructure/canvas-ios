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

import { AssignmentListActions } from '../actions'
import { default as QuizDetailsActions } from '../../quizzes/details/actions'
import { assignmentGroups } from '../assignment-group-entities-reducer'
import { apiResponse } from '../../../../test/helpers/apiMock'
import { testAsyncReducer } from '../../../../test/helpers/async'
import * as template from '../../../__templates__'

const { refreshQuiz } = QuizDetailsActions

test('refresh assignment groups', async () => {
  const group = template.assignmentGroup()
  let assignmentRefs = group.assignments.map((a) => a.id)

  let action = AssignmentListActions({ getAssignmentGroups: apiResponse([group]), getAssignments: apiResponse(group.assignments) }).refreshAssignmentList(1)
  let state = await testAsyncReducer(assignmentGroups, action)

  delete group.assignments
  expect(state).toEqual([{}, {
    [group.id.toString()]: { group, assignmentRefs },
  }])
})

test('refresh quiz', () => {
  const quiz = template.quiz()
  const group = template.assignmentGroup({
    id: '1',
    name: 'Old',
    overrides: [],
  })
  const initialState = {
    '1': {
      assignmentRefs: ['123'],
      group,
    },
  }
  const refreshedGroup = {
    ...group,
    name: 'Refreshed',
  }
  delete refreshedGroup.assignments
  delete refreshedGroup.overrides
  const resolved = {
    type: refreshQuiz.toString(),
    payload: {
      result: [{}, { data: [refreshedGroup] }],
      courseID: '1',
      quizID: quiz.id,
    },
  }

  delete group.assignments
  expect(
    assignmentGroups(initialState, resolved)
  ).toEqual({
    '1': {
      group: { ...group, name: 'Refreshed' },
      assignmentRefs: ['123'],
    },
  })
})

test('refresh assignment groups returns existing state when there is a gradingPeriodID', async () => {
  const group = template.assignmentGroup()
  let action = AssignmentListActions({ getAssignmentGroups: apiResponse([group]), getAssignments: apiResponse(group.assignments) }).refreshAssignmentList(1, 2)
  let state = await testAsyncReducer(assignmentGroups, action)
  expect(state).toEqual([{}, {}])
})

