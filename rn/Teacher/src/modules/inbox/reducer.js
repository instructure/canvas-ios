// @flow

import Actions from './actions'
import handleAsync from '../../utils/handleAsync'
import { handleActions } from 'redux-actions'
import { Reducer, combineReducers } from 'redux'
import i18n from 'format-message'
import fromPairs from 'lodash/fromPairs'
import { asyncRefsReducer } from '../../redux/async-refs-reducer'

const { refreshInboxAll,
        refreshInboxUnread,
        refreshInboxStarred,
        refreshInboxSent,
        refreshInboxArchived,
        updateInboxSelectedScope } = Actions

export function createScopeHandler (action: string): Function {
  return asyncRefsReducer(
    action,
    i18n('There was an problem loading your messages.'),
    ({ result }) => {
      return result.data.sort((a, b) => {
        return new Date(b.last_message_at) - new Date(a.last_message_at)
      }).map(c => c.id)
    }
  )
}

export function entityExtractor (): { [string]: Function } {
  return handleAsync({
    resolved: (state, { result }) => {
      const pairs = result.data.map((c) => [c.id, c])
      return {
        ...state,
        ...fromPairs(pairs),
      }
    },
  })
}

export const conversations: Reducer = handleActions({
  [refreshInboxAll.toString()]: entityExtractor(),
  [refreshInboxUnread.toString()]: entityExtractor(),
  [refreshInboxStarred.toString()]: entityExtractor(),
  [refreshInboxSent.toString()]: entityExtractor(),
  [refreshInboxArchived.toString()]: entityExtractor(),
}, {})

export const inbox: Reducer<InboxState, any> = combineReducers({
  conversations,
  all: createScopeHandler(refreshInboxAll.toString()),
  unread: createScopeHandler(refreshInboxUnread.toString()),
  starred: createScopeHandler(refreshInboxStarred.toString()),
  sent: createScopeHandler(refreshInboxSent.toString()),
  archived: createScopeHandler(refreshInboxArchived.toString()),
  selectedScope: handleActions({
    [updateInboxSelectedScope.toString()]: (state, { payload }) => {
      return payload
    },
  }, 'all'),
})

export default inbox
