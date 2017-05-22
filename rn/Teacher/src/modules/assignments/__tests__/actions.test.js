/* @flow */

import { AssignmentListActions } from '../actions'
import { apiResponse } from '../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../test/helpers/async'

const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/course'),
}

test('refresh assignment list', async () => {
  const course = template.course()
  const groups = [template.assignmentGroup()]
  let actions = AssignmentListActions({ getAssignmentGroups: apiResponse(groups) })
  const result = await testAsyncAction(actions.refreshAssignmentList(course.id), {})

  expect(result).toMatchObject([{
    type: actions.refreshAssignmentList.toString(),
    pending: true,
    payload: {
      courseID: course.id,
    },
  },
  {
    type: actions.refreshAssignmentList.toString(),
    payload: {
      result: { data: groups },
      courseID: course.id,
    },
  },
  ])
})

test('refresh single assignment', async () => {
  const course = template.course()
  const assignment = template.assignment()
  let actions = AssignmentListActions({ getAssignment: apiResponse(assignment) })
  const result = await testAsyncAction(actions.refreshAssignment(course.id, assignment.id), {})

  expect(result).toMatchObject([{
    type: actions.refreshAssignment.toString(),
    pending: true,
    payload: {
      courseID: course.id,
      assignmentID: assignment.id,
    },
  },
  {
    type: actions.refreshAssignment.toString(),
    payload: {
      result: { data: assignment },
      courseID: course.id,
      assignmentID: assignment.id,
    },
  },
  ])
})

test('refresh assignment list can take an optional grading period id', async () => {
  const course = template.course()
  const groups = [template.assignmentGroup()]
  let actions = AssignmentListActions({ getAssignmentGroups: apiResponse(groups) })
  const result = await testAsyncAction(actions.refreshAssignmentList(course.id, 1), {})

  expect(result).toMatchObject([{
    type: actions.refreshAssignmentList.toString(),
    pending: true,
    payload: {
      courseID: course.id,
      gradingPeriodID: 1,
    },
  }, {
    type: actions.refreshAssignmentList.toString(),
    payload: {
      result: { data: groups },
      courseID: course.id,
      gradingPeriodID: 1,
    },
  }])
})

test('cancel update assignment action', () => {
  const assignment = template.assignment()
  let actions = AssignmentListActions()
  const result = actions.cancelAssignmentUpdate(assignment)
  expect(result).toMatchObject({
    type: 'assignment.cancel-update',
    payload: {
      originalAssignment: assignment,
    },
  })
})
