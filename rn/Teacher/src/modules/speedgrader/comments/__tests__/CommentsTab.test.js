//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

/* eslint-disable flowtype/require-valid-file-annotation */

import { shallow } from 'enzyme'
import { ActionSheetIOS, Alert, AppState, FlatList } from 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'
import { CommentsTab, mapStateToProps } from '../CommentsTab'
import { setSession } from '../../../../canvas-api'
import DrawerState from '../../utils/drawer-state'
import explore from '../../../../../test/helpers/explore'
import setProps from '../../../../../test/helpers/setProps'
import Permissions from '../../../../common/permissions'
import * as template from '../../../../__templates__'

const templates = {
  ...template,
  ...require('../../../../redux/__templates__/app-state'),
}

jest
  .mock('../AudioComment')
  .mock('../CommentInput', () => 'CommentInput')
  .mock('../../../../common/components/MediaComment', () => 'MediaComment')
  .mock('../../../../common/permissions')

const comments = [
  {
    key: 'comment-1',
    name: 'Mrs. Fig',
    date: new Date('2017-03-17T19:15:25Z'),
    avatarURL: 'http://fillmurray.com/332/555',
    from: 'me',
    contents: {
      type: 'text',
      comment: templates.submissionComment({ comment: 'Well?!' }),
    },
  },
  {
    key: 'comment-2',
    name: 'Dim Whitted',
    date: new Date('2017-03-17T19:23:25Z'),
    avatarURL: 'http://fillmurray.com/220/400',
    from: 'them',
    contents: {
      type: 'text',
      comment: templates.submissionComment({ message: '…' }),
    },
  },
  {
    key: 'comment-3',
    name: 'Mrs. Fig',
    date: new Date('2017-03-17T19:33:25Z'),
    avatarURL: 'http://fillmurray.com/332/555',
    from: 'me',
    contents: { type: 'media_comment' },
  },
  {
    key: 'comment-4',
    name: 'Dim Whitted',
    date: new Date('2017-03-17T19:40:25Z'),
    avatarURL: 'http://fillmurray.com/220/400',
    from: 'them',
    contents: { type: 'media_comment' },
  },
  {
    key: 'comment-5',
    name: 'Dim Whitted',
    date: new Date('2017-03-17T19:50:25Z'),
    avatarURL: 'http://fillmurray.com/220/400',
    from: 'me',
    contents: {
      type: 'media',
      mediaID: '1',
      mediaType: 'audio',
      url: 'http://canvas.instructure.com/audio.mp3',
      displayName: 'Audio Comment',
    },
  },
  {
    key: 'submission',
    name: 'Dim Whitted',
    date: new Date('2017-03-17T19:40:25Z'),
    avatarURL: 'http://fillmurray.com/220/400',
    from: 'them',
    contents: {
      type: 'submission',
      items: [{
        contentID: '1',
        icon: 0,
        title: 'Item 1',
        subtitle: 'Item 1 Subtitle',
      }],
    },
  },
]

let mediaCommentActionSheet
beforeEach(() => {
  // $FlowFixMe
  ActionSheetIOS.showActionSheetWithOptions = jest.fn((config, callback) => { mediaCommentActionSheet = callback })
  Permissions.checkMicrophone = jest.fn(() => Promise.resolve(true))
  Permissions.checkCamera = jest.fn(() => Promise.resolve(true))
})

test('comments render properly', () => {
  const tree = shallow(
    <CommentsTab commentRows={comments} drawerState={new DrawerState()}/>
  )
  expect(tree.find('FlatList').prop('data')).toHaveLength(comments.length)
})

test('empty state renders properly', () => {
  const tree = shallow(<CommentsTab commentRows={[]} drawerState={new DrawerState()}/>)
  let flatlist = tree.find('FlatList')
  expect(flatlist.prop('ListEmptyComponent').props.title).toBe('There are no comments to display.')
  expect(flatlist.prop('inverted')).toBe(false)
})

test('calling switchFile will call the correct actions', () => {
  let actions = {
    selectSubmissionFromHistory: jest.fn(),
    selectFile: jest.fn(),
  }

  const instance = renderer.create(
    <CommentsTab commentRows={comments} drawerState={new DrawerState()} {...actions} />
  ).getInstance()

  instance.switchFile('1', '2', '3')
  expect(actions.selectSubmissionFromHistory).toHaveBeenCalledWith('1', '2')
  expect(actions.selectFile).toHaveBeenCalledWith('1', '3')
})

test('selecting file closes drawer', () => {
  const props = {
    commentRows: comments,
    drawerState: {
      snapTo: jest.fn(),
    },
    selectSubmissionFromHistory: jest.fn(),
    selectFile: jest.fn(),
  }
  const tree = shallow(<CommentsTab {...props} />)
  const row = tree
    .find(FlatList)
    .dive()
    .find('[testID="submission-comment-submission"]')
    .dive()
    .find('SubmittedContent')
  row.simulate('Press')
  expect(props.drawerState.snapTo).toHaveBeenCalledWith(0, true)
})

