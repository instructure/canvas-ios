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
