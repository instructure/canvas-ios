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

/* eslint-disable flowtype/require-valid-file-annotation */

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  FlatList,
  LayoutAnimation,
  ActionSheetIOS,
  AppState,
} from 'react-native'
import { getSession } from '@canvas-api'
import CommentRow, { type CommentRowProps, type CommentContent } from './CommentRow'
import CommentInput, { type Comment } from './CommentInput'
import DrawerState from '../utils/drawer-state'
import SubmissionCommentActions from './actions'
import SpeedGraderActions from '../actions'
import { type SubmittedContentDataProps } from './SubmittedContent'
import CommentStatus from './CommentStatus'
import Images from '@images'
import MediaComment, { type Media } from '@common/components/MediaComment'
import Permissions from '@common/permissions'
import i18n from 'format-message'
import bytes from '@utils/locale-bytes'
import striptags from 'striptags'
import ListEmptyComponent from '../../../common/components/ListEmptyComponent'

const Actions = {
  ...SubmissionCommentActions,
  ...SpeedGraderActions,
}

export class CommentsTab extends Component<CommentsTabProps, any> {
  constructor (props: CommentsTabProps) {
    super(props)

    this.state = {
      shouldShowStatus: this.props.commentRows.some(c => c.pending),
      showingNewMediaComment: null,
      appState: AppState.currentState,
    }
  }

  componentDidMount () {
    AppState.addEventListener('change', this._handleAppStateChange)
  }

  componentWillUnmount () {
    AppState.removeEventListener('change', this._handleAppStateChange)
  }