test('adding media shows action sheet', () => {
  const spy = jest.fn()
  // $FlowFixMe
  ActionSheetIOS.showActionSheetWithOptions = spy
  const view = renderer.create(
    <CommentsTab commentRows={comments} drawerState={new DrawerState()} />
  )
  const input: any = explore(view.toJSON()).selectByType('CommentInput')
  input.props.addMedia()
  expect(spy).toHaveBeenCalledWith({
    options: ['Record Audio', 'Record Video', 'Cancel'],
    cancelButtonIndex: 2,
  }, expect.any(Function))
})

test('adding audio shows audio recorder', async () => {
  const view = renderer.create(
    <CommentsTab commentRows={comments} drawerState={new DrawerState()} />
  )
  let recorder: any = explore(view.toJSON()).selectByID('speedgrader.comments.comments-tab.audio-recorder.container')
  expect(recorder.props.style.height).toEqual(0)
  const input: any = explore(view.toJSON()).selectByType('CommentInput')
  input.props.addMedia()
  await mediaCommentActionSheet(0)
  recorder = explore(view.toJSON()).selectByID('speedgrader.comments.comments-tab.audio-recorder.container') || {}
  expect(recorder.props.style.height).toBeGreaterThan(0)
})

test('audio cancel hides audio recorder', async () => {
  const view = renderer.create(
    <CommentsTab commentRows={comments} drawerState={new DrawerState()} />
  )
  const input: any = explore(view.toJSON()).selectByType('CommentInput')
  input.props.addMedia()
  await mediaCommentActionSheet(0)
  const recorder: any = explore(view.toJSON()).selectByType('MediaComment')
  recorder.props.onCancel()
  const container: any = explore(view.toJSON()).selectByID('speedgrader.comments.comments-tab.audio-recorder.container')
  expect(container.props.style.height).toEqual(0)
})

test('hides new media comment when current student changes', async () => {
  const view = renderer.create(
    <CommentsTab commentRows={comments} drawerState={new DrawerState()} isCurrentStudent={true} />
  )
  const input: any = explore(view.toJSON()).selectByType('CommentInput')
  input.props.addMedia()
  await mediaCommentActionSheet(0)
  let container: any = explore(view.toJSON()).selectByID('speedgrader.comments.comments-tab.audio-recorder.container')
  expect(container.props.style.height).toBeGreaterThan(0)
  setProps(view, { isCurrentStudent: false })
  container = explore(view.toJSON()).selectByID('speedgrader.comments.comments-tab.audio-recorder.container')
  expect(container.props.style.height).toEqual(0)
})

test('hides new media comment when app enters background', async () => {
  let mock
  AppState.addEventListener = jest.fn((state, handler) => { mock = handler })
  const view = renderer.create(
    <CommentsTab commentRows={comments} drawerState={new DrawerState()} isCurrentStudent={true} />
  )
  const input: any = explore(view.toJSON()).selectByType('CommentInput')
  input.props.addMedia()
  await mediaCommentActionSheet(0)
  let container: any = explore(view.toJSON()).selectByID('speedgrader.comments.comments-tab.audio-recorder.container')
  expect(container.props.style.height).toBeGreaterThan(0)
  mock('background')
  container = explore(view.toJSON()).selectByID('speedgrader.comments.comments-tab.audio-recorder.container')
  expect(container.props.style.height).toEqual(0)
})

test('hides new media comment when app goes inactive', async () => {
  let mock
  AppState.addEventListener = jest.fn((state, handler) => { mock = handler })
  const view = renderer.create(
    <CommentsTab commentRows={comments} drawerState={new DrawerState()} isCurrentStudent={true} />
  )
  const input: any = explore(view.toJSON()).selectByType('CommentInput')
  input.props.addMedia()
  await mediaCommentActionSheet(0)
  let container: any = explore(view.toJSON()).selectByID('speedgrader.comments.comments-tab.audio-recorder.container')
  expect(container.props.style.height).toBeGreaterThan(0)
  mock('inactive')
  container = explore(view.toJSON()).selectByID('speedgrader.comments.comments-tab.audio-recorder.container')
  expect(container.props.style.height).toEqual(0)
})

