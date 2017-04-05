// @flow

import { UserProfileActions } from '../actions'
import { users } from '../reducer'
import { apiResponse } from '../../../../test/helpers/apiMock'
import { testAsyncReducer } from '../../../../test/helpers/async'

let template = {
  ...require('../../../api/canvas-api/__templates__/users'),
}

describe('user-profiles reducer', () => {
  it('should fill our the user profile entities from response', async () => {
    const user = template.user()

    let action = UserProfileActions({
      getUserProfile: apiResponse(user),
    }).refreshUsers([user.id])

    let state = await testAsyncReducer(users, action)
    expect(state).toMatchObject([{}, { [user.id]: user }])
  })
})
