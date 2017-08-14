// @flow

import { UserProfileActions } from '../actions'
import { users } from '../reducer'
import { apiResponse } from '../../../../test/helpers/apiMock'
import { testAsyncReducer } from '../../../../test/helpers/async'

let template = {
  ...require('../../../api/canvas-api/__templates__/users'),
}

describe('user-profiles reducer', () => {
  it('should mark a user as pending', () => {
    let action = {
      type: UserProfileActions().refreshUsers.toString(),
      pending: true,
      payload: {
        userIDs: ['1'],
      },
    }

    let state = users({}, action)
    expect(state).toMatchObject({
      '1': {
        pending: true,
      },
    })
  })

  it('should fill out the user profile entities from response', async () => {
    const user = template.user()

    let action = UserProfileActions({
      getUserProfile: apiResponse(user),
    }).refreshUsers([user.id])

    let state = await testAsyncReducer(users, action)
    expect(state).toMatchObject([{}, {
      [user.id]: {
        data: user,
        pending: false,
      },
    }])
  })

  it('should put pending false on failure', () => {
    let action = {
      type: UserProfileActions().refreshUsers.toString(),
      error: true,
      payload: {
        userIDs: ['1'],
      },
    }

    let state = users({}, action)
    expect(state).toMatchObject({
      '1': {
        pending: false,
      },
    })
  })
})
