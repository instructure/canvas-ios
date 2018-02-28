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
import { CoursesActions } from '../../courses/actions'
import { gradingPeriods, refs } from '../grading-periods-reducer'
import { apiResponse } from '../../../../test/helpers/apiMock'
import { testAsyncReducer } from '../../../../test/helpers/async'

const template = {
  ...require('../../../__templates__/assignments'),
  ...require('../../../__templates__/grading-periods'),
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
  let action = AssignmentListActions({ getAssignmentGroups: apiResponse([group]) }).refreshAssignmentList(1, 1)
  let state = await testAsyncReducer(gradingPeriods, action)

  expect(state).toEqual([{}, {
    '1': {
      assignmentRefs: [group.assignments[0].id],
    },
  }])
})

test('refresh assignment groups list with no gradingPeriodID', async () => {
  let group = template.assignmentGroup()
  let action = AssignmentListActions({ getAssignmentGroups: apiResponse([group]) }).refreshAssignmentList(1, null)
  let state = await testAsyncReducer(gradingPeriods, action)

  expect(state).toEqual([{}, {
  }])
})

test('refs', async () => {
  const gradingPeriod = template.gradingPeriod({ id: '1' })
  let action = CoursesActions({ getCourseGradingPeriods: apiResponse({ grading_periods: [gradingPeriod] }) }).refreshGradingPeriods('1')
  let state = await testAsyncReducer(refs, action)

  expect(state).toEqual([{
    pending: 1,
    refs: [],
  }, {
    pending: 0,
    refs: ['1'],
  }])
})
