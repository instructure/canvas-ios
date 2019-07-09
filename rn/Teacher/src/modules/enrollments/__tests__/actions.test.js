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
