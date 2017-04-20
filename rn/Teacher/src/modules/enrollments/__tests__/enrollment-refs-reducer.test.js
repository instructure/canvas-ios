// @flow

import {
  enrollments,
} from '../enrollments-refs-reducer'
import Actions from '../Actions'

const { refreshEnrollments } = Actions
const templates = {
  ...require('../../../api/canvas-api/__templates__/enrollments'),
}

const defaultRefs = { pending: 0, refs: [] }

test('captures the enrollment ids', () => {
  const data = [
    templates.enrollment({ id: '4' }),
    templates.enrollment({ id: '6' }),
  ]

  const pending = {
    type: refreshEnrollments.toString(),
    pending: true,
  }

  const resolved = {
    type: refreshEnrollments.toString(),
    payload: { result: { data } },
  }

  const pendingState = enrollments(defaultRefs, pending)
  expect(pendingState).toEqual({
    refs: [],
    pending: 1,
  })

  expect(enrollments(pendingState, resolved)).toEqual({
    refs: ['4', '6'],
    pending: 0,
  })
})
