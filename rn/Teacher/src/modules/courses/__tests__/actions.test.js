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

import { CoursesActions } from '../actions'
import { testAsyncAction } from '../../../../test/helpers/async'
import { apiResponse } from '../../../../test/helpers/apiMock'

let template = {
  ...require('../../../__templates__/course'),
  ...require('../../../__templates__/grading-periods'),
}

let defaultState = {}

test('refresh courses workflow', async () => {
  const courses = [template.course()]
  const colors = template.customColors()
  let actions = CoursesActions({ getCourses: apiResponse(courses), getCustomColors: apiResponse(colors) })
  const result = await testAsyncAction(actions.refreshCourses())

  expect(result).toMatchObject([
    {
      type: actions.refreshCourses.toString(),
      pending: true,
    },
    {
      type: actions.refreshCourses.toString(),
      payload: { result: [{ data: courses }, { data: colors }], syncToNative: true },
    },
  ])
})

test('update course color workflow', async () => {
  let response = { hexcode: '#fff' }
  let actions = CoursesActions({ updateCourseColor: apiResponse(response) })
  let state = {
    ...defaultState,
    customColors: {
      '1': '#333',
    },
  }
  const result = await testAsyncAction(actions.updateCourseColor('1', '#fff'), state)

  expect(result).toMatchObject([
    {
      type: actions.updateCourseColor.toString(),
      pending: true,
      payload: {
        courseID: '1',
        color: '#fff',
      },
    },
    {
      type: actions.updateCourseColor.toString(),
      payload: {
        result: { data: response },
        color: '#fff',
        courseID: '1',
      },
    },
  ])
})

test('refreshGradingPeriods', async () => {
  let gradingPeriod = template.gradingPeriod()
  let response = { grading_periods: [gradingPeriod] }
  let actions = CoursesActions({ getCourseGradingPeriods: apiResponse(response) })
  let result = await testAsyncAction(actions.refreshGradingPeriods('1'))

  expect(result).toMatchObject([{
    type: actions.refreshGradingPeriods.toString(),
    pending: true,
    payload: {
      courseID: '1',
    },
  }, {
    type: actions.refreshGradingPeriods.toString(),
    payload: { handlesError: true, result: { data: response }, courseID: '1' },
  }])
})

test('getCourseEnabledFeatures', async () => {
  let features = ['anonymous_grading']
  let actions = CoursesActions({ getCourseEnabledFeatures: apiResponse(features) })
  let result = await testAsyncAction(actions.getCourseEnabledFeatures('1'))

  expect(result).toMatchObject([{
    type: actions.getCourseEnabledFeatures.toString(),
    payload: { courseID: '1' },
    pending: true,
  }, {
    type: actions.getCourseEnabledFeatures.toString(),
    payload: {
      result: {
        data: features,
      },
      courseID: '1',
    },
  }])
})

test('getCoursePermissions', async () => {
  let permissions = { send_messages: false }
  let actions = CoursesActions({ getCoursePermissions: apiResponse(permissions) })
  let result = await testAsyncAction(actions.getCoursePermissions('1'))

  expect(result).toMatchObject([{
    type: actions.getCoursePermissions.toString(),
    payload: { courseID: '1' },
    pending: true,
  }, {
    type: actions.getCoursePermissions.toString(),
    payload: {
      courseID: '1',
      result: {
        data: permissions,
      },
    },
  }])
})
