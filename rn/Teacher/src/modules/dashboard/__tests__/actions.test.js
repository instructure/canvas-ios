//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import { DashboardActions } from '../actions'
import { testAsyncAction } from '../../../../test/helpers/async'
import { apiResponse } from '../../../../test/helpers/apiMock'
import * as templates from '../../../__templates__'

describe('DashboardActions', () => {
  it('gets the dashboard cards', async () => {
    let cards = [templates.dashboardCard()]
    let actions = DashboardActions({ getDashboardCards: apiResponse(cards) })
    let result = await testAsyncAction(actions.getDashboardCards())

    expect(result).toMatchObject([{
      type: actions.getDashboardCards.toString(),
      pending: true,
    }, {
      type: actions.getDashboardCards.toString(),
      payload: {
        result: {
          data: cards,
        },
      },
    }])
  })
})
