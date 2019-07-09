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
