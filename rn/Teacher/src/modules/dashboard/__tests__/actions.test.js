//
// Copyright (C) 2019-present Instructure, Inc.
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
