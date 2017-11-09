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

/* @flow */

import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import Actions from './actions'
import handleAsync from '../../utils/handleAsync'

export type UserProfileState = {}

const { refreshUsers } = Actions

export let defaultState: UserProfileState = { }

export const users: Reducer<UserProfileState, any> = handleActions({
  [refreshUsers.toString()]: handleAsync({
    pending: (state, { userIDs }) => {
      let entities = userIDs.reduce((prev, id) => {
        prev[id] = {
          ...state[id],
          pending: true,
        }
        return prev
      }, {})

      return {
        ...state,
        ...entities,
      }
    },
    resolved: (state, { result }) => {
      let entities = {}
      result.data.forEach((entity) => {
        entities[entity.id] =
        {
          data: entity,
          pending: false,
        }
      })
      return {
        ...state,
        ...entities,
      }
    },
    rejected: (state, { userIDs }) => {
      let entities = userIDs.reduce((prev, id) => {
        prev[id] = {
          ...state[id],
          pending: false,
        }
        return prev
      }, {})

      return {
        ...state,
        ...entities,
      }
    },
  }),
}, defaultState)
