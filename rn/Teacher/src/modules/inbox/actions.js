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
