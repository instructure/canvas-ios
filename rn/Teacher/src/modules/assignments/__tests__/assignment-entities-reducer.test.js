/* @flow */

import { AssignmentListActions } from '../actions'
import { assignments } from '../assignment-entities-reducer'
import { apiResponse, apiError } from '../../../../test/helpers/apiMock'
import { testAsyncReducer } from '../../../../test/helpers/async'
import SubmissionActions from '../../submissions/list/actions'
import { default as QuizDetailsActions } from '../../quizzes/details/actions'

const { refreshSubmissions } = SubmissionActions
const { refreshQuiz } = QuizDetailsActions
const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/submissions'),
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
        pending: -1,
        refs: ['3'],
      },
      pending: 0,
      error: null,
      pendingComments: {},
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
      pendingComments: {},
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
