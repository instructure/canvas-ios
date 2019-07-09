//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// @flow

import { AssignmentListActions } from '../actions'
import { CoursesActions } from '../../courses/actions'
import { gradingPeriods, refs } from '../grading-periods-reducer'
import { apiResponse } from '../../../../test/helpers/apiMock'
import { testAsyncReducer } from '../../../../test/helpers/async'
import * as template from '../../../__templates__'

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
  let action = AssignmentListActions({ getAssignmentGroups: apiResponse([group]), getAssignments: apiResponse(group.assignments) }).refreshAssignmentList(1, 1)
  let state = await testAsyncReducer(gradingPeriods, action)

  expect(state).toEqual([{}, {
    '1': {
      assignmentRefs: [group.assignments[0].id],
    },
  }])
})

test('refresh assignment groups list with no gradingPeriodID', async () => {
  let group = template.assignmentGroup()
  let action = AssignmentListActions({ getAssignmentGroups: apiResponse([group]), getAssignments: apiResponse(group.assignments) }).refreshAssignmentList(1, null)
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
