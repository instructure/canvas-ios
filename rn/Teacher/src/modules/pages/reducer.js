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

import { default as ListActions } from './list/actions'
import { default as DetailsActions } from './details/actions'

const { refreshedPages } = ListActions
const { refreshedPage } = DetailsActions

export const refs: Reducer<AsyncRefs, any> = handleActions({
  [refreshedPages.toString()]: (state, { payload: { pages } }) => ({
    ...state,
    pending: 0,
    refs: pages.map(({ url }) => url),
  }),
  [refreshedPage.toString()]: (state, { payload: { page } }) => ({
    ...state,
    pending: 0,
    refs: [...(state.refs || []).filter(ref => ref !== page.url), page.url],
  }),
}, {})

export const entities: Reducer<PagesState, any> = handleActions({
  [refreshedPages.toString()]: (state, { payload: { pages } }) => ({
    ...state,
    ...pages.reduce((memo, page) => ({
      ...memo,
      [page.url]: { data: page },
    }), {}),
  }),
  [refreshedPage.toString()]: (state, { payload: { page } }) => ({
    ...state,
    [page.url]: { data: page },
  }),
}, {})