it('makes an audio media comment', async () => {
  const spy = jest.fn()
  const props = {
    commentRows: comments,
    drawerState: new DrawerState(),
    makeAComment: spy,
    courseID: '1',
    assignmentID: '2',
    userID: '3',
    gradeIndividually: false,
  }
  const view = renderer.create(
    <CommentsTab {...props} />
  )
  const input: any = explore(view.toJSON()).selectByType('CommentInput')
  input.props.addMedia()
  await mediaCommentActionSheet(0)
  const recorder: any = explore(view.toJSON()).selectByType('MediaComment')
  recorder.props.onFinishedUploading({ mediaID: '4', mediaType: 'audio', filePath: '/file.mov' })
  expect(spy).toHaveBeenCalledWith('1', '2', '3', {
    type: 'media',
    mediaID: '4',
    mediaType: 'audio',
    groupComment: true,
  }, '/file.mov')
})

it('alerts without audio permissions', async () => {
  Permissions.checkMicrophone = jest.fn(() => Promise.resolve(false))
  const spy = jest.fn()
  Alert.alert = spy
  const view = renderer.create(
    <CommentsTab commentRows={comments} drawerState={new DrawerState()} />
  )
  const input: any = explore(view.toJSON()).selectByType('CommentInput')
  input.props.addMedia()
  await mediaCommentActionSheet(0)
  expect(spy).toHaveBeenCalledWith('Permission Needed', expect.any(String), expect.any(Array))
})

it('alerts without video permissions', async () => {
  Permissions.checkCamera = jest.fn(() => Promise.resolve(false))
  const spy = jest.fn()
  Alert.alert = spy
  const view = renderer.create(
    <CommentsTab commentRows={comments} drawerState={new DrawerState()} />
  )
  const input: any = explore(view.toJSON()).selectByType('CommentInput')
  input.props.addMedia()
  await mediaCommentActionSheet(1)
  expect(spy).toHaveBeenCalledWith('Permission Needed', expect.any(String), expect.any(Array))
})

test('mapStateToProps returns no comments for no submissionID', () => {
  const props = {
    courseID: '123',
    assignmentID: '245',
    userID: '55',
    submissionID: undefined,
    drawerState: new DrawerState(),
    gradeIndividually: true,
    navigator: {},
  }

  let state = templates.appState()
  state.entities.courses = {
    '123': {
      enabledFeatures: [],
    },
  }
  state.entities.assignments = {
    '245': {
      data: {},
      pendingComments: {},
      submissions: { refs: [], pending: 0 },
      submissionSummary: { data: {}, pending: 0, error: null },
      gradeableStudents: { refs: [], pending: 0 },
      pending: 0,
      groups: { refs: [], pending: 0 },
    },
  }

  expect(mapStateToProps(state, props)).toEqual({
    commentRows: [],
    anonymous: false,
  })
})

