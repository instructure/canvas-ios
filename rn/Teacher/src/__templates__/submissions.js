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

import template, { type Template } from '../utils/template'
import { user } from './users'

export const submission: Template<Submission> = template({
  id: '32',
  user: user({ id: '55' }),
  user_id: '55',
  grade: 'B-',
  submitted_at: '2017-04-05T15:12:45Z',
  excused: false,
  late: false,
  missing: false,
  workflow_state: 'submitted',
  attachments: [],
  submission_type: 'online_text_entry',
  body: 'This is my submission!',
  attempt: 1,
  grade_matches_current_submission: true,
  preview_url: '',
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
