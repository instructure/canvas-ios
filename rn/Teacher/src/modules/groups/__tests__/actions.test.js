//
// Copyright (C) 2017-present Instructure, Inc.
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

import Actions, { GroupActions } from '../actions'
import { testAsyncAction } from '../../../../test/helpers/async'
import { apiResponse } from '../../../../test/helpers/apiMock'
import * as template from '../../../__templates__'

const { refreshGroupsForCourse, refreshGroup, listUsersForGroup } = Actions

describe('refreshGroupsForCourse', () => {
  it('should refresh groups', async () => {
    const groups = [
      template.group({ id: '1' }),
      template.group({ id: '2', name: 'Yellow Squadron' }),
    ]

    let actions = GroupActions({
      getGroupsForCourse: apiResponse(groups),
    })

    let result = await testAsyncAction(actions.refreshGroupsForCourse('who cares'))
    expect(result).toMatchObject([
      {
        type: refreshGroupsForCourse.toString(),
        pending: true,
        payload: {},
      },
      {
        type: refreshGroupsForCourse.toString(),
        payload: {
          result: { data: groups },
        },
      },
    ])
  })
})

describe('refreshGroup', () => {
  it('should refresh a single group', async () => {
    const group = template.group({ id: '1' })

    let actions = GroupActions({
      getGroupByID: apiResponse(group),
    })

    let result = await testAsyncAction(actions.refreshGroup('i care you silly'))
    expect(result).toMatchObject([
      {
        type: refreshGroup.toString(),
        pending: true,
        payload: {},
      },
      {
        type: refreshGroup.toString(),
        payload: {
          result: [{ data: group }],
        },
      },
    ])
  })

  it('should get course settings', async () => {
    const group = template.group({ id: '1', course_id: '2' })
    const settings = template.courseSettings()
    let actions = GroupActions({
      getGroupByID: apiResponse(group),
      getCourseSettings: apiResponse(settings),
    })

    let result = await testAsyncAction(actions.refreshGroup('1'))
    expect(result).toMatchObject([
      {
        type: refreshGroup.toString(),
        pending: true,
        payload: {},
      },
      {
        type: refreshGroup.toString(),
        payload: {
          result: [{ data: group }, { data: settings }],
        },
      },
    ])
  })
})

describe('listUsersForGroup', () => {
  it('should return the users in a group', async () => {
    const group = template.group({ id: '1' })

    let actions = GroupActions({
      getUsersForGroupID: apiResponse(group.users),
    })

    let result = await testAsyncAction(actions.listUsersForGroup('1'))
    expect(result).toMatchObject([
      {
        type: listUsersForGroup.toString(),
        pending: true,
        payload: {},
      },
      {
        type: listUsersForGroup.toString(),
        payload: {
          result: { data: group.users },
        },
      },
    ])
  })
})
