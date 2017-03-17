/* @flow */

import { AssignmentListActions } from '../actions'
import { defaultState } from '../reducer'
import { apiResponse } from '../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../test/helpers/async'

const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
}

test('refresh assignment list', async () => {
  const groups = [template.assignmentGroup()]
  let actions = AssignmentListActions({ getCourseAssignmentGroups: apiResponse(groups) })
  const result = await testAsyncAction(actions.refreshAssignmentList(groups), defaultState)

  expect(result).toMatchObject([
    {
      type: actions.refreshAssignmentList.toString(),
      pending: true,
    },
    {
      type: actions.refreshAssignmentList.toString(),
      payload: { data: groups },
    },
  ])
})
