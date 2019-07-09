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
  createDiscussion: createAction('discussions.edit.create', (context: CanvasContext, contextID: string, params: CreateDiscussionParameters) => {
    return {
      promise: api.createDiscussion(context, contextID, params),
      params,
      handlesError: true,
      context,
      contextID,
    }
  }),
  updateDiscussion: createAction('discussions.edit.update', (context: CanvasContext, contextID: string, params: UpdateDiscussionParameters) => {
    return {
      promise: api.updateDiscussion(context, contextID, params),
      params,
      handlesError: true,
      context,
      contextID,
    }
  }),
  deleteDiscussion: createAction('discussions.edit.delete', (context: CanvasContext, contextID: string, discussionID: string) => {
    return {
      promise: api.deleteDiscussion(context, contextID, discussionID),
      discussionID,
      context,
      contextID,
    }
  }),
  subscribeDiscussion: createAction('discussions.edit.subscribe', (context: CanvasContext, contextID: string, discussionID: string, subscribed: boolean) => {
    return {
      promise: api.subscribeDiscussion(context, contextID, discussionID, subscribed),
      discussionID,
      context,
      contextID,
      subscribed,
    }
  }),
  deletePendingNewDiscussion: createAction('discussions.edit.deletePendingNew', (context: CanvasContext, contextID: string) => ({
    context,
    contextID,
  })),
})

export default (Actions(canvas): *)
