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

function extractComments (submission: ?SubmissionComments): Array<CommentRowProps> {
  if (!(submission && submission.submission_comments)) {
    return []
  }

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

function extractSubmissionHistory (submission: ?SubmissionHistory): Array<CommentRowProps> {
  return []
}

function extractPendingComments (assignments: ?AssignmentContentState, userID): Array<CommentRowProps> {
  const session = getSession()
  if (!assignments || !session) { return [] }
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

  const comments = extractComments(submission)
  const pendingComments = extractPendingComments(assignments, userID)
  const history = extractSubmissionHistory(submission)

  const commentRows = [
    ...comments,
    ...history,
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
