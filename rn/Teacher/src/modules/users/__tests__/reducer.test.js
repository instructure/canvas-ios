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

import { UserActions } from '../actions'
import { users } from '../reducer'
import { apiResponse } from '../../../../test/helpers/apiMock'
import { testAsyncReducer } from '../../../../test/helpers/async'

let template = {
  ...require('../../../__templates__/users'),
}

describe('user-profiles reducer', () => {
  it('should mark a user as pending', () => {
    let action = {
      type: UserActions().refreshUsers.toString(),
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

    let action = UserActions({
      getCourseUsers: apiResponse([user]),
    }).refreshUsers('1', [user.id])

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
      type: UserActions().refreshUsers.toString(),
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
