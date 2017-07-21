// @flow

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  FlatList,
} from 'react-native'
import { getSession } from '../../../api/session'
import CommentRow, { type CommentRowProps, type CommentContent } from './CommentRow'
import CommentInput, { type Comment } from './CommentInput'
import DrawerState from '../utils/drawer-state'
import SubmissionCommentActions, { type CommentActions } from './actions'
import SpeedGraderActions, { type SpeedGraderActionsType } from '../actions'
import { type SubmittedContentDataProps } from './SubmittedContent'
import CommentStatus from './CommentStatus'
import Images from '../../../images'
import i18n from 'format-message'
import filesize from 'filesize'
import striptags from 'striptags'

export class CommentsTab extends Component<any, CommentsTabProps, any> {
  constructor (props: CommentsTabProps) {
    super(props)

    this.state = { shouldShowStatus: this.props.commentRows.some(c => c.pending) }
  }

  makeAComment = (comment: Comment) => {
    const {
      courseID,
      assignmentID,
      userID,
    } = this.props
    this.setState({ shouldShowStatus: true })
    this.props.makeAComment(
      courseID,
      assignmentID,
      userID,
      { ...comment, groupComment: !this.props.gradeIndividually },
    )
  }

  deletePendingComment = (localID: string) => {
    this.props.deletePendingComment(
      this.props.assignmentID,
      this.props.userID,
      localID
    )
  }

  switchFile = (submissionID: string, attemptIndex: number, attachmentIndex: number) => {
    this.props.selectSubmissionFromHistory(submissionID, attemptIndex)
    this.props.selectFile(submissionID, attachmentIndex)
  }

  renderComment = ({ item }: { item: CommentRowProps }) =>
    <CommentRow
      {...item}
      anonymous={this.props.anonymous}
      testID={'submission-comment-' + item.key}
      style={{ transform: [{ rotate: '180deg' }] }}
      retryPendingComment={this.makeAComment}
      deletePendingComment={this.deletePendingComment}
      switchFile={this.switchFile}
      localID={item.key}
    />

  statusComplete = () => {
    this.setState({ shouldShowStatus: false })
  }

  render () {
    // $FlowFixMe
    const rows = this.props.commentRows
    let hasPending = this.props.commentRows.some(c => c.pending)
    return (
      <View style={{ flex: 1 }}>
        <FlatList
          showsVerticalScrollIndicator={false}
          style={{ transform: [{ rotate: '180deg' }] }}
          data={rows}
          renderItem={this.renderComment}
        />
        { this.state.shouldShowStatus &&
          <CommentStatus
            isDone={!hasPending}
            animationComplete={this.statusComplete}
            drawerState={this.props.drawerState}
            userID={this.props.userID}
          />
        }
        <CommentInput
          allowMediaComments={false}
          makeComment={this.makeAComment}
          drawerState={this.props.drawerState}
          disabled={hasPending}
        />
      </View>
    )
  }
}

type CommentRows = { commentRows: CommentRowData[], anonymous: boolean }

type RoutingProps = {
  courseID: string,
  assignmentID: string,
  userID: string,
  submissionID: ?string,
  gradeIndividually: boolean,
  drawerState: DrawerState,
}

type CommentsTabProps = CommentRows & RoutingProps & CommentActions & SpeedGraderActionsType

type CommentRowData = {
  error?: string,
  style?: Object,
  key: string,
  name: string,
  date: Date,
  avatarURL: string,
  from: 'me' | 'them',
  contents: CommentContent,
  pending: number,
}

function extractComments (submission: SubmissionComments): Array<CommentRowData> {
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
      pending: 0,
    }))
}

function contentForAttempt (attempt: Submission, assignment: Assignment): Array<SubmittedContentDataProps> {
  switch (attempt.submission_type) {
    case 'online_text_entry':
      return [{
        contentID: 'text',
        icon: Images.document,
        title: i18n('Text Submission'),
        subtitle: striptags(attempt.body || ''),
      }]
    case 'online_url':
      return [{
        contentID: 'url',
        icon: Images.speedGrader.submissions.url,
        title: i18n('URL Submission'),
        subtitle: attempt.url || '',
      }]
    case 'online_upload':
      const attachments = attempt.attachments || []
      return attachments.map(attachment => ({
        contentID: `attachment-${attachment.id}`,
        icon: Images.document,
        title: attachment.display_name,
        subtitle: filesize(attachment.size),
      }))
    case 'media_recording':
      if (!attempt.media_comment) {
        return []
      }
      const mediaType = attempt.media_comment.media_type
      const media = mediaType === 'audio'
        ? { icon: Images.speedGrader.submissions.audio, subtitle: i18n('Audio') }
        : { icon: Images.speedGrader.submissions.video, subtitle: i18n('Video') }
      return [{
        ...media,
        contentID: 'attachment-media-comment',
        title: i18n('Media Submission'),
      }]
    case 'discussion_topic':
      if (attempt.discussion_entries == null ||
        attempt.discussion_entries.length === 0 ||
        attempt.discussion_entries[0].message == null) {
        return []
      }
      const firstMessage = attempt.discussion_entries[0].message
      return [{
        contentID: 'attachment-discussion-entry',
        icon: Images.speedGrader.submissions.discussion,
        title: i18n('Discussion Submission'),
        subtitle: striptags(firstMessage || ''),
      }]
    case 'online_quiz':
      return [{
        contentID: 'attachment-quiz-submission',
        icon: Images.speedGrader.submissions.quiz,
        title: i18n('Quiz Submission'),
        subtitle: i18n('Attempt {number}', { number: attempt.attempt }),
      }]
    case 'external_tool':
      let toolURL = ''
      if (assignment.external_tool_tag_attributes &&
        assignment.external_tool_tag_attributes.url) {
        toolURL = assignment.external_tool_tag_attributes.url
      }
      return [{
        contentID: 'attachment-lti-submission',
        icon: Images.speedGrader.submissions.lti,
        title: i18n('External Tool Submission'),
        subtitle: toolURL,
      }]
  }
  return []
}

function rowForSubmission (user: User, attempt: Submission, assignment: Assignment): CommentRowData {
  const attemptNumber = attempt.attempt || 0
  const submittedAt = attempt.submitted_at || ''

  const items = contentForAttempt(attempt, assignment)
  return {
    key: `submission-${attemptNumber}`,
    name: user.name,
    avatarURL: user.avatar_url,
    from: 'them',
    date: new Date(submittedAt),
    contents: {
      type: 'submission',
      items: items,
      submissionID: attempt.id,
      attemptIndex: attemptNumber - 1,
    },
    pending: 0,
  }
}

function extractAttempts (submission: SubmissionWithHistory, assignment: Assignment): Array<CommentRowData> {
  return submission.submission_history
    .map(attempt => rowForSubmission(submission.user, attempt, assignment))
}

function extractPendingComments (assignments: ?AssignmentContentState, userID): Array<CommentRowData> {
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
    pending: pending.pending,
    error: pending.error || undefined, // this fixes flow even though error could already be undefined...
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
  const attempts = submission ? extractAttempts(submission, assignments.data) : []

  const commentRows = [
    ...comments,
    ...attempts,
    ...pendingComments,
  ].sort((c1, c2) => c2.date.getTime() - c1.date.getTime())

  return {
    commentRows,
    anonymous: !!assignments.anonymousGradingOn,
  }
}

const Connected = connect(
  mapStateToProps,
  { ...SubmissionCommentActions, ...SpeedGraderActions }
)(CommentsTab)

export default (Connected: any)
