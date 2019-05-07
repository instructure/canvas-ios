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

import { UserInfoActions } from '../actions'
import { apiResponse } from '../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../test/helpers/async'

describe('UserInfo Actions', () => {
  it('refreshses canActAsUser', async () => {
    let actions = UserInfoActions({ becomeUserPermissions: apiResponse({ become_user: false }) })
    const result = await testAsyncAction(actions.refreshCanActAsUser())
    expect(result).toMatchObject([{
      type: 'userInfo.canActAsUser',
      payload: { handlesError: true },
    },
    {
      type: 'userInfo.canActAsUser',
      payload: { handlesError: true, result: { data: { become_user: false } } },
    }])
  })
})

describe('refreshHelpLinks', () => {
  it('sets the payload', () => {
    const actions = UserInfoActions({ getHelpLinks: jest.fn(() => 'help links') })
    const action = actions.refreshHelpLinks()
    expect(action).toMatchObject({
      type: 'userInfo.refreshHelpLinks',
      payload: {
        promise: 'help links',
        handlesError: true,
      },
    })
  })
})
