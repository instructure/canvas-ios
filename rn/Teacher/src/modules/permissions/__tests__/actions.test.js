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

/* @flow */

import { PermissionsActions } from '../actions'
import { apiResponse } from '../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../test/helpers/async'

describe('PermissionsActions', () => {
  it('calls the getContextPermissions api', async () => {
    let api = { getContextPermissions: apiResponse({ post_to_forum: true }) }
    let actions = PermissionsActions(api)
    let contextName = 'courses'
    let contextID = '1'
    const result = await testAsyncAction(actions.updateContextPermissions(contextName, contextID))
    expect(result).toMatchObject([{
      type: actions.updateContextPermissions.toString(),
      pending: true,
      payload: {
        contextName,
        contextID,
      },
    }, {
      type: actions.updateContextPermissions.toString(),
      payload: {
        contextName,
        contextID,
        result: {
          data: { post_to_forum: true },
        },
      },
    }])
    expect(api.getContextPermissions).toHaveBeenCalled()
  })
})
