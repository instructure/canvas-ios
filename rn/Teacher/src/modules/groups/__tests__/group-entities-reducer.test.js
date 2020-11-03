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

/* eslint-disable flowtype/require-valid-file-annotation */

import Actions from '../actions'
import CoursesActions from '../../courses/actions'
import { groups } from '../group-entities-reducer'
import PermissionsActions from '../../permissions/actions'

const { refreshGroupsForCourse, refreshGroup, listUsersForGroup } = Actions
const { refreshCourses } = CoursesActions
const { updateContextPermissions } = PermissionsActions

import * as template from '../../../__templates__'

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

test('doesnt overwrite other data for the group', () => {
  let group = template.group({ id: '1' })
  let action = {
    type: refreshGroupsForCourse.toString(),
    payload: {
      result: { data: [group] },
    },
  }

  let state = {
    '1': {
      permissions: {
        post_to_forum: true,
      },
    },
  }

  expect(groups(state, action)).toEqual({
    '1': {
      group,
      permissions: {
        post_to_forum: true,
      },
    },
  })
})

test('captures a single entity', () => {
  const group = template.group({ id: '1' })
  const action = {
    type: refreshGroup.toString(),
    payload: {
      result: [{ data: group }],
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
      color: '',
      permissions: {},
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
      color: '',
      permissions: {},
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
      color: '',
      permissions: {},
    },
  }

  expect(groups(initialState, action)).toEqual(expected)
})

test('captures group colors', () => {
  const group = template.group({ id: '1' })
  const initialState = {
    '1': {
      pending: 0,
      error: null,
      group,
    },
  }

  const action = {
    type: refreshCourses.toString(),
    payload: {
      result: [{}, {
        data: {
          custom_colors: {
            group_1: '#fff',
            group_2: '#eee',
            course_3: '#000',
          },
        },
      }],
    },
  }

  expect(groups(initialState, action)).toMatchObject({
    '1': {
      color: '#fff',
    },
    '2': {
      color: '#eee',
    },
  })
})

test('colors when there are no groups', () => {
  const group = template.group({ id: '1' })
  const initialState = {
    '1': {
      pending: 0,
      error: null,
      group,
    },
  }

  const action = {
    type: refreshCourses.toString(),
    payload: {
      result: [{}, {
        data: {
          custom_colors: {
            account_1: '#fff',
            course_2: '#eee',
            course_3: '#000',
          },
        },
      }],
    },
  }

  expect(groups(initialState, action)).toEqual(initialState)
})

test('updates the group permissions when the context is a group', () => {
  let action = {
    type: updateContextPermissions.toString(),
    payload: {
      contextID: '1',
      contextName: 'groups',
      result: {
        data: { post_to_forum: false },
      },
    },
  }

  let state = {
    '1': {},
  }
  let newState = groups(state, action)
  expect(newState).toMatchObject({
    '1': {
      permissions: { post_to_forum: false },
    },
  })
})

test('doesnt overwrite existing permissions when they are not present in the payload', () => {
  let action = {
    type: updateContextPermissions.toString(),
    payload: {
      contextID: '1',
      contextName: 'groups',
      result: {
        data: { post_to_forum: false },
      },
    },
  }

  let state = {
    '1': {
      permissions: {
        create_discussion: true,
      },
    },
  }
  expect(groups(state, action)).toMatchObject({
    '1': {
      permissions: {
        post_to_forum: false,
        create_discussion: true,
      },
    },
  })
})

test('doesnt update the group when the context is not a group', () => {
  let action = {
    type: updateContextPermissions.toString(),
    payload: {
      contextID: '1',
      contextName: 'courses',
      result: {
        data: { post_to_forum: false },
      },
    },
  }

  let state = {
    '1': {},
  }
  let newState = groups(state, action)
  expect(newState).toMatchObject(state)
})
