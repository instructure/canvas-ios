/* @flow */

import { AssignmentListActions } from '../actions'
import { default as QuizDetailsActions } from '../../quizzes/details/actions'
import { assignmentGroups } from '../assignment-group-refs-reducer'
import { apiResponse, apiError } from '../../../../test/helpers/apiMock'
import { testAsyncReducer } from '../../../../test/helpers/async'

const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/quiz'),
}

const { refreshQuiz } = QuizDetailsActions

test('refresh assignment group refs', async () => {
  const groups = [template.assignmentGroup()]
  let action = AssignmentListActions({ getAssignmentGroups: apiResponse(groups) }).refreshAssignmentList(1)
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
  let action = AssignmentListActions({ getAssignmentGroups: apiResponse(groups) }).refreshAssignmentList(1, 2)
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
  const action = AssignmentListActions({ getAssignmentGroups: apiError({ message: '' }) }).refreshAssignmentList(1, 2)
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
      result: [{ data: [group] }, { data: quiz }],
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
