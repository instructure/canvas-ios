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
import canvas from 'instructure-canvas-api'

export let Actions = (api: CanvasApi): * => ({
  refreshDiscussionEntries: createAction('discussionDetailEntries.refresh', (courseID: string, discussionID: string, includeNewEntries: boolean) => {
    return {
      promise: Promise.all([
        api.getAllDiscussionEntries(courseID, discussionID, includeNewEntries),
        api.getDiscussion(courseID, discussionID),
      ]).then(([view, discussion]) => {
        if (discussion.data.assignment_id) {
          return Promise.all([
            Promise.resolve(view),
            Promise.resolve(discussion),
            api.getAssignment(courseID, discussion.data.assignment_id),
          ])
        }
        return Promise.resolve([view, discussion])
      }),
      courseID,
      discussionID,
    }
  }),
  refreshSingleDiscussion: createAction('discussions.details.refreshSingle', (courseID: string, discussionID: string) => {
    return {
      promise: api.getDiscussion(courseID, discussionID),
      discussionID,
    }
  }),
  deleteDiscussionEntry: createAction('discussionDetail.delete-entry', (courseID: string, discussionID: string, entryID: string, localIndexPath: number[]) => {
    return {
      promise: api.deleteDiscussionEntry(courseID, discussionID, entryID),
      courseID,
      discussionID,
      entryID,
      localIndexPath,
    }
  }),
  createEntry: createAction('discussions.details.createEntry', (courseID: string, discussionID: string, entryID: string = '', parameters: CreateEntryParameters, indexPath: number[], lastReplyAt: string) => {
    return {
      promise: api.createEntry(courseID, discussionID, entryID, parameters),
      courseID,
      discussionID,
      entryID,
      indexPath,
      lastReplyAt,
    }
  }),
  markEntryAsRead: createAction('discussions.details.markEntryAsRead', (courseID: string, discussionID: string, entryID: string) => {
    return {
      promise: api.markEntryAsRead(courseID, discussionID, entryID),
      discussionID,
    }
  }),
  markAllAsRead: createAction('discussions.details.markAllAsRead', (courseID: string, discussionID: string, oldUnreadCount: number) => {
    return {
      promise: api.markAllAsRead(courseID, discussionID),
      discussionID,
      oldUnreadCount,
    }
  }),
  editEntry: createAction('discussions.details.editEntry', (courseID: string, discussionID: string, entryID: string, parameters: CreateEntryParameters, indexPath: number[]) => {
    return {
      promise: api.editEntry(courseID, discussionID, entryID, parameters),
      courseID,
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
