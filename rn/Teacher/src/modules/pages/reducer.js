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