  componentWillReceiveProps (newProps: CommentsTabProps) {
    if (this.props.isCurrentStudent && !newProps.isCurrentStudent) {
      this.setState({ showingNewMediaComment: null })
    }
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

  addMedia = () => {
    ActionSheetIOS.showActionSheetWithOptions({
      options: [
        i18n('Record Audio'),
        i18n('Record Video'),
        i18n('Cancel'),
      ],
      cancelButtonIndex: 2,
    }, (i) => [this.addAudio, this.addVideo, () => {}][i]())
  }

  addAudio = async () => {
    const permitted = await Permissions.checkMicrophone()
    if (permitted) {
      LayoutAnimation.easeInEaseOut()
      this.setState({ showingNewMediaComment: 'audio' })
    } else {
      Permissions.alert('microphone')
    }
  }

  addVideo = async () => {
    const permitted = await Permissions.checkCamera()
    if (permitted) {
      LayoutAnimation.easeInEaseOut()
      this.setState({ showingNewMediaComment: 'video' })
    } else {
      Permissions.alert('camera')
    }
  }

  makeAMediaComment = (media: Media) => {
    const { mediaID, mediaType, filePath } = media
    const {
      courseID,
      assignmentID,
      userID,
    } = this.props
    LayoutAnimation.easeInEaseOut()
    this.setState({
      shouldShowStatus: true,
      showingNewMediaComment: null,
    })
    this.props.makeAComment(
      courseID,
      assignmentID,
      userID,
      {
        type: 'media',
        mediaID,
        mediaType,
        groupComment: !this.props.gradeIndividually,
      },
      filePath,
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
    this.props.drawerState.snapTo(0, true)
  }

  navigateToContextCard = (userID: string) => {
    this.props.navigator.show(
      `/courses/${this.props.courseID}/users/${userID}`,
      { modal: true },
    )
  }

  renderComment = ({ item }: { item: CommentRowProps }) =>
    <CommentRow
      {...item}
      anonymous={this.props.anonymous}
      testID={'submission-comment-' + item.key}
      retryPendingComment={this.makeAComment}
      deletePendingComment={this.deletePendingComment}
      switchFile={this.switchFile}
      localID={item.key}
      onAvatarPress={this.navigateToContextCard}
    />

  statusComplete = () => {
    this.setState({ shouldShowStatus: false })
  }

  render () {
    // $FlowFixMe
    const rows = this.props.commentRows
    let hasPending = this.props.commentRows.some(c => c.pending)
    let containerStyles = {}
    if (rows.length === 0) containerStyles = { flex: 1, justifyContent: 'center' }
    return (
      <View style={{ flex: 1 }}>
        <FlatList
          showsVerticalScrollIndicator={false}
          inverted={true}
          data={rows}
          renderItem={this.renderComment}
          ListEmptyComponent={<ListEmptyComponent title={i18n('There are no comments to display.')} />}
          contentContainerStyle={containerStyles}
        />
        { this.state.shouldShowStatus &&
          <CommentStatus
            isDone={!hasPending}
            animationComplete={this.statusComplete}
            drawerState={this.props.drawerState}
            userID={this.props.userID}
          />
        }
        { this.state.showingNewMediaComment == null &&
          <CommentInput
            makeComment={this.makeAComment}
            drawerState={this.props.drawerState}
            disabled={hasPending}
            addMedia={this.addMedia}
          />
        }
        <View
          style={{ height: this.state.showingNewMediaComment === 'audio' ? 240 : 0, overflow: 'hidden' }}
          testID='speedgrader.comments.comments-tab.audio-recorder.container'
        >
          { this.state.showingNewMediaComment === 'audio' &&
            <MediaComment
              onFinishedUploading={this.makeAMediaComment}
              onCancel={this.onMediaCommentCancel}
              mediaType='audio'
            />
          }
        </View>

        <View
          style={{ height: this.state.showingNewMediaComment === 'video' ? 235 : 0, overflow: 'hidden' }}
          testID='speedgrader.comments.comments-tab.camera.container'
        >
          { this.state.showingNewMediaComment === 'video' &&
            <View style={{ flex: 1 }}>
              <MediaComment
                onFinishedUploading={this.makeAMediaComment}
                onCancel={this.onMediaCommentCancel}
                mediaType='video'
              />
            </View>
          }
        </View>
      </View>
    )
  }

  onMediaCommentCancel = () => {
    LayoutAnimation.easeInEaseOut()
    this.setState({ showingNewMediaComment: null })
  }

  _handleAppStateChange = (nextAppState) => {
    if (nextAppState.match(/inactive|background/) && this.state.appState === 'active') {
      this.setState({ showingNewMediaComment: null })
    }
    this.setState({ appState: nextAppState })
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

type CommentsTabProps = CommentRows & RoutingProps & typeof SubmissionCommentActions & typeof SpeedGraderActions & NavigationProps

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

function extractComments (submissionComments: SubmissionComment[]): Array<CommentRowData> {
  const myUserID = getSession().user.id

  return submissionComments
    .map(comment => ({
      key: 'comment-' + comment.id,
      name: comment.author_name,
      date: new Date(comment.created_at),
      avatarURL: comment.author.avatar_image_url,
      userID: comment.author.id,
      from: comment.author.id === myUserID ? 'me' : 'them',
      contents: comment.media_comment ? contentForMediaComment(comment.media_comment) : { type: 'text', message: comment.comment },
      pending: 0,
    }))
}

function contentForMediaComment (mediaComment: MediaComment): CommentContent {
  return {
    type: 'media',
    mediaID: mediaComment.media_id,
    mediaType: mediaComment.media_type,
    url: mediaComment.url,
    displayName: mediaComment.display_name,
  }
}

function contentForAttempt (attempt: Submission, assignment: Assignment): Array<SubmittedContentDataProps> {
  switch (attempt.submission_type) {
    case 'online_text_entry':
      return [{
        contentID: 'text',
        icon: Images.speedGrader.submissions.text,
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
        icon: Images.speedGrader.submissions.document,
        title: attachment.display_name,
        subtitle: bytes(attachment.size),
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
    userID: user.id,
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
  if (!submission.submission_history) return []
  return submission.submission_history
    .filter(attempt => attempt.attempt != null)
    .map(attempt => rowForSubmission(submission.user, attempt, assignment))
}

function extractPendingComments (assignments: ?AssignmentContentState, userID): Array<CommentRowData> {
  const session = getSession()
  if (!assignments) {
    return []
  }

  const pendingForStudent: Array<PendingCommentState> = assignments.pendingComments[userID] || []
  return pendingForStudent.map(pending => ({
    date: new Date(pending.timestamp),
    key: pending.localID,
    from: 'me',
    name: session.user.name,
    avatarURL: session.user.avatar_url,
    userID: session.user.id,
    contents: pending.mediaComment ? { ...pending.comment, url: pending.mediaComment.url } : pending.comment,
    pending: pending.pending,
    error: pending.error || undefined, // this fixes flow even though error could already be undefined...
  }))
}

export function mapStateToProps ({ entities }: AppState, ownProps: RoutingProps): CommentRows {
  const { submissionID, userID, assignmentID, courseID } = ownProps

  const submission = submissionID &&
    entities.submissions[submissionID]
    ? entities.submissions[submissionID].submission
    : undefined

  const assignments = entities.assignments[assignmentID]

  const assignmentData = assignments && assignments.data
  const quiz = assignmentData && assignmentData.quiz_id && entities.quizzes[assignmentData.quiz_id].data

  const courseContent = entities.courses[courseID]

  const pendingComments = extractPendingComments(assignments, userID)
  const comments = submission && submission.submission_comments ? extractComments(submission.submission_comments) : []
  const attempts = submission ? extractAttempts(submission, assignments.data) : []

  let anonymous = (
    assignments && assignments.anonymousGradingOn ||
    quiz && quiz.anonymous_submissions ||
    courseContent && courseContent.enabledFeatures.includes('anonymous_grading')
  )

  const commentRows = [
    ...comments,
    ...attempts,
    ...pendingComments,
  ].sort((c1, c2) => c2.date.getTime() - c1.date.getTime())

  return {
    commentRows,
    anonymous,
  }
}

const Connected = connect(mapStateToProps, Actions)(CommentsTab)
export default (Connected: any)
