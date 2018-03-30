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

// @flow

import { GroupFavoritesActions } from '../actions'
import { testAsyncAction } from '../../../../../test/helpers/async'
import { apiResponse } from '../../../../../test/helpers/apiMock'

test('toggle group favorite workflow', async () => {
  let actions = GroupFavoritesActions({ updateGroupFavorites: apiResponse({ data: ['1'] }) })
  let initialState = {
    groupFavorites: [],
  }
  const result = await testAsyncAction(actions.updateGroupFavorites('self', ['1']), initialState)

  expect(result).toMatchObject([
    {
      type: actions.updateGroupFavorites.toString(),
      payload: {
        favorites: ['1'],
        userID: 'self',
      },
      pending: true,
    },
    {
      type: actions.updateGroupFavorites.toString(),
    },
  ])
})
