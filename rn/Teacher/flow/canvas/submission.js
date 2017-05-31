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
  | 'external_tool'
  | 'discussion_topic'
  | 'online_quiz'

export type Submission = {
  id: string,
  user: User,
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

export type SubmissionCommentParams
  = { type: 'text', message: string }
