// @flow

import Actions from '../actions'
import { groups } from '../group-entities-reducer'

const { refreshGroupsForCourse, refreshGroup } = Actions

const template = {
  ...require('../../../api/canvas-api/__templates__/group'),
}

test('igornes pending', () => {
  expect(groups({}, {
    type: refreshGroupsForCourse.toString(),
    pending: true,
    payload: {},
  })).toEqual({})
})

test('captures entities', () => {
  const groupTemplates = [
    template.group({ id: '1' }),
    template.group({ id: '2', name: 'Yellow Squadron' }),
  ]
  const action = {
    type: refreshGroupsForCourse.toString(),
    payload: {
      result: { data: groupTemplates },
    },
  }

  expect(groups({}, action)).toEqual({
    '1': { group: groupTemplates[0] },
    '2': { group: groupTemplates[1] },
  })
})

test('captures a single entity', () => {
  const group = template.group({ id: '1' })
  const action = {
    type: refreshGroup.toString(),
    payload: {
      result: { data: group },
    },
  }

  expect(groups({}, action)).toEqual({
    '1': { group },
  })
})
