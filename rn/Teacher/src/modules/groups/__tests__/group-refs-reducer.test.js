// @flow

import groups from '../group-refs-reducer'
import Actions from '../actions'

const { refreshGroupsForCourse } = Actions

const templates = {
  ...require('../../../api/canvas-api/__templates__/group'),
}

test('it captures group ids', () => {
  const data = [
    templates.group({ id: '1' }),
    templates.group({ id: '2' }),
  ]

  const pending = {
    type: refreshGroupsForCourse.toString(),
    pending: true,
  }
  const resolved = {
    type: refreshGroupsForCourse.toString(),
    payload: { result: { data } },
  }

  const pendingState = groups(undefined, pending)
  expect(pendingState).toEqual({ refs: [], pending: 1 })
  expect(groups(pendingState, resolved)).toEqual({
    pending: 0,
    refs: ['1', '2'],
  })
})
