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

import { Actions } from './../actions'
import { apiResponse } from '../../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../../test/helpers/async'

const template = {
  ...require('../../../../__templates__/discussion'),
}

describe('refreshDiscussions', () => {
  it('should get discussions', async () => {
    const discussion = template.discussion({ title: 'refreshed' })
    const api = {
      getDiscussions: apiResponse([discussion]),
    }
    const actions = Actions(api)
    const action = actions.refreshDiscussions()
    const result = await testAsyncAction(action)
    expect(result).toMatchObject([
      {
        type: actions.refreshDiscussions.toString(),
        pending: true,
      },
      {
        type: actions.refreshDiscussions.toString(),
        payload: {
          result: { data: [discussion] },
        },
      },
    ])
  })
})
