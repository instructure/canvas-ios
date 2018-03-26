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
import TabsActions from './actions'
import handleAsync from '../../../utils/handleAsync'
import { parseErrorMessage } from '../../../redux/middleware/error-handler'

export let defaultState: TabsState = { tabs: [], pending: 0 }

let { refreshTabs } = TabsActions

export const tabs: Reducer<TabsState, any> = handleActions({
  [refreshTabs.toString()]: handleAsync({
    pending: (state) => ({ ...state, pending: state.pending + 1, error: undefined }),
    resolved: (state, { result }) => {
      return {
        ...state,
        tabs: result.data,
        pending: state.pending - 1,
        error: undefined,
      }
    },
    rejected: (state, { error }) => {
      return {
        ...state,
        error: parseErrorMessage(error),
        pending: state.pending - 1,
      }
    },
  }),
}, defaultState)
