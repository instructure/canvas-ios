/* @flow */

import { createAction } from 'redux-actions'
import canvas from '../../api/canvas-api'

export function createInboxAction (api: any, scope: InboxScope): any {
  return {
    promise: api.getConversations(scope),
  }
}

export let InboxActions: (typeof canvas) => any = (api) => ({
  refreshInboxAll: createAction('inbox.refresh-all', () => {
    return createInboxAction(api, 'all')
  }),
  refreshInboxUnread: createAction('inbox.refresh-unread', () => {
    return createInboxAction(api, 'unread')
  }),
  refreshInboxStarred: createAction('inbox.refresh-starred', () => {
    return createInboxAction(api, 'starred')
  }),
  refreshInboxSent: createAction('inbox.refresh-sent', () => {
    return createInboxAction(api, 'sent')
  }),
  refreshInboxArchived: createAction('inbox.refresh-archived', () => {
    return createInboxAction(api, 'archived')
  }),
  updateInboxSelectedScope: createAction('inbox.update-scope', (selectedScope: InboxScope) => {
    return selectedScope
  }),
})

export default (InboxActions(canvas): any)
