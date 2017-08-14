// @flow

import { UserProfileActions } from '../actions'
import { testAsyncAction } from '../../../../test/helpers/async'
import { apiResponse } from '../../../../test/helpers/apiMock'

let template = {
  ...require('../../../api/canvas-api/__templates__/users'),
}

test('should refresh user profiles based on a single userID passed in', async () => {
  const user = template.user()
  let actions = UserProfileActions({ getUserProfile: apiResponse(user) })
  const result = await testAsyncAction(actions.refreshUsers([user.id]))

  expect(result).toMatchObject([
    {
      type: actions.refreshUsers.toString(),
      pending: true,
      payload: {
        userIDs: [user.id],
      },
    },
    {
      type: actions.refreshUsers.toString(),
      payload: { result: [{ data: user }] },
    },
  ])
})

test('should refresh user profiles based on the userIDs passed in', async () => {
  const user = template.user()
  let actions = UserProfileActions({ getUserProfile: apiResponse(user) })
  const result = await testAsyncAction(actions.refreshUsers([user.id, user.id]))

  expect(result).toMatchObject([
    {
      type: actions.refreshUsers.toString(),
      pending: true,
      payload: {
        userIDs: [user.id, user.id],
      },
    },
    {
      type: actions.refreshUsers.toString(),
      payload: { result: [{ data: user }, { data: user }] },
    },
  ])
})
