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

import { AssignmentListActions } from '../actions'
import { assignments } from '../assignment-entities-reducer'
import { apiResponse, apiError } from '../../../../test/helpers/apiMock'
import { testAsyncReducer } from '../../../../test/helpers/async'
import SubmissionActions from '../../submissions/list/actions'
import { default as QuizDetailsActions } from '../../quizzes/details/actions'
import { default as DiscussionDetailsActions } from '../../discussions/details/actions'

const { refreshSubmissions, refreshSubmissionSummary, getUserSubmissions } = SubmissionActions
const { refreshQuiz } = QuizDetailsActions
const { refreshDiscussionEntries } = DiscussionDetailsActions
const template = {
  ...require('../../../__templates__/assignments'),
  ...require('../../../__templates__/submissions'),
  ...require('../../../__templates__/error'),
}

test('refresh assignments', async () => {
  const groups = [template.assignmentGroup()]
  const assignment = template.assignment()
  let action = AssignmentListActions({ getAssignmentGroups: apiResponse(groups) }).refreshAssignmentList(1, 2)
  let state = await testAsyncReducer(assignments, action)

  expect(state).toEqual([{}, {
    [assignment.id.toString()]: {
      data: assignment,
      submissions: { refs: [], pending: 0 },
      submissionSummary: { data: { graded: 0, ungraded: 0, not_submitted: 0 }, error: null, pending: 0 },
      gradeableStudents: { refs: [], pending: 0 },
      pendingComments: {},
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
      pendingComments: {},
      anonymousGradingOn: false,
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
      pendingComments: {},
      anonymousGradingOn: false,
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

test('anonymousGrading', () => {
  const assignment = template.assignment({
    id: '1',
    name: 'Old',
  })
  let actions = AssignmentListActions()
  let state = {
    '1': {
      anonymousGradingOn: false,
      data: assignment,
      pending: 0,
      submissions: { refs: [], pending: 0 },
      submissionSummary: { data: {}, pending: 0, error: null },
      gradeableStudents: { refs: [], pending: 0 },
      pendingComments: {},
    },
  }
  let action = {
    type: actions.anonymousGrading,
    payload: {
      courseID: '1',
      assignmentID: '1',
      anonymous: true,
    },
  }
  expect(assignments(state, action)).toMatchObject({
    '1': {
      anonymousGradingOn: true,
    },
  })
})

test('refreshDiscussionEntries', () => {
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
      pendingComments: {},
      anonymousGradingOn: false,
    },
  }
  const refreshedAssignment = {
    ...assignment,
    name: 'Refreshed',
  }
  const resolved = {
    type: refreshDiscussionEntries.toString(),
    payload: {
      result: [{}, {}, { data: refreshedAssignment }],
      courseID: '1',
      discussionID: '1',
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

test('refreshDiscussionEntries with no assignment', () => {
  const assignment = null
  const initialState = {
    '1': {
      data: assignment,
      pending: 0,
      submissions: { refs: [], pending: 0 },
      submissionSummary: { data: {}, pending: 0, error: null },
      gradeableStudents: { refs: [], pending: 0 },
      pendingComments: {},
      anonymousGradingOn: false,
    },
  }
  const refreshedAssignment = null
  const resolved = {
    type: refreshDiscussionEntries.toString(),
    payload: {
      result: [{}, {}, { data: refreshedAssignment }],
      courseID: '1',
      discussionID: '1',
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
      pendingComments: {},
      anonymousGradingOn: false,
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

test('refreshSubmissionSummary with error', async () => {
  const assignment = template.assignment({ id: '1' })
  const emptySummary = template.submissionSummary({ graded: 0, ungraded: 0, not_submitted: 0 })
  const initialState = {
    '1': {
      data: assignment,
      pending: 0,

      submissions: { refs: [], pending: 0 },
      submissionSummary: { data: {}, pending: 0, error: null },
      gradeableStudents: { refs: [], pending: 0 },
      pendingComments: {},
      anonymousGradingOn: false,
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
      submissionSummary: { data: emptySummary, pending: 0, error: error },
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
      pendingComments: {},
      anonymousGradingOn: false,
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
      pendingComments: {},
      anonymousGradingOn: false,
      error: null,
    },
    '2': {
      data: assignmentTwo,
      pending: 0,
      submissions: { refs: [], pending: 0 },
      submissionSummary: { data: {}, pending: 0, error: null },
      gradeableStudents: { refs: [], pending: 0 },
      pendingComments: {},
      anonymousGradingOn: false,
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
