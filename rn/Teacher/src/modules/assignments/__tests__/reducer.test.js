/* @flow */

import { AssignmentListActions } from '../actions'
import reducer from '../reducer'
import { apiResponse } from '../../../../test/helpers/apiMock'
import { testAsyncReducer } from '../../../../test/helpers/async'

const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
}

test('refresh assignment list', async () => {
  const groups = [template.assignmentGroup()]
  let action = AssignmentListActions({ getCourseAssignmentGroups: apiResponse(groups) }).refreshAssignmentList(1, 2)
  let state = await testAsyncReducer(reducer, action)

  expect(state).toEqual([
    {
      pending: 1,
      assignmentGroups: [],
      nextPage: null,
    },
    {
      pending: 0,
      assignmentGroups: groups,
      nextPage: undefined,
    },
  ])
})
