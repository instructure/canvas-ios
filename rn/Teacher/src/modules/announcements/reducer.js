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
import handleAsync from '../../utils/handleAsync'
import { asyncRefsReducer } from '../../redux/async-refs-reducer'
import { default as ListActions } from './list/actions'
import { default as EditActions } from '../discussions/edit/actions'
import i18n from 'format-message'
import composeReducers from '../../redux/compose-reducers'

const { refreshAnnouncements } = ListActions
const { createDiscussion, deleteDiscussion } = EditActions

const list: Reducer<AsyncRefs, any> = asyncRefsReducer(
  refreshAnnouncements.toString(),
  i18n('There was a problem loading the announcements.'),
  ({ result }) => result.data.map(announcement => announcement.id)
)

const refsChanges: Reducer<AsyncRefs, any> = handleActions({
  [createDiscussion.toString()]: handleAsync({
    resolved: (state, { result: { data } }) => ({
      ...state,
      refs: [...state.refs, data.id],
    }),
  }),
  [deleteDiscussion.toString()]: handleAsync({
    resolved: (state, { discussionID }) => ({
      ...state,
      refs: (state.refs || []).filter(ref => ref !== discussionID),
    }),
  }),
}, {})

export const refs: Reducer<AsyncRefs, any> = composeReducers(list, refsChanges)
