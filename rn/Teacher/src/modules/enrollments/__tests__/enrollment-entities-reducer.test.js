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

import {
  enrollments,
  enrollmentUsers,
} from '../enrollment-entities-reducer'
import Actions from '../actions'

const { refreshEnrollments, refreshUserEnrollments, acceptEnrollment, rejectEnrollment } = Actions
const templates = {
  ...require('../../../__templates__/enrollments'),
  ...require('../../../__templates__/users'),
}

test('captures entities mapped by id', () => {
  const data = [
    templates.enrollment({ id: '3' }),
    templates.enrollment({ id: '5' }),
  ]

  const action = {
    type: refreshEnrollments.toString(),
    payload: { result: { data } },
  }

  expect(enrollments({}, action)).toEqual({
    '3': data[0],
    '5': data[1],
  })
})

test('refreshUserEnrollments adds the enrollments', () => {
  const data = [
    templates.enrollment({ id: '3' }),
    templates.enrollment({ id: '5' }),
  ]

  const action = {
    type: refreshUserEnrollments.toString(),
    payload: { result: { data } },
  }

  expect(enrollments({}, action)).toEqual({
    '3': data[0],
    '5': data[1],
  })
})

test('captures entities mapped by id for users', () => {
  const u1 = templates.user({ id: '1' })
  let u2 = templates.user({ id: '2' })
  const users = {
    [u2.id]: {
      data: u2,
    },
  }

  u2 = templates.user({
    id: '2',
    name: 'Zeratul',
  })
  const data = [
    templates.enrollment({ id: '3', user_id: u1.id, user: u1 }),
    templates.enrollment({ id: '5', user_id: u2.id, user: u2 }),
  ]

  const action = {
    type: refreshEnrollments.toString(),
    payload: { result: { data } },
  }

  expect(enrollmentUsers(users, action)).toEqual({
    '1': {
      data: u1,
    },
    '2': {
      data: u2,
    },
  })
})

test('accepts enrollment', () => {
  const data = { success: true }

  const action = {
    type: acceptEnrollment.toString(),
    payload: { courseID: '2', enrollmentID: '1', result: { data } },
  }

  let ens = {
    '1': { enrollment_state: 'invited' },
  }

  expect(enrollments(ens, action)).toEqual({
    '1': { enrollment_state: 'active', displayState: 'acted' },
  })
})

test('rejects enrollment', () => {
  const data = { success: true }

  const action = {
    type: rejectEnrollment.toString(),
    payload: { courseID: '2', enrollmentID: '1', result: { data } },
  }

  let ens = {
    '1': { enrollment_state: 'invited' },
  }

  expect(enrollments(ens, action)).toEqual({
    '1': { enrollment_state: 'rejected', displayState: 'acted' },
  })
})

test('handles failed accepted enrollment', () => {
  const data = { success: false }

  const action = {
    type: acceptEnrollment.toString(),
    payload: { courseID: '2', enrollmentID: '1', result: { data } },
  }

  let ens = {
    '1': { enrollment_state: 'invited' },
  }

  expect(enrollments(ens, action)).toEqual({
    '1': { enrollment_state: 'invited' },
  })
})

test('handles failed rejected enrollment', () => {
  const data = { success: false }

  const action = {
    type: rejectEnrollment.toString(),
    payload: { courseID: '2', enrollmentID: '1', result: { data } },
  }

  let ens = {
    '1': { enrollment_state: 'invited' },
  }

  expect(enrollments(ens, action)).toEqual({
    '1': { enrollment_state: 'invited' },
  })
})
