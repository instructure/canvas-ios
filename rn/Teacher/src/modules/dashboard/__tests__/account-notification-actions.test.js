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

/* @flow */

import { AccountNotificationActions } from '../account-notification-actions'
import { apiResponse } from '../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../test/helpers/async'

const template = {
  ...require('../../../__templates__/account-notification'),
}

describe('account notification actions', () => {
  const list = [
    template.accountNotification({ id: '1' }),
    template.accountNotification({ id: '2' }),
  ]
  const actions = AccountNotificationActions({
    getAccountNotifications: apiResponse(list),
    deleteAccountNotification: apiResponse(null),
  })

  it('can refresh the notifications list', async () => {
    const result = await testAsyncAction(actions.refreshNotifications(), {})
    expect(result).toMatchObject([
      {
        type: actions.refreshNotifications.toString(),
        pending: true,
        payload: {},
      },
      {
        type: actions.refreshNotifications.toString(),
        payload: { result: { data: list } },
      },
    ])
  })

  it('can close a notification', async () => {
    const result = await testAsyncAction(actions.closeNotification('2'), {})
    expect(result).toMatchObject([
      {
        type: actions.closeNotification.toString(),
        pending: true,
        payload: { id: '2' },
      },
      {
        type: actions.closeNotification.toString(),
        payload: { id: '2', result: { data: null } },
      },
    ])
  })
})
