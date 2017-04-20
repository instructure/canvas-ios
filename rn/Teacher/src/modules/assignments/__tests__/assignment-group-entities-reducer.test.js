// @flow

import { AssignmentListActions } from '../actions'
import { assignmentGroups } from '../assignment-group-entities-reducer'
import { apiResponse } from '../../../../test/helpers/apiMock'
import { testAsyncReducer } from '../../../../test/helpers/async'

const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
}

test('refresh assignment groups', async () => {
  const group = template.assignmentGroup()
  let assignmentRefs = group.assignments.map((a) => a.id)

  let action = AssignmentListActions({ getCourseAssignmentGroups: apiResponse([group]) }).refreshAssignmentList(1)
  let state = await testAsyncReducer(assignmentGroups, action)

  delete group.assignments
  expect(state).toEqual([{}, {
    [group.id.toString()]: { group, assignmentRefs },
  }])
})

test('refresh assignment groups returns existing state when there is a gradingPeriodID', async () => {
  const group = template.assignmentGroup()
  let action = AssignmentListActions({ getCourseAssignmentGroups: apiResponse([group]) }).refreshAssignmentList(1, 2)
  let state = await testAsyncReducer(assignmentGroups, action)
  expect(state).toEqual([{}, {}])
})

