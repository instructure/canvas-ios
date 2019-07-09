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

import { LTIActions } from '../actions'
import { apiResponse } from '../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../test/helpers/async'

const template = {
  ...require('../../../__templates__/external-tool'),
}

test('fetch LTI launch definitions', async () => {
  const definitions = [template.ltiLaunchDefinition()]
  let actions = LTIActions({ getLTILaunchDefinitions: apiResponse(definitions) })
  const result = await testAsyncAction(actions.refreshLTITools('555'))
  expect(result).toMatchObject([
    {
      type: actions.refreshLTITools.toString(),
      pending: true,
      payload: { courseID: '555' },
    },
    {
      type: actions.refreshLTITools.toString(),
      payload: {
        result: { data: definitions },
        courseID: '555',
      },
    },
  ])
})
