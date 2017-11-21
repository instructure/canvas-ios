//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

// @flow

export type File = {
  id: string,
  display_name: string,
  url: string,
  size: number,
  thumbnail_url: number,
  mime_class: string,
}

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
  submission_type: ?SubmissionType,
  body: ?string,
  preview_url: string,
  attempt: ?number,
  attachments?: Array<Attachment>,
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