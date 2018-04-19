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
import { favoriteGroups, defaultState } from '../favorite-groups-reducer'
import { apiResponse } from '../../../../../test/helpers/apiMock'
import { testAsyncReducer } from '../../../../../test/helpers/async'

describe('toggleGroupFavorite', () => {
  it('update group favorites undefined payload', async () => {
    const groupID = '1'
    const action = GroupFavoritesActions({ updateGroupFavorites: apiResponse() }).updateGroupFavorites('self', [groupID])
    const initialState = {
      ...defaultState,
      groupRefs: [],
      userHasFavoriteGroups: true,
    }
    const states = await testAsyncReducer(favoriteGroups, action, initialState)
    expect(states).toEqual([{ groupRefs: [], pending: 0, userHasFavoriteGroups: true }, { groupRefs: [], pending: 0, userHasFavoriteGroups: true }])
  })

  it('update group favorites', async () => {
    const groupID = '1'

    const api = {
      updateGroupFavorites: apiResponse({ data: [groupID] }),
    }

    const action = GroupFavoritesActions(api).updateGroupFavorites('self', [groupID])
    const initialState = {
      ...defaultState,
      groupRefs: [],
    }
    const states = await testAsyncReducer(favoriteGroups, action, initialState)
    const groupRefs = [groupID]
    expect(states).toEqual([
      { groupRefs: [], pending: 0, userHasFavoriteGroups: true },
      { groupRefs, pending: 0, userHasFavoriteGroups: true },
    ])
  })

  it('refresh group favorites', async () => {
    const groupID = '1'

    const api = {
      refreshGroupFavorites: apiResponse({ data: [groupID] }),
    }

    const action = GroupFavoritesActions(api).refreshGroupFavorites()
    const initialState = {
      ...defaultState,
      groupRefs: [],
    }
    const states = await testAsyncReducer(favoriteGroups, action, initialState)
    const groupRefs = [groupID]
    expect(states).toEqual([
      { groupRefs: [], pending: 0, userHasFavoriteGroups: true },
      { groupRefs, pending: 0, userHasFavoriteGroups: true },
    ])
  })

  it('refresh group favorites undefined payload', async () => {
    const api = {
      refreshGroupFavorites: apiResponse(),
    }

    const action = GroupFavoritesActions(api).refreshGroupFavorites()
    const initialState = {
      ...defaultState,
      groupRefs: [],
    }
    const states = await testAsyncReducer(favoriteGroups, action, initialState)
    expect(states).toEqual([
      { groupRefs: [], pending: 0, userHasFavoriteGroups: true },
      { groupRefs: [], pending: 0, userHasFavoriteGroups: true },
    ])
  })

  it('refresh group favorites error, favorites have never been set', async () => {
    const action = {
      type: GroupFavoritesActions({}).refreshGroupFavorites.toString(),
      error: true,
      payload: {
        error: { response: { status: 400, data: { message: 'no data for scope' } } },
      },
    }

    const initialState = {
      ...defaultState,
      groupRefs: [],
    }
    const states = await testAsyncReducer(favoriteGroups, action, initialState)
    expect(states).toEqual([
      { groupRefs: [], pending: 0, userHasFavoriteGroups: false },
      { groupRefs: [], pending: 0, userHasFavoriteGroups: false },
    ])
  })
})
