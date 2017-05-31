// @flow

import { createAction } from 'redux-actions'
import canvas from '../../../api/canvas-api'
import uuid from 'uuid/v1'

export type CommentActions = {
  makeAComment: (
    courseID: string,
    assignmentID: string,
    userID: string,
    comment: SubmissionCommentParams) => void,
  deletePendingComment: (
    userID: string,
    localID: string
  ) => void,
}

export const SubmissionCommentActions = (api: typeof canvas): CommentActions => ({
  makeAComment: createAction('submissions.comments.send', (courseID: string, assignmentID: string, userID: string, comment: SubmissionCommentParams) => ({
    comment,
    assignmentID,
    userID,
    localID: uuid(),
    timestamp: new Date().toISOString(),
    promise: api.commentOnSubmission(
      courseID, assignmentID, userID, comment
    ),
    handlesError: true,
  })),

  deletePendingComment: createAction('submission.comments.delete-pending', (assignmentID: string, userID: string, localID: string) => ({
    assignmentID, userID, localID,
  })),
})

export default (SubmissionCommentActions(canvas): CommentActions)
