// @flow

import Actions, { GroupActions } from '../actions'
import { testAsyncAction } from '../../../../test/helpers/async'
import { apiResponse } from '../../../../test/helpers/apiMock'

const { refreshGroupsForCourse, refreshGroup, listUsersForGroup } = Actions

const template = {
  ...require('../../../api/canvas-api/__templates__/group'),
}

test('should refresh groups', async () => {
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

test('should refresh a single group', async () => {
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
        result: { data: group },
      },
    },
  ])
})

test('should return the users in a group', async () => {
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
