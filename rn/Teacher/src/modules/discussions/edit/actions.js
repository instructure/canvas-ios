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

export let Actions = (api: CanvasApi): * => ({
  createDiscussion: createAction('discussions.edit.create', (courseID: string, params: CreateDiscussionParameters) => {
    return {
      promise: api.createDiscussion(courseID, params),
      params,
      handlesError: true,
      courseID,
    }
  }),
  updateDiscussion: createAction('discussions.edit.update', (courseID: string, params: UpdateDiscussionParameters) => {
    return {
      promise: api.updateDiscussion(courseID, params),
      params,
      handlesError: true,
      courseID,
    }
  }),
  deleteDiscussion: createAction('discussions.edit.delete', (courseID: string, discussionID: string) => {
    return {
      promise: api.deleteDiscussion(courseID, discussionID),
      discussionID,
      courseID,
    }
  }),
  subscribeDiscussion: createAction('discussions.edit.subscribe', (courseID: string, discussionID: string, subscribed: boolean) => {
    return {
      promise: api.subscribeDiscussion(courseID, discussionID, subscribed),
      discussionID,
      courseID,
      subscribed,
    }
  }),
  deletePendingNewDiscussion: createAction('discussions.edit.deletePendingNew', (courseID: string) => ({
    courseID,
  })),
})

export default (Actions(canvas): *)
