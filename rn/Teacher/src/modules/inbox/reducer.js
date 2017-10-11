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

import Actions from './actions'
import handleAsync from '../../utils/handleAsync'
import { handleActions } from 'redux-actions'
import { Reducer, combineReducers } from 'redux'
import i18n from 'format-message'
import fromPairs from 'lodash/fromPairs'
import { asyncRefsReducer } from '../../redux/async-refs-reducer'
import { parseErrorMessage } from '../../redux/middleware/error-handler'

const {
  refreshInboxAll,
  refreshInboxUnread,
  refreshInboxStarred,
  refreshInboxSent,
  refreshInboxArchived,
  updateInboxSelectedScope,
  refreshConversationDetails,
  starConversation,
  unstarConversation,
  deleteConversation,
  deleteConversationMessage,
  markAsRead,
} = Actions

export function createScopeHandler (action: string): Function {
  return asyncRefsReducer(
    action,
    i18n('There was an problem loading your messages.'),
    ({ result }) => {
      return result.data.map(c => c.id)
    }
  )
}

export function createStarEntityHandler (starred: boolean): { [string]: Function } {
  return handleAsync({
    pending: (state, { conversationID }) => {
      const convoState = state[conversationID]
      if (!convoState) return state
      return {
        ...state,
        [conversationID]: {
          ...convoState,
          data: {
            ...convoState.data,
            starred,
          },
        },
      }
    },
    rejected: (state, { conversationID }) => {
      const convoState = state[conversationID]
      if (!convoState) return state
      return {
        ...state,
        [conversationID]: {
          ...convoState,
          data: {
            ...convoState.data,
            starred: !starred,
          },
        },
      }
    },
  })
}

export function entityExtractor (): { [string]: Function } {
  return handleAsync({
    resolved: (state, { result }) => {
      const pairs = result.data.map((c) => {
        const current = (state[c.id] || { data: {} }).data
        return [c.id, {
          data: {
            ...current,
            ...c,
          },
        }]
      })
      return {
        ...state,
        ...fromPairs(pairs),
      }
    },
  })
}

export function detailEntity (): { [string]: Function } {
  return handleAsync({
    pending: (state, { conversationID }) => {
      const convoState = state[conversationID] || {}
      return {
        ...state,
        [conversationID]: {
          ...convoState,
          pending: 1,
          error: null,
        },
      }
    },
    resolved: (state, { result, conversationID }) => {
      const convoState = state[conversationID]
      return {
        ...state,
        [conversationID]: {
          ...convoState,
          data: result.data,
          pending: 0,
          error: null,
        },
      }
    },
    rejected: (state, { conversationID }) => {
      const convoState = state[conversationID]
      return {
        ...state,
        [conversationID]: {
          ...convoState,
          pending: 0,
          error: i18n('An error occured while fetching this conversation.'),
        },
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
  [refreshConversationDetails.toString()]: detailEntity(),
  [starConversation.toString()]: createStarEntityHandler(true),
  [unstarConversation.toString()]: createStarEntityHandler(false),
  [deleteConversation.toString()]: handleAsync({
    pending: (state, { conversationID }) => ({
      ...state,
      [conversationID]: {
        ...state[conversationID],
        pending: (state[conversationID] && state[conversationID].pending || 0) + 1,
        error: null,
      },
    }),
    resolved: (state, { conversationID }) => {
      return Object.keys(state).reduce((incoming, current) => {
        return current === conversationID ? incoming : { ...incoming, [current]: state[current] }
      }, {})
    },
    rejected: (state, { conversationID, error }) => ({
      ...state,
      [conversationID]: {
        ...state[conversationID],
        pending: (state[conversationID] && state[conversationID].pending || 1) - 1,
        error: parseErrorMessage(error),
      },
    }),
  }),
  [deleteConversationMessage.toString()]: handleAsync({
    pending: (state, { conversationID, messageID }) => ({
      ...state,
      [conversationID]: {
        ...state[conversationID],
        data: {
          ...state[conversationID].data,
          messages: state[conversationID].data.messages.map(message => {
            if (message.id === messageID) {
              return {
                ...message,
                pendingDelete: true,
              }
            } else {
              return message
            }
          }),
        },
      },
    }),
    resolved: (state, { conversationID, messageID }) => {
      if (state[conversationID].data.messages.length === 1 &&
          state[conversationID].data.messages[0].id === messageID) {
        return {
          ...state,
          [conversationID]: undefined,
        }
      }

      return {
        ...state,
        [conversationID]: {
          ...state[conversationID],
          data: {
            ...state[conversationID].data,
            messages: state[conversationID].data.messages.filter(message => message.id !== messageID),
          },
        },
      }
    },
    rejected: (state, { conversationID, messageID }) => ({
      ...state,
      [conversationID]: {
        ...state[conversationID],
        data: {
          ...state[conversationID].data,
          messages: state[conversationID].data.messages.map(message => {
            if (message.id === messageID) {
              let newMessage = { ...message }
              delete newMessage.pendingDelete
              return newMessage
            } else {
              return message
            }
          }),
        },
      },
    }),
  }),
  [markAsRead.toString()]: handleAsync({
    pending: (state, { conversationID }) => {
      return {
        ...state,
        [conversationID]: {
          ...state[conversationID],
          data: {
            ...state[conversationID].data,
            workflow_state: 'read',
          },
        },
      }
    },
    rejected: (state, { conversationID }) => {
      return {
        ...state,
        [conversationID]: {
          ...state[conversationID],
          data: {
            ...state[conversationID].data,
            workflow_state: 'unread',
          },
        },
      }
    },
  }),
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
