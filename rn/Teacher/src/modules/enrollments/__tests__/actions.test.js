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

import { EnrollmentsActions } from '../actions'
import { testAsyncAction } from '../../../../test/helpers/async'
import { apiResponse } from '../../../../test/helpers/apiMock'

let template = {
  ...require('../../../__templates__/enrollments'),
}

test('should refresh enrollments', async () => {
  const enrollments = [
    template.enrollment({ id: '45' }),
    template.enrollment({ id: '67' }),
  ]

  let actions = EnrollmentsActions({
    getCourseEnrollments: apiResponse(enrollments),
  })

  let result = await testAsyncAction(actions.refreshEnrollments('1'))

  expect(result).toMatchObject([
    {
      type: actions.refreshEnrollments.toString(),
      pending: true,
      payload: {
        courseID: '1',
      },
    },
    {
      type: actions.refreshEnrollments.toString(),
      payload: {
        result: { data: enrollments },
        courseID: '1',
      },
    },
  ])
})

test('should refresh user enrollments', async () => {
  const enrollments = [
    template.enrollment({ id: '45' }),
    template.enrollment({ id: '67' }),
  ]

  let actions = EnrollmentsActions({
    getUserEnrollments: apiResponse(enrollments),
  })

  let result = await testAsyncAction(actions.refreshUserEnrollments())

  expect(result).toMatchObject([
    {
      type: actions.refreshUserEnrollments.toString(),
      pending: true,
      payload: {
        userID: 'self',
      },
    },
    {
      type: actions.refreshUserEnrollments.toString(),
      payload: {
        result: { data: enrollments },
        userID: 'self',
      },
    },
  ])
})

test('should accept enrollment', async () => {
  let actions = EnrollmentsActions({
    acceptEnrollment: apiResponse({ success: true }),
  })

  let result = await testAsyncAction(actions.acceptEnrollment('1', '2', 'accept'))

  expect(result).toMatchObject([
    {
      type: actions.acceptEnrollment.toString(),
      pending: true,
      payload: {
        courseID: '1',
        enrollmentID: '2',
      },
    },
    {
      type: actions.acceptEnrollment.toString(),
      payload: {
        result: { data: { success: true } },
        courseID: '1',
        enrollmentID: '2',
      },
    },
  ])
})

test('should reject enrollment', async () => {
  let actions = EnrollmentsActions({
    rejectEnrollment: apiResponse({ success: true }),
  })

  let result = await testAsyncAction(actions.rejectEnrollment('1', '2', 'reject'))

  expect(result).toMatchObject([
    {
      type: actions.rejectEnrollment.toString(),
      pending: true,
      payload: {
        courseID: '1',
        enrollmentID: '2',
      },
    },
    {
      type: actions.rejectEnrollment.toString(),
      payload: {
        result: { data: { success: true } },
        courseID: '1',
        enrollmentID: '2',
      },
    },
  ])
})
