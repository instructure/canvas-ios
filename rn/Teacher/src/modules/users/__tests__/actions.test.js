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
import { testAsyncAction } from '../../../../test/helpers/async'
import { apiResponse } from '../../../../test/helpers/apiMock'

let template = {
  ...require('../../../__templates__/users'),
}

test('should refresh users based on a single userID passed in', async () => {
  const user = template.user()
  let actions = UserActions({ getCourseUsers: apiResponse([user]) })
  const result = await testAsyncAction(actions.refreshUsers('1', [user.id]))

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
      payload: { result: { data: [user] } },
    },
  ])
})

test('should refresh user profiles based on the userIDs passed in', async () => {
  const user = template.user()
  let actions = UserActions({ getCourseUsers: apiResponse([user, user]) })
  const result = await testAsyncAction(actions.refreshUsers('1', [user.id, user.id]))

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
      payload: { result: { data: [user, user] } },
    },
  ])
})
