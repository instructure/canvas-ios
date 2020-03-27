//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
  const conferences = [
    template.liveConference(),
  ]
  const actions = AccountNotificationActions({
    getAccountNotifications: apiResponse(list),
    deleteAccountNotification: apiResponse(null),
    getLiveConferences: apiResponse(conferences),
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

  it('can refresh the live conferences', async () => {
    const result = await testAsyncAction(actions.refreshLiveConferences(), {})
    expect(result).toMatchObject([
      {
        type: actions.refreshLiveConferences.toString(),
        pending: true,
        payload: {},
      },
      {
        type: actions.refreshLiveConferences.toString(),
        payload: { result: { data: conferences } },
      },
    ])
  })

  it('can ignore the live conferences', async () => {
    const result = actions.ignoreLiveConference('4')
    expect(result).toMatchObject({
      type: actions.ignoreLiveConference.toString(),
      payload: { id: '4' },
    })
  })
})
