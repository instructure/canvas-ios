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

/* eslint-disable flowtype/require-valid-file-annotation */

import Actions from '../actions'
import CoursesActions from '../../courses/actions'
import { groups } from '../group-entities-reducer'
import DiscussionEditActions from '../../discussions/edit/actions'

const { refreshGroupsForCourse, refreshGroup, listUsersForGroup } = Actions
const { refreshCourses } = CoursesActions
const { createDiscussion } = DiscussionEditActions

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

test('captures entities with discussion', () => {
  let group = template.group({ id: '1' })

  const action = {
    type: createDiscussion.toString(),
    payload: {
      context: 'groups', contextID: group.id,
    },
    pending: true,
  }

  let announcement = template.discussion({ id: '2', is_announcement: true })
  const action2 = {
    type: createDiscussion.toString(),
    payload: {
      context: 'groups',
      contextID: group.id,
      params: { ...announcement },
      result: { data: announcement },
    },
  }

  let state = {
    [group.id]: {
      group,
      discussions: { pending: 0, refs: [] },
    },
  }

  let result1 = groups(state, action)
  let result2 = groups(result1, action2)

  expect(result1).toEqual({
    [group.id]: {
      group,
      color: '',
      discussions: { pending: 0, refs: [], new: { pending: 1, id: null, error: null } },
      announcements: { pending: 0, refs: [] },
      pending: 0,
      error: null,
    },
  })

  expect(result2).toEqual({
    [group.id]: {
      group,
      color: '',
      discussions: { pending: 0, refs: [], new: { pending: 0, id: announcement.id, error: null } },
      announcements: { pending: 0, refs: [announcement.id] },
      pending: 0,
      error: null,
    },
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
      announcements: {
        pending: 0,
        refs: [],
      },
      discussions: {
        pending: 0,
        refs: [],
      },
      color: '',
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
      announcements: {
        pending: 0,
        refs: [],
      },
      discussions: {
        pending: 0,
        refs: [],
      },
      color: '',
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
      announcements: {
        pending: 0,
        refs: [],
      },
      discussions: {
        pending: 0,
        refs: [],
      },
      color: '',
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
