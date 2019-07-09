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
