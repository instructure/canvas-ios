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

  it('getUserSettings', async () => {
    let actions = UserInfoActions({ getUserSettings: apiResponse({ hide_dashcard_color_overlays: true }) })
    let result = await testAsyncAction(actions.getUserSettings())
    expect(result).toMatchObject([{
      type: 'userInfo.getUserSettings',
      payload: { },
    }, {
      type: 'userInfo.getUserSettings',
      payload: { result: { data: { hide_dashcard_color_overlays: true } } },
    }])
  })

  it('updateUserSettings', async () => {
    let actions = UserInfoActions({ updateUserSettings: apiResponse({ hide_dashcard_color_overlays: true }) })
    let result = await testAsyncAction(actions.updateUserSettings('self', true))
    expect(result).toMatchObject([{
      type: 'userInfo.updateUserSettings',
      payload: { hideOverlay: true },
    }, {
      type: 'userInfo.updateUserSettings',
      payload: {
        result: {
          data: {
            hide_dashcard_color_overlays: true,
          },
        },
        hideOverlay: true,
      },
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
