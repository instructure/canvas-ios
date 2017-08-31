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

import { createAction } from 'redux-actions'
import canvas from 'canvas-api'

export function createInboxAction (api: any, scope: InboxScope, next?: Function): any {
  return {
    promise: next ? next() : api.getConversations(scope),
    usedNext: !!next,
  }
}

export let InboxActions = (api: CanvasApi): * => ({
  refreshInboxAll: createAction('inbox.refresh-all', (useNext?: Function) => {
    return createInboxAction(api, 'all', useNext)
  }),
  refreshInboxUnread: createAction('inbox.refresh-unread', (useNext?: Function) => {
    return createInboxAction(api, 'unread', useNext)
  }),
  refreshInboxStarred: createAction('inbox.refresh-starred', (useNext?: Function) => {
    return createInboxAction(api, 'starred', useNext)
  }),
  refreshInboxSent: createAction('inbox.refresh-sent', (useNext?: Function) => {
    return createInboxAction(api, 'sent', useNext)
  }),
  refreshInboxArchived: createAction('inbox.refresh-archived', (useNext?: Function) => {
    return createInboxAction(api, 'archived', useNext)
  }),
  updateInboxSelectedScope: createAction('inbox.update-scope', (selectedScope: InboxScope) => {
    return selectedScope
  }),
  refreshConversationDetails: createAction('inbox.refresh-conversation', (conversationID: string) => {
    return {
      promise: api.getConversationDetails(conversationID),
      conversationID,
    }
  }),
  starConversation: createAction('inbox.star-conversation', (conversationID: string) => {
    return {
      promise: api.starConversation(conversationID),
      conversationID,
    }
  }),
  unstarConversation: createAction('inbox.unstar-conversation', (conversationID: string) => {
    return {
      promise: api.unstarConversation(conversationID),
      conversationID,
    }
  }),
  deleteConversation: createAction('inbox.delete-conversation', (conversationID: string) => {
    return {
      promise: api.deleteConversation(conversationID),
      conversationID,
    }
  }),
  markAsRead: createAction('inbox.mark-as-read', (conversationID: string) => {
    return {
      promise: api.markConversationAsRead(conversationID),
      conversationID,
    }
  }),
})

export default (InboxActions(canvas): *)
