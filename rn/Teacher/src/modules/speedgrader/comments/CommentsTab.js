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

export class CommentsTab extends Component<any, Props, any> {

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
        <CommentInput drawerState={this.props.drawerState} />
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
type Props = CommentRows & RoutingProps

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
      contents: { type: 'comment', message: comment.comment },
    }))
}

function extractSubmissionHistory (submission: ?SubmissionHistory): Array<CommentRowProps> {
  return []
}

export function mapStateToProps ({ entities }: AppState, ownProps: RoutingProps): CommentRows {
  const submission = ownProps.submissionID &&
    entities.submissions[ownProps.submissionID]
    ? entities.submissions[ownProps.submissionID].submission : undefined

  const comments = extractComments(submission)
  const history = extractSubmissionHistory(submission)
  const commentRows = [...comments, ...history]
    .sort((c1, c2) => c2.date.getTime() - c1.date.getTime())

  return {
    commentRows,
  }
}

const Connected = connect(mapStateToProps)(CommentsTab)
export default (Connected: any)
