//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

/* @flow */

import { createAction } from 'redux-actions'
import canvas from '../../../canvas-api'

export let Actions = (api: CanvasApi): * => ({
  refreshDiscussionEntries: createAction('discussionDetailEntries.refresh', (context: string, contextID: string, discussionID: string, includeNewEntries: boolean) => {
    return {
      promise: Promise.all([
        api.getAllDiscussionEntries(context, contextID, discussionID, includeNewEntries),
        api.getDiscussion(context, contextID, discussionID),
      ]).then(([view, discussion]) => {
        if (discussion.data.assignment_id && context !== 'groups') {
          return Promise.all([
            Promise.resolve(view),
            Promise.resolve(discussion),
            api.getAssignment(contextID, discussion.data.assignment_id),
          ])
        }
        return Promise.resolve([view, discussion])
      }),
      context,
      contextID,
      discussionID,
      handlesError: true,
    }
  }),
  refreshSingleDiscussion: createAction('discussions.details.refreshSingle', (context: string, contextID: string, discussionID: string) => {
    return {
      promise: api.getDiscussion(context, contextID, discussionID),
      discussionID,
    }
  }),
  deleteDiscussionEntry: createAction('discussionDetail.delete-entry', (context: string, contextID: string, discussionID: string, entryID: string, localIndexPath: number[]) => {
    return {
      promise: api.deleteDiscussionEntry(context, contextID, discussionID, entryID),
      context,
      contextID,
      discussionID,
      entryID,
      localIndexPath,
    }
  }),
  createEntry: createAction('discussions.details.createEntry', (context: string, contextID: string, discussionID: string, entryID: string = '', parameters: CreateEntryParameters, indexPath: number[], lastReplyAt: string) => {
    return {
      promise: api.createEntry(context, contextID, discussionID, entryID, parameters),
      context,
      contextID,
      discussionID,
      entryID,
      indexPath,
      lastReplyAt,
    }
  }),
  markEntryAsRead: createAction('discussions.details.markEntryAsRead', (context: string, contextID: string, discussionID: string, entryID: string) => {
    return {
      promise: api.markEntryAsRead(context, contextID, discussionID, entryID),
      discussionID,
      entryID,
    }
  }),
  markEntryAsUnread: createAction('discussions.details.markEntryAsUnread', (context: string, contextID: string, discussionID: string, entryID: string) => {
    return {
      promise: api.markEntryAsUnread(context, contextID, discussionID, entryID),
      discussionID,
      entryID,
    }
  }),
  markAllAsRead: createAction('discussions.details.markAllAsRead', (context: string, contextID: string, discussionID: string, oldUnreadCount: number) => {
    return {
      promise: api.markAllAsRead(context, contextID, discussionID),
      discussionID,
      oldUnreadCount,
    }
  }),
  editEntry: createAction('discussions.details.editEntry', (context: string, contextID: string, discussionID: string, entryID: string, parameters: CreateEntryParameters, indexPath: number[]) => {
    return {
      promise: api.editEntry(context, contextID, discussionID, entryID, parameters),
      context,
      contextID,
      discussionID,
      entryID,
      indexPath,
    }
  }),
  deletePendingReplies: createAction('discussions.details.deletePendingReplies', (discussionID) => ({
    discussionID,
  })),
  rateEntry: createAction('discussions.details.rateEntry', (context: string, contextID: string, discussionID: string, entryID: string, rating: number, path: Array<number>) => {
    return {
      promise: api.rateEntry(context, contextID, discussionID, entryID, rating),
      context,
      contextID,
      discussionID,
      entryID,
      rating,
      path,
    }
  }),
})

export default (Actions(canvas): *)
