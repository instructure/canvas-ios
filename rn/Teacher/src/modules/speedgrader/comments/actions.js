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

import { createAction } from 'redux-actions'
import canvas from '../../../canvas-api'
import uuid from 'uuid/v1'

export const SubmissionCommentActions = (api: CanvasApi): * => ({
  makeAComment: createAction('submissions.comments.send', (courseID: string, assignmentID: string, userID: string, comment: SubmissionCommentParams, mediaFilePath?: string) => ({
    comment,
    assignmentID,
    userID,
    localID: uuid(),
    timestamp: new Date().toISOString(),
    promise: api.commentOnSubmission(
      courseID, assignmentID, userID, comment
    ),
    handlesError: true,
    mediaFilePath,
  })),

  deletePendingComment: createAction('submission.comments.delete-pending', (assignmentID: string, userID: string, localID: string) => ({
    assignmentID, userID, localID,
  })),
})

export default (SubmissionCommentActions(canvas): *)
