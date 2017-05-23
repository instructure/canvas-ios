// @flow

import {
  enrollments,
  enrollmentUsers,
} from '../enrollment-entities-reducer'
import Actions from '../actions'

const { refreshEnrollments } = Actions
const templates = {
  ...require('../../../api/canvas-api/__templates__/enrollments'),
  ...require('../../../api/canvas-api/__templates__/users'),
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
