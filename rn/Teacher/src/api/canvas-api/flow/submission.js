// @flow

export type Submission = {
  +user: {
    +id: string,
    +name: string,
    +sortable_name: string,
    +short_name: string,
    +avatar_url: string,
  },
  +grade?: ?string,
  +submitted_at: string,
}

export type SubmissionHistory = {
  +submission_history: Submission[],
}

export type SubmissionComments = {
  +submission_comments: SubmissionComment[],
}

export type SubmissionWithHistory =
  Submission &
  SubmissionHistory &
  SubmissionComments

export type SubmissionCommentAuthor = {
  +id: string,
  +display_name: string,
  +avatar_image_url: string,
  +html_url: string,
}

export type SubmissionComment = {
  +id: string,
  +author_id: string,
  +author_name: string,
  +author: SubmissionCommentAuthor,
  +comment: string,
}
