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
