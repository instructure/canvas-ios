// @flow

import template, { type Template } from '../../../utils/template'
import { user } from './users'

export const submission: Template<Submission> = template({
  id: '32',
  user: user({ id: '55' }),
  user_id: '55',
  grade: 'B-',
  submitted_at: '2017-04-05T15:12:45Z',
  excused: false,
  late: false,
  workflow_state: 'submitted',
  attachments: [],
  submission_type: 'online_text_entry',
  body: 'This is my submission!',
  attempt: 1,
  grade_matches_current_submission: true,
})

export function submissionHistory (submissionOverrides: Array<Object> = [submission()], commentOverrides: Array<Object> = []): SubmissionWithHistory {
  const submissionHistory = submissionOverrides.map(submission)

  const comments = commentOverrides.map(submissionComment)

  return {
    ...submissionHistory[0],
    submission_history: submissionHistory,
    submission_comments: comments,
  }
}

export const submissionCommentAuthor: Template<submissionCommentAuthor> = template({
  id: '55',
  display_name: 'Severus Snape',
  avatar_image_url: 'http://fillmurray.com/499/355',
  html_url: 'https://hogwarts.canvaslms.com/users/55',
})

const defaultAuthor = submissionCommentAuthor()

export const submissionComment: Template<SubmissionComment> = template({
  id: '356',
  author_id: defaultAuthor.id,
  author_name: defaultAuthor.display_name,
  author: submissionCommentAuthor(),
  comment: 'a comment from Snape',
  created_at: '2017-03-17T19:15:25Z',
  media_comment: undefined,
})

export const submissionSummary: Template<SubmissionSummary> = template({
  graded: 1,
  ungraded: 1,
  not_submitted: 0,
})
