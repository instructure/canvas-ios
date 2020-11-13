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
import { assignments } from '../assignment-entities-reducer'
import { apiResponse, apiError } from '../../../../test/helpers/apiMock'
import { testAsyncReducer } from '../../../../test/helpers/async'
import SubmissionActions from '../../submissions/list/actions'
import { default as QuizDetailsActions } from '../../quizzes/details/actions'
import * as template from '../../../__templates__'

const { refreshSubmissions, refreshSubmissionSummary, getUserSubmissions } = SubmissionActions
const { refreshQuiz } = QuizDetailsActions

test('refresh assignments', async () => {
  const groups = [template.assignmentGroup()]
  const assignment = groups[0].assignments[0]
  let action = AssignmentListActions({ getAssignmentGroups: apiResponse(groups), getAssignments: apiResponse(groups[0].assignments) }).refreshAssignmentList(1, 2)
  let state = await testAsyncReducer(assignments, action)

  expect(state).toEqual([{}, {
    [assignment.id.toString()]: {
      data: assignment,
      submissions: { refs: [], pending: 0 },
      submissionSummary: { data: { graded: 0, ungraded: 0, not_submitted: 0 }, error: null, pending: 0 },
      gradeableStudents: { refs: [], pending: 0 },
    },
  }])
})

test('refresh single assignment', async () => {
  const assignment = template.assignment()
  let action = AssignmentListActions({ getAssignment: apiResponse(assignment) }).refreshAssignment(1, assignment.id)
  let state = await testAsyncReducer(assignments, action)

  expect(state).toMatchObject([
    {
      [assignment.id.toString()]: {
        data: {},
      },
    },
    {
      [assignment.id.toString()]: {
        data: assignment,
      },
    },
  ])
})

test('update assignments', async () => {
  let assignment = template.assignment()
  let action = AssignmentListActions({ updateAssignment: apiResponse(assignment) }).updateAssignment('1', assignment, assignment)
  let state = await testAsyncReducer(assignments, action)

  let a = { [assignment.id]: { pending: 1, error: null, data: { ...assignment } } }
  let b = { [assignment.id]: { pending: 0, error: null, data: { ...assignment } } }

  expect(state).toEqual([a, b])
})

it('update assignments with error', async () => {
  let original = template.assignment()
  let updated = template.assignment({ name: 'foo' })
  let error = '401 error'
  let action = AssignmentListActions({ updateAssignment: apiError({ message: error }) }).updateAssignment('1', updated, original)
  let state = await testAsyncReducer(assignments, action)

  let a = { [updated.id]: { data: { ...updated }, pending: 1, error: null } }
  let b = { [original.id]: { data: { ...original }, pending: 0, error: { data: { errors: [{ message: error }] }, status: 401 } } }

  expect(state).toEqual([a, b])
})

test('reduces assignment content', () => {
  let assignment = template.assignment()

  const data = [
    template.submission({ id: '3' }),
  ].map(override => template.submissionHistory([override]))

  let action = {
    type: refreshSubmissions.toString(),
    payload: { assignmentID: assignment.id, result: { data } },
  }

  let state = {
    [assignment.id]: { data: assignment },
  }

  expect(assignments(state, action)).toEqual({
    [assignment.id]: {
      data: assignment,
      submissions: {
        pending: 0,
        refs: ['3'],
      },
      submissionSummary: { data: { graded: 0, ungraded: 0, not_submitted: 0 }, error: null, pending: 0 },
      gradeableStudents: { pending: 0, refs: [] },
      pending: 0,
      error: null,
    },
  })
})

test('revert assignment update', () => {
  let assignment = template.assignment()

  let action = {
    type: AssignmentListActions().cancelAssignmentUpdate.toString(),
    payload: { originalAssignment: assignment },
  }

  let state = {
    [assignment.id]: { data: assignment },
  }

  let result = assignments(state, action)
  expect(result).toEqual({
    [assignment.id]: {
      data: assignment,
      error: null,
    },
  })
})

test('refreshQuiz', () => {
  const assignment = template.assignment({
    id: '1',
    name: 'Old',
  })
  const initialState = {
    '1': {
      data: assignment,
      pending: 0,
      submissions: { refs: [], pending: 0 },
      submissionSummary: { data: {}, pending: 0, error: null },
      gradeableStudents: { refs: [], pending: 0 },
    },
  }
  const refreshedAssignment = {
    ...assignment,
    name: 'Refreshed',
  }
  const resolved = {
    type: refreshQuiz.toString(),
    payload: {
      result: [{}, {}, { data: refreshedAssignment }],
      courseID: '1',
      quizID: '1',
    },
  }
  expect(
    assignments(initialState, resolved)
  ).toEqual({
    '1': {
      ...initialState['1'],
      data: refreshedAssignment,
    },
  })
})

test('refresh quiz with no assignment', () => {
  const resolved = {
    type: refreshQuiz.toString(),
    payload: {
      result: [{}, {}, { data: null }],
      courseID: '1',
      quizID: '1',
    },
  }
  expect(
    assignments({}, resolved)
  ).toEqual({

  })
})

