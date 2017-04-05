// @flow

import {
  enrollments,
} from '../enrollment-entities-reducer'
import Actions from '../actions'

const { refreshEnrollments } = Actions
const templates = {
  ...require('../../../api/canvas-api/__templates__/enrollments'),
}

test('captures entities mapped by id', () => {
  const data = [
    templates.enrollment({ id: '3' }),
    templates.enrollment({ id: '5' }),
  ]

  const action = {
    type: refreshEnrollments.toString(),
    payload: {
      result: {
        data,
      },
    },
  }

  expect(enrollments({}, action)).toEqual({
    '3': data[0],
    '5': data[1],
  })
})
