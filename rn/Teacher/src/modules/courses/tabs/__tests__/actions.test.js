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
