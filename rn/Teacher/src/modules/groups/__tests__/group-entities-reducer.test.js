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

import Actions from '../actions'
import CoursesActions from '../../courses/actions'
import { groups } from '../group-entities-reducer'

const { refreshGroupsForCourse, refreshGroup, listUsersForGroup } = Actions
const { refreshCourses } = CoursesActions

const template = {
  ...require('../../../__templates__/group'),
  ...require('../../../__templates__/error'),
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