test('mapStateToProps returns comment and submission rows', () => {
  let teacherComment = templates.submissionComment({
    author_id: '1111',
    author: templates.submissionCommentAuthor({
      id: '1111',
      name: 'Severus Snape',
      pronouns: null,
    }),
    attachments: [templates.attachment({ id: '1' })],
  })
  const student = templates.submissionCommentAuthor({
    id: '6682',
    display_name: 'Harry Potter',
    pronouns: 'He/Him',
  })
  let studentComment = templates.submissionComment({
    author_id: student.id,
    author_name: student.display_name,
    author: student,
    created_at: '2017-03-17T19:17:25Z',
    comment: 'a comment from harry',
  })
  const audioComment = templates.submissionComment({
    media_comment: templates.mediaComment(),
  })

  const audio = templates.submission({
    attempt: 8,
    submitted_at: '2017-03-21T19:13:25Z',
    submission_type: 'media_recording',
    media_comment: {
      url: 'https://notorious.com/audio',
      media_type: 'audio',
    },
  })

  const lti = templates.submission({
    attempt: 7,
    submitted_at: '2017-03-20T19:13:25Z',
    submission_type: 'external_tool',
  })

  const quiz = templates.submission({
    id: 'quiz-attempt-id',
    user_id: '8',
    attempt: 6,
    submitted_at: '2017-03-19T19:13:25Z',
    submission_type: 'online_quiz',
  })

  const discussion = templates.submission({
    attempt: 5,
    submitted_at: '2017-03-18T19:13:25Z',
    submission_type: 'discussion_topic',
    discussion_entries: [{ message: `<p>You're wrong because I said.</p>` }],
  })

  const text = templates.submission({
    attempt: 4,
    submitted_at: '2017-03-17T19:13:25Z',
    attachments: [templates.attachment({ id: '4' })],
    user: templates.user({
      id: '55',
      name: 'Bob',
      pronouns: null,
    }),
  })

  const url = templates.submission({
    attempt: 3,
    submission_type: 'online_url',
    submitted_at: '2017-03-17T19:12:25Z',
    url: 'https://google.com/homeworks',
  })

  const files = templates.submission({
    attempt: 2,
    submission_type: 'online_upload',
    submitted_at: '2017-03-17T19:11:25Z',
    attachments: [templates.attachment()],
  })

  const media = templates.submission({
    attempt: 1,
    submission_type: 'media_recording',
    submitted_at: '2017-03-17T19:10:25Z',
    media_comment: {
      url: 'https://notorius.com/2017/3/17/video',
      media_type: 'video',
    },
  })

  const submission = templates.submissionHistory(
    [ text, url, files, media, lti, quiz, discussion, audio ],
    [ teacherComment, studentComment, audioComment ],
  )

  const appState = templates.appState()
  appState.entities.submissions = {
    [submission.id]: { submission, pending: 0 },
  }
  appState.entities.assignments = {
    '200': {
      data: {},
      pendingComments: {
        [student.id]: [
          {
            timestamp: new Date(),
            localID: '1',
            comment: { type: 'text', comment: 'new comment' },
            pending: 1,
          },
        ],
      },
      submissions: { refs: [], pending: 0 },
      submissionSummary: { error: null, pending: 0, data: { graded: 0, ungraded: 0, not_submitted: 0 } },
      gradeableStudents: { refs: [], pending: 0 },
      pending: 0,
      groups: { refs: [], pending: 0 },
      external_tool_tag_attributes: {
        url: 'https://math-games-such-fun.edu/',
      },
    },
  }

  const ownProps = {
    courseID: '100',
    assignmentID: '200',
    userID: student.id,
    submissionID: submission.id,
    drawerState: new DrawerState(),
    gradeIndividually: true,
    navigator: {},
  }

  const session = templates.session()
  session.user.id = teacherComment.author_id
  setSession(session)

  let props = mapStateToProps(appState, ownProps)

  let contents = props.commentRows.map(({ contents }) => contents)
  let quizAttempt = contents.filter(({ attemptIndex }) => attemptIndex === 6)[0]
  expect(quizAttempt.submissionID).toEqual(submission.id)
  expect(quizAttempt.submissionID).not.toEqual(quizAttempt.id)

  let teacherComments = props.commentRows.filter(({ userID }) => userID === teacherComment.author.id)
  teacherComment = teacherComments.find(({ pending }) => pending !== 1)
  expect(teacherComment.contents.comment.attachments).toHaveLength(1)
  expect(teacherComment.name).toEqual('Severus Snape')
  let pendingComment = teacherComments.find(({ pending }) => pending === 1)
  expect(pendingComment.contents.type).toEqual('text')
  expect(pendingComment.contents.comment.comment).toEqual('new comment')

  studentComment = props.commentRows.filter(({ userID }) => userID === student.id)[0]
  expect(studentComment.name).toEqual('Harry Potter (He/Him)')

  let textAttempt = props.commentRows.find(({ contents }) => contents.attemptIndex === text.attempt)
  expect(textAttempt.name).toEqual('Bob')

  appState.entities.submissions[submission.id].submission.user.pronouns = 'He/Him'
  props = mapStateToProps(appState, ownProps)
  textAttempt = props.commentRows.find(({ contents }) => contents.attemptIndex === text.attempt)
  expect(textAttempt.name).toEqual('Bob (He/Him)')
})

test('mapStateToProps returns true when the assignment is a quiz that is an anonymous survey', () => {
  const props = {
    courseID: '123',
    assignmentID: '245',
    userID: '55',
    submissionID: undefined,
    drawerState: new DrawerState(),
    gradeIndividually: true,
    navigator: {},
  }

  let state = templates.appState()
  state.entities.assignments = {
    '245': {
      data: templates.assignment({ id: '245', quiz_id: '678' }),
      pendingComments: {},
      submissions: { refs: [], pending: 0 },
      submissionSummary: { data: {}, pending: 0, error: null },
      gradeableStudents: { refs: [], pending: 0 },
      pending: 0,
      groups: { refs: [], pending: 0 },
    },
  }
  state.entities.quizzes = {
    '678': {
      data: templates.quiz({ id: '678', anonymous_submissions: true }),
    },
  }

  expect(mapStateToProps(state, props).anonymous).toEqual(true)
})

test('mapStateToProps returns true when the assignment has anonymous grading turned on', () => {
  const props = {
    courseID: '123',
    assignmentID: '245',
    userID: '55',
    submissionID: undefined,
    drawerState: new DrawerState(),
    gradeIndividually: true,
    navigator: {},
  }

  let state = templates.appState()
  state.entities.courses = {
    '123': {},
  }
  state.entities.assignments = {
    '245': {
      data: { anonymize_students: true },
      pendingComments: {},
      submissions: { refs: [], pending: 0 },
      submissionSummary: { data: {}, pending: 0, error: null },
      gradeableStudents: { refs: [], pending: 0 },
      pending: 0,
      groups: { refs: [], pending: 0 },
    },
  }

  expect(mapStateToProps(state, props).anonymous).toEqual(true)
})
