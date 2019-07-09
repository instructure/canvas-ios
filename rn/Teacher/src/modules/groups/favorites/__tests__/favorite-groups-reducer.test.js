//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
