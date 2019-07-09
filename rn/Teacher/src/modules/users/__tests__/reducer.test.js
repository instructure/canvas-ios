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
