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
})

export default (Actions(canvas): *)
