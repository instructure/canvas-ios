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
import { getSession } from '../../canvas-api/session'

const { refreshCanMasquerade } = Actions
const defaultState: UserInfo = {
  canMasquerade: false,
}

function isSiteAdmin () {
  const session = getSession()
  return session ? session.baseURL.match(/siteadmin/) : false
}

export const userInfo: Reducer<UserInfo, any> = handleActions({
  [refreshCanMasquerade.toString()]: handleAsync({
    pending: (state) => {
      return state
    },
    resolved: (state, { result }) => {
      return {
        ...state,
        canMasquerade: result.data.reduce((memo, role) => {
          return memo || isSiteAdmin() || (role.permissions.become_user && role.permissions.become_user.enabled)
        }, false),
      }
    },
    rejected: (state) => {
      return {
        ...state,
        canMasquerade: false || isSiteAdmin(),
      }
    },
  }),
}, defaultState)
