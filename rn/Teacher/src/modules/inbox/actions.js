/* @flow */

import { createAction } from 'redux-actions'
import canvas from '../../api/canvas-api'

export function createInboxAction (api: any, scope: InboxScope, next?: Function): any {
  return {
    promise: next ? next() : api.getConversations(scope),
    usedNext: !!next,
  }
}

export let InboxActions: (typeof canvas) => any = (api) => ({
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
})

export default (InboxActions(canvas): any)
