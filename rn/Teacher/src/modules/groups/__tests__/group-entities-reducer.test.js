// @flow

import Actions from '../actions'
import { groups } from '../group-entities-reducer'

const { refreshGroupsForCourse, refreshGroup, listUsersForGroup } = Actions

const template = {
  ...require('../../../api/canvas-api/__templates__/group'),
  ...require('../../../api/canvas-api/__templates__/error'),
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

test('captures list of users resolved', () => {
  const group = template.group({ id: '1' })

  const initialState = {
    '1': {
      pending: 0,
      error: null,
      group: {
        ...group,
        users: null,
      },
    },
  }

  const action = {
    type: listUsersForGroup.toString(),
    payload: {
      groupID: group.id,
      result: { data: group.users },
    },
  }

  let expected = {
    '1': {
      group: {
        ...group,
      },
      error: null,
      pending: 0,
    },
  }

  expect(groups(initialState, action)).toEqual(expected)
})

test('captures list of users pending', () => {
  const group = template.group({ id: '1' })

  const initialState = {
    '1': {
      pending: 0,
      error: null,
      group: {
        ...group,
        users: null,
      },
    },
  }

  const action = {
    type: listUsersForGroup.toString(),
    pending: true,
    payload: {
      groupID: group.id,
    },
  }

  let expected = {
    '1': {
      group: {
        ...initialState['1'].group,
      },
      error: null,
      pending: 1,
    },
  }

  expect(groups(initialState, action)).toEqual(expected)
})

test('captures list of users rejected', () => {
  const group = template.group({ id: '1' })

  const initialState = {
    '1': {
      pending: 0,
      error: null,
      group: {
        ...group,
        users: null,
      },
    },
  }

  const action = {
    type: listUsersForGroup.toString(),
    error: true,
    payload: {
      groupID: group.id,
      error: template.error('User not authorized'),
    },
  }

  let expected = {
    '1': {
      group: {
        ...initialState['1'].group,
      },
      error: 'User not authorized',
      pending: 0,
    },
  }

  expect(groups(initialState, action)).toEqual(expected)
})
