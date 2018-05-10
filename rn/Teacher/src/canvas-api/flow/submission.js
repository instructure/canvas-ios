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

export type SubmissionType
  = 'online_text_entry'
  | 'online_url'
  | 'online_upload'
  | 'media_recording'
  | 'on_paper'
  | 'none'
  | 'basic_lti_launch' // seen in practice
  | 'external_tool' // from api docs (should be treated the same)
  | 'discussion_topic'
  | 'online_quiz'

export type SubmissionStatus =
  'none' |
  'missing' |
  'late' |
  'submitted' |
  'excused' |
  'resubmitted' |
  'unsubmitted'

export type SubmissionDiscussionEntry = {
  message: string,
}

export type TurnItInData = {
  status: 'pending' | 'scored' | 'error', // not sure about 'error'
  similarity_score: number,
  outcome_response?: {
    outcomes_tool_placement_url: ?string,
  },
}

export type Submission = {
  id: string,
  user: User,
  group?: Group,
  user_id: string,
  grade?: ?string,
  score?: ?number,
  submitted_at: ?string,
  workflow_state: 'submitted'
    | 'unsubmitted'
    | 'graded'
    | 'pending_review',
  excused: boolean,
  late: boolean,
  missing: boolean,
  submission_type: ?SubmissionType,
  body: ?string,
  preview_url: string,
  attempt: ?number,
  attachments?: Attachment[],
  url?: string,
  media_comment?: MediaComment,
  discussion_entries?: SubmissionDiscussionEntry[],
  turnitin_data?: { [string]: TurnItInData },
  grade_matches_current_submission: boolean,
}

export type SubmissionHistory = {
  submission_history: Submission[],
}

export type SubmissionComments = {
  submission_comments: SubmissionComment[],
}

export type SubmissionUser = {
  user: User,
}

export type SubmissionWithHistory
  = Submission
  & SubmissionHistory
  & SubmissionComments
  & SubmissionUser

export type SubmissionCommentAuthor = {
  id: string,
  display_name: string,
  avatar_image_url: string,
  html_url: string,
}

export type SubmissionComment = {
  id: string,
  author_id: string,
  author_name: string,
  author: SubmissionCommentAuthor,
  comment: string,
  created_at: string,
  media_comment: ?MediaComment,
}

export type SubmissionCommentParams = {
  type: 'text' | 'media',
  mediaType?: 'audio' | 'video',
  mediaID?: string,
  message?: string,
  groupComment: boolean,
}

export type SubmissionSummary = {
  graded: number,
  ungraded: number,
  not_submitted: number,
}
