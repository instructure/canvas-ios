// @flow

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  FlatList,
} from 'react-native'
import { getSession } from '../../../api/session'
import CommentRow, { type CommentRowProps } from './CommentRow'
import CommentInput from './CommentInput'
import DrawerState from '../utils/drawer-state'
import SubmissionCommentActions, { type CommentActions } from './actions'
import { type SubmittedContentDataProps } from './SubmittedContent'
import Images from '../../../images'
import i18n from 'format-message'
import filesize from 'filesize'
import striptags from 'striptags'

const textSubmission = i18n({
  default: 'Text Submission',
  description: 'Text submitted for an assignment',
})

const urlSubmission = i18n({
  default: 'URL Submission',
  description: 'URL submitted for an assignment',
})

export class CommentsTab extends Component<any, Props, any> {
  makeAComment = (comment: SubmissionCommentParams) => {
    const {
      courseID,
      assignmentID,
      userID,
    } = this.props
    this.props.makeAComment(
      courseID,
      assignmentID,
      userID,
      comment
    )
  }

  renderComment = ({ item }: { item: CommentRowProps }) =>
    <CommentRow
      {...item}
      testID={'submission-comment-' + item.key}
      style={{ transform: [{ rotate: '180deg' }] }}
    />

  render (): any {
    const rows = this.props.commentRows || []
    return (
      <View style={{ flex: 1 }}>
        <FlatList
          showsVerticalScrollIndicator={false}
          style={{ transform: [{ rotate: '180deg' }] }}
          data={rows}
          renderItem={this.renderComment}
        />
        <CommentInput makeComment={this.makeAComment} drawerState={this.props.drawerState} />
      </View>
    )
  }
}

type CommentRows = { commentRows: Array<CommentRowProps> }

type RoutingProps = {
  courseID: string,
  assignmentID: string,
  userID: string,
  submissionID: ?string,
  drawerState: DrawerState,
}

type Props = CommentRows & RoutingProps & CommentActions

function extractComments (submission: SubmissionComments): Array<CommentRowProps> {
  const session = getSession()
  const myUserID = session ? session.user.id : '😲'

  return submission.submission_comments
    .filter(comment => !comment.media_comment) // TODO don't exclmedia comments
    .map(comment => ({
      key: 'comment-' + comment.id,
      name: comment.author_name,
      date: new Date(comment.created_at),
      avatarURL: comment.author.avatar_image_url,
      from: comment.author.id === myUserID ? 'me' : 'them',
      contents: { type: 'text', message: comment.comment },
    }))
}

function contentForAttempt (attempt: Submission): Array<SubmittedContentDataProps> {
  switch (attempt.submission_type) {
    case 'online_text_entry':
      return [{
        contentID: 'text',
        icon: Images.document,
        title: textSubmission,
        subtitle: striptags(attempt.body || ''),
      }]
    case 'online_url':
      return [{
        contentID: 'url',
        icon: Images.document,
        title: urlSubmission,
        subtitle: attempt.url || '',
      }]
    case 'online_upload':
    case 'media_recording':
      const attachments = attempt.attachments || []
      return attachments.map(attachment => ({
        contentID: `attachment-${attachment.id}`,
        icon: Images.document,
        title: attachment.display_name,
        subtitle: filesize(attachment.size),
      }))
  }
  return []
}

function rowForSubmission (user: User, attempt: Submission): CommentRowProps {
  const attemptNumber = attempt.attempt || 0
  const submittedAt = attempt.submitted_at || ''

  const items = contentForAttempt(attempt)
  return {
    key: `submission-${attemptNumber}`,
    name: user.name,
    avatarURL: user.avatar_url,
    from: 'them',
    date: new Date(submittedAt),
    contents: {
      type: 'submission',
      items: items,
    },
  }
}

function extractAttempts (submission: SubmissionWithHistory): Array<CommentRowProps> {
  return submission.submission_history
    .map(attempt => rowForSubmission(submission.user, attempt))
}

function extractPendingComments (assignments: ?AssignmentContentState, userID): Array<CommentRowProps> {
  const session = getSession()
  if (!assignments || !session) {
    return []
  }

  const pendingForStudent: Array<PendingCommentState> = assignments.pendingComments[userID] || []

  return pendingForStudent.map(pending => ({
    date: new Date(pending.timestamp),
    key: pending.localID,
    from: 'me',
    name: session.user.name,
    avatarURL: session.user.avatar_url,
    contents: pending.comment,
  }))
}

export function mapStateToProps ({ entities }: AppState, ownProps: RoutingProps): CommentRows {
  const { submissionID, userID, assignmentID } = ownProps

  const submission = submissionID &&
    entities.submissions[submissionID]
      ? entities.submissions[submissionID].submission
      : undefined

  const assignments = entities.assignments[assignmentID]

  const pendingComments = extractPendingComments(assignments, userID)
  const comments = submission ? extractComments(submission) : []
  const attempts = submission ? extractAttempts(submission) : []

  const commentRows = [
    ...comments,
    ...attempts,
    ...pendingComments,
  ].sort((c1, c2) => c2.date.getTime() - c1.date.getTime())

  return {
    commentRows,
  }
}

const Connected = connect(
  mapStateToProps,
  SubmissionCommentActions
)(CommentsTab)

export default (Connected: any)