test('refreshSubmissionSummary', () => {
  const assignment = template.assignment({
    id: '1',
    name: 'Old',
  })
  const submissionSummary = template.submissionSummary({ graded: 1, ungraded: 1, not_submitted: 1 })
  const initialState = {
    '1': {
      data: assignment,
      pending: 0,
      submissions: { refs: [], pending: 0 },
      submissionSummary: { data: {}, pending: 0, error: null },
      gradeableStudents: { refs: [], pending: 0 },
      error: null,
    },
  }

  const resolved = {
    type: refreshSubmissionSummary.toString(),
    payload: {
      result: { data: submissionSummary },
      courseID: '1',
      assignmentID: '1',
    },
  }
  expect(assignments(initialState, resolved)).toEqual({
    '1': {
      ...initialState['1'],
      submissionSummary: { data: submissionSummary, pending: 0, error: null },
    },
  })
})

test('refreshSubmissionSummary with error object', async () => {
  const assignment = template.assignment({ id: '1' })
  const emptySummary = template.submissionSummary({ graded: 0, ungraded: 0, not_submitted: 0 })
  const initialState = {
    '1': {
      data: assignment,
      pending: 0,

      submissions: { refs: [], pending: 0 },
      submissionSummary: { data: {}, pending: 0, error: null },
      gradeableStudents: { refs: [], pending: 0 },
      error: null,
    },
  }

  const error = template.error('summary error')
  const action = {
    type: refreshSubmissionSummary.toString(),
    error: true,
    payload: {
      courseID: '1',
      assignmentID: '1',
      error,
    },
  }

  const state = assignments(initialState, action)

  expect(state).toEqual({
    '1': {
      ...initialState['1'],
      submissionSummary: { data: emptySummary, pending: 0, error: 'summary error' },
    },
  })
})

test('refreshSubmissionSummary with error type', async () => {
  const assignment = template.assignment({ id: '1' })
  const emptySummary = template.submissionSummary({ graded: 0, ungraded: 0, not_submitted: 0 })
  const initialState = {
    '1': {
      data: assignment,
      pending: 0,

      submissions: { refs: [], pending: 0 },
      submissionSummary: { data: {}, pending: 0, error: null },
      gradeableStudents: { refs: [], pending: 0 },
      error: null,
    },
  }

  const error = new TypeError('ouch')
  const action = {
    type: refreshSubmissionSummary.toString(),
    error: true,
    payload: {
      courseID: '1',
      assignmentID: '1',
      error,
    },
  }

  const state = assignments(initialState, action)

  expect(state).toEqual({
    '1': {
      ...initialState['1'],
      submissionSummary: { data: emptySummary, pending: 0, error: 'ouch' },
    },
  })
})

test('refreshSubmissionSummary pending', async () => {
  const assignment = template.assignment({ id: '1' })
  const initialState = {
    '1': {
      data: assignment,
      pending: 0,
      submissions: { refs: [], pending: 0 },
      submissionSummary: { data: {}, pending: 0, error: null },
      gradeableStudents: { refs: [], pending: 0 },
      error: null,
    },
  }

  const action = {
    type: refreshSubmissionSummary.toString(),
    pending: true,
    payload: {
      courseID: '1',
      assignmentID: '1',
    },
  }

  const state = assignments(initialState, action)

  expect(state).toEqual({
    '1': {
      ...initialState['1'],
      submissionSummary: { data: { graded: 0, ungraded: 0, not_submitted: 0 }, pending: 1, error: null },
    },
  })
})

test('getUserSubmissions adds a submission ref to the assignment', () => {
  let assignmentOne = template.assignment({ id: '1' })
  let submissionOne = template.submission({ id: '1', assignment_id: '1' })
  let assignmentTwo = template.assignment({ id: '2' })
  let submissionTwo = template.submission({ id: '2', assignment_id: '2' })

  let action = {
    type: getUserSubmissions.toString(),
    payload: { result: { data: [submissionOne, submissionTwo] } },
  }

  let initialState = {
    '1': {
      data: assignmentOne,
      pending: 0,
      submissions: { refs: [], pending: 0 },
      submissionSummary: { data: {}, pending: 0, error: null },
      gradeableStudents: { refs: [], pending: 0 },
      error: null,
    },
    '2': {
      data: assignmentTwo,
      pending: 0,
      submissions: { refs: [], pending: 0 },
      submissionSummary: { data: {}, pending: 0, error: null },
      gradeableStudents: { refs: [], pending: 0 },
      error: null,
    },
  }

  let newState = assignments(initialState, action)
  expect(newState['1'].submissions.refs[0]).toEqual('1')
  expect(newState['2'].submissions.refs[0]).toEqual('2')
})

test('getUserSubmissions pending', () => {
  let action = {
    type: getUserSubmissions.toString(),
    pending: true,
  }

  let initialState = {}

  let newState = assignments(initialState, action)
  expect(newState).toEqual(initialState)
})
