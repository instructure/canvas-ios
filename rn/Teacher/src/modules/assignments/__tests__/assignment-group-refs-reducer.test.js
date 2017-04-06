/* @flow */

import { AssignmentListActions } from '../actions'
import { assignmentGroups } from '../assignment-group-refs-reducer'
import { apiResponse, apiError } from '../../../../test/helpers/apiMock'
import { testAsyncReducer } from '../../../../test/helpers/async'

const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
}

test('refresh assignment group refs', async () => {
  const groups = [template.assignmentGroup()]
  let action = AssignmentListActions({ getCourseAssignmentGroups: apiResponse(groups) }).refreshAssignmentList(1)
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
  let action = AssignmentListActions({ getCourseAssignmentGroups: apiResponse(groups) }).refreshAssignmentList(1, 2)
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
  const action = AssignmentListActions({ getCourseAssignmentGroups: apiError({ message: '' }) }).refreshAssignmentList(1, 2)
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
