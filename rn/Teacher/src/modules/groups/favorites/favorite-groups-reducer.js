//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow

import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import GroupFavoritesActions from '../favorites/actions'
import handleAsync from '../../../utils/handleAsync'

let { updateGroupFavorites, refreshGroupFavorites } = GroupFavoritesActions

export let defaultState: FavoriteGroupsState = {
  groupRefs: [],
  pending: 0,
  userHasFavoriteGroups: true,
}

export const favoriteGroups: Reducer<FavoriteGroupsState, any> = handleActions({
  [updateGroupFavorites.toString()]: handleAsync({
    resolved: (state, { result }) => {
      const favorites = result.data && result.data.data || []
      return {
        ...state,
        groupRefs: favorites,
        userHasFavoriteGroups: true,
      }
    } }),

  [refreshGroupFavorites.toString()]: handleAsync({
    resolved: (state, { result }) => {
      const favorites = result.data && result.data.data || []
      return {
        ...state,
        groupRefs: favorites,
        userHasFavoriteGroups: true,
      }
    },
    rejected: (state, { error }) => {
      let response = error && error.response || {}
      let mutatedState = { ...state }
      let userHasFavoriteGroups = true
      if (response.status === 400 && response.data && response.data.message === 'no data for scope') {
        //  favorites have never been set
        userHasFavoriteGroups = false
      }

      return {
        ...mutatedState,
        groupRefs: [],
        userHasFavoriteGroups,
      }
    },
  }),
}, defaultState)
