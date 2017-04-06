/* @flow */

import { AssignmentListActions } from '../actions'
import { assignments } from '../assignment-entities-reducer'
import { apiResponse, apiError } from '../../../../test/helpers/apiMock'
import { testAsyncReducer } from '../../../../test/helpers/async'

const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
}

test('refresh assignments', async () => {
  const groups = [template.assignmentGroup()]
  const assignment = template.assignment()
  let action = AssignmentListActions({ getCourseAssignmentGroups: apiResponse(groups) }).refreshAssignmentList(1, 2)
  let state = await testAsyncReducer(assignments, action)

  expect(state).toEqual([{}, {
    [assignment.id.toString()]: { assignment },
  }])
})

test('update assignments', async () => {
  let assignment = template.assignment()
  let action = AssignmentListActions({ updateAssignment: apiResponse(assignment) }).updateAssignment('1', assignment, assignment)
  let state = await testAsyncReducer(assignments, action)

  let a = { [assignment.id]: { pending: 1, assignment: { ...assignment } } }
  let b = { [assignment.id]: { pending: 0, assignment: { ...assignment } } }

  expect(state).toEqual([a, b])
})

it('update assignments with error', async () => {
  let original = template.assignment()
  let updated = template.assignment({ name: 'foo' })
  let error = '401 error'
  let action = AssignmentListActions({ updateAssignment: apiError({ message: error }) }).updateAssignment('1', updated, original)
  let state = await testAsyncReducer(assignments, action)

  let a = { [updated.id]: { assignment: { ...updated }, pending: 1 } }
  let b = { [original.id]: { assignment: { ...original }, pending: 0, error: { data: { errors: [{ message: error }] }, status: 401 } } }

  expect(state).toEqual([a, b])
})

