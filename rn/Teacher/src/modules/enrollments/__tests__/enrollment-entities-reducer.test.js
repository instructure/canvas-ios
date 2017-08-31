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

import {
  enrollments,
  enrollmentUsers,
} from '../enrollment-entities-reducer'
import Actions from '../actions'

const { refreshEnrollments } = Actions
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

test('captures entities mapped by id for users', () => {
  const u1 = templates.user({ id: '1' })
  let u2 = templates.user({ id: '2' })
  const users = {
    [u2.id]: u2,
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
    '1': u1,
    '2': u2,
  })
})
