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
const { refreshedPage, deletedPage } = DetailsActions

export const refs: Reducer<AsyncRefs, any> = handleActions({
  [refreshedPages.toString()]: (state, { payload: { pages } }) => ({
    ...state,
    pending: 0,
    refs: pages.map(p => p.page_id),
  }),
  [refreshedPage.toString()]: (state, { payload: { page } }) => ({
    ...state,
    pending: 0,
    refs: [...(state.refs || []).filter(ref => ref !== page.page_id), page.page_id],
  }),
  [deletedPage.toString()]: (state, { payload: { page } }) => ({
    ...state,
    pending: 0,
    refs: [...(state.refs || []).filter(ref => ref !== page.page_id)],
  }),
}, {})

export const entities: Reducer<PagesState, any> = handleActions({
  [refreshedPages.toString()]: (state, { payload: { pages } }) => ({
    ...state,
    ...pages.reduce((memo, page) => ({
      ...memo,
      [page.page_id]: {
        data: {
          ...page,
          body: state[page.page_id] && state[page.page_id].data && state[page.page_id].data.body,
        },
      },
    }), {}),
  }),
  [refreshedPage.toString()]: (state, { payload: { page } }) => ({
    ...state,
    [page.page_id]: { data: page },
  }),
  [deletedPage.toString()]: (state, { payload: { page } }) => {
    return Object.keys(state).reduce((memo, pageID) => {
      if (pageID === page.page_id) return memo
      return { ...memo, [pageID]: state[pageID] }
    }, {})
  },
}, {})

// Responsible for removing the front_page flag from the page
// that was the front page before the refreshed page became the new
// front page.
export const frontPage: Reducer<PagesState, any> = handleActions({
  [refreshedPage.toString()]: (state, { payload: { page, courseID } }) => {
    if (!page.front_page) {
      return state
    }
    const frontPage = state.courses[courseID].pages.refs
      .map(r => state.pages[r])
      .filter(p => p)
      .map(p => p.data)
      .find(p => p.front_page)

    if (!frontPage || frontPage.page_id === page.page_id) {
      return state
    }

    return {
      ...state,
      pages: {
        ...state.pages,
        [frontPage.page_id]: {
          ...state.pages[frontPage.page_id],
          data: {
            ...frontPage,
            front_page: false,
          },
        },
      },
    }
  },
}, {})
