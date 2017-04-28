// @flow

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
}

export type SubmissionHistory = {
  submission_history: Submission[],
}

export type SubmissionComments = {
  submission_comments: SubmissionComment[],
}

export type SubmissionWithHistory
  = Submission
  & SubmissionHistory
  & SubmissionComments

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
  media_comment: ?any, // TODO media comments
}
