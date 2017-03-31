/* @flow */

import { AssignmentListActions } from '../actions'
import { CoursesActions } from '../../courses/actions'
import { gradingPeriods } from '../grading-periods-reducer'
import { apiResponse } from '../../../../test/helpers/apiMock'
import { testAsyncReducer } from '../../../../test/helpers/async'

const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/grading-periods'),
}

test('refresh grading periods', async () => {
  const gradingPeriod = template.gradingPeriod()
  let action = CoursesActions({ getCourseGradingPeriods: apiResponse({ grading_periods: [gradingPeriod] }) }).refreshGradingPeriods(1)
  let state = await testAsyncReducer(gradingPeriods, action)

  expect(state).toEqual([{}, {
    [gradingPeriod.id]: {
      gradingPeriod,
      assignmentRefs: [],
    },
  }])
})

test('refresh grading periods should keep any existing assignmentRefs', async () => {
  const gradingPeriod = template.gradingPeriod({ id: 1 })
  let action = CoursesActions({ getCourseGradingPeriods: apiResponse({ grading_periods: [gradingPeriod] }) }).refreshGradingPeriods(1)
  let initialState = {
    '1': {
      gradingPeriod,
      assignmentRefs: [1],
    },
  }
  let state = await testAsyncReducer(gradingPeriods, action, initialState)

  expect(state).toEqual([initialState, initialState])
})

test('refresh assignment groups list', async () => {
  let group = template.assignmentGroup()
  let action = AssignmentListActions({ getCourseAssignmentGroups: apiResponse([group]) }).refreshAssignmentList(1, 1)
  let state = await testAsyncReducer(gradingPeriods, action)

  expect(state).toEqual([{}, {
    '1': {
      assignmentRefs: [group.assignments[0].id],
    },
  }])
})
