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

/* @flow */

import { TabsActions } from '../actions'
import { defaultState } from '../tabs-reducer'
import { apiResponse } from '../../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../../test/helpers/async'

const template = {
  ...require('../../../../__templates__/tab'),
}

test('refresh tabs', async () => {
  const tabs = [template.tab()]
  let actions = TabsActions({ getCourseTabs: apiResponse(tabs) })
  const result = await testAsyncAction(actions.refreshTabs('1'), defaultState)
  expect(result).toMatchObject([
    {
      type: actions.refreshTabs.toString(),
      pending: true,
      payload: { courseID: '1' },
    },
    {
      type: actions.refreshTabs.toString(),
      payload: {
        result: { data: tabs },
        courseID: '1',
      },
    },
  ])
})
