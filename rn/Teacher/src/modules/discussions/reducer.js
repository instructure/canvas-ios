/* @flow */

import { Reducer } from 'redux'
import { asyncRefsReducer } from '../../redux/async-refs-reducer'
import { handleActions } from 'redux-actions'
import handleAsync from '../../utils/handleAsync'
import { default as ListActions } from './list/actions'
import i18n from 'format-message'

const { refreshDiscussions } = ListActions

export const refs: Reducer<AsyncRefs, any> = asyncRefsReducer(
  refreshDiscussions.toString(),
  i18n('There was a problem loading discussions.'),
  ({ result }) => result.data.map(discussion => discussion.id)
)

export const discussionData: Reducer<DiscussionState, any> = handleActions({
  [refreshDiscussions.toString()]: handleAsync({
    resolved: (state, { result }) => {
      const incoming = result.data
        .reduce((incoming, discussion) => ({
          ...incoming,
          [discussion.id]: {
            data: discussion,
            pending: 0,
            error: null,
          },
        }), {})
      return { ...state, ...incoming }
    },
  }),
}, {})

export function discussions (state: any = {}, action: any): any {
  let newState = state
  return discussionData(newState, action)
}
