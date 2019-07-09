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
import { assignmentGroups } from '../assignment-group-refs-reducer'
import { apiResponse, apiError } from '../../../../test/helpers/apiMock'
import { testAsyncReducer } from '../../../../test/helpers/async'
import * as template from '../../../__templates__'

const { refreshQuiz } = QuizDetailsActions

test('refresh assignment group refs', async () => {
  const groups = [template.assignmentGroup()]
  let action = AssignmentListActions({ getAssignmentGroups: apiResponse(groups), getAssignments: apiResponse(groups[0].assignments) }).refreshAssignmentList(1)
  let state = await testAsyncReducer(assignmentGroups, action)

  expect(state).toEqual([
    {
      pending: 1,
      refs: [],
    },
    {
      pending: 0,
      refs: groups.map((group) => group.id),
    },
  ])
})

test('refresh assignment group refs doesnt update refs when a grading period id is provided', async () => {
  const groups = [template.assignmentGroup()]
  let action = AssignmentListActions({ getAssignmentGroups: apiResponse(groups), getAssignments: apiResponse(groups[0].assignments) }).refreshAssignmentList(1, 2)
  let state = await testAsyncReducer(assignmentGroups, action)

  expect(state).toEqual([
    {
      pending: 1,
      refs: [],
    },
    {
      pending: 0,
      refs: [],
    },
  ])
})

test('assignment list with error', async () => {
  const action = AssignmentListActions({ getAssignmentGroups: apiError({ message: '' }), getAssignments: apiError({ message: '' }) }).refreshAssignmentList(1, 2)
  const state = await testAsyncReducer(assignmentGroups, action)
  expect(state).toEqual([{
    pending: 1,
    refs: [],
  }, {
    pending: 0,
    refs: [],
    error: 'Could not get list of assignments',
  }])
})

test('refresh quiz', () => {
  const quiz = template.quiz()
  const group = template.assignmentGroup({ id: '43' })
  const initialState = {
    refs: [],
  }
  const resolved = {
    type: refreshQuiz.toString(),
    payload: {
      result: [{ data: quiz }, { data: [group] }],
      courseID: '1',
      quizID: quiz.id,
    },
  }
  expect(
    assignmentGroups(initialState, resolved)
  ).toEqual({
    refs: [group.id],
  })
})
