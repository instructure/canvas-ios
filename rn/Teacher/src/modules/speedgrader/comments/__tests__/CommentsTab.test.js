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

/* eslint-disable flowtype/require-valid-file-annotation */

import { shallow } from 'enzyme'
import { ActionSheetIOS, AlertIOS, AppState, FlatList } from 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'
import { CommentsTab, mapStateToProps } from '../CommentsTab'
import { setSession } from '@canvas-api'
import DrawerState from '../../utils/drawer-state'
import explore from '@test/helpers/explore'
import setProps from '@test/helpers/setProps'
import Permissions from '@common/permissions'

const templates = {
  ...require('@redux/__templates__/app-state'),
  ...require('@templates/submissions'),
  ...require('@templates/session'),
  ...require('@templates/attachment'),
  ...require('@templates/mediaComment'),
  ...require('@templates/assignments'),
  ...require('@templates/quiz'),
}

jest
  .mock('../AudioComment')
  .mock('../CommentInput', () => 'CommentInput')
  .mock('../../../../common/components/MediaComment', () => 'MediaComment')
  .mock('../../../../common/permissions')
  .mock('FlatList', () => {
    return ({
      ListEmptyComponent,
      data,
      renderItem,
    }) => (
      <view>
        {data.length > 0
          ? data.map((item, index) => (
            <view key={index}>
              {renderItem({ item, index })}
            </view>
          ))
          : <ListEmptyComponent />
        }
      </view>
    )
  })

const comments = [
  {
    key: 'comment-1',
    name: 'Mrs. Fig',
    date: new Date('2017-03-17T19:15:25Z'),
    avatarURL: 'http://fillmurray.com/332/555',
    from: 'me',
    contents: { type: 'text', message: 'Well?!' },
  },
  {
    key: 'comment-2',
    name: 'Dim Whitted',
    date: new Date('2017-03-17T19:23:25Z'),
    avatarURL: 'http://fillmurray.com/220/400',
    from: 'them',
    contents: { type: 'text', message: '…' },
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
  const tree = renderer.create(
    <CommentsTab commentRows={comments} drawerState={new DrawerState()}/>
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('empty state renders properly', () => {
  const tree = shallow(<CommentsTab commentRows={[]} drawerState={new DrawerState()}/>)
  let flatlist = tree.find('Component').first()
  let props = flatlist.props().children[0].props
  expect(props['ListEmptyComponent'].props.title).toBe('There are no comments to display.')
  expect(props['contentContainerStyle'].justifyContent).toBe('center')
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
  AlertIOS.alert = spy
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
  AlertIOS.alert = spy
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
      anonymousGradingOn: false,
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
  const teacherComment = templates.submissionComment({})
  const student = templates.submissionCommentAuthor({
    id: '6682',
    display_name: 'Harry Potter',
  })
  const studentComment = templates.submissionComment({
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
      anonymousGradingOn: true,
      pendingComments: {},
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

  expect(mapStateToProps(appState, ownProps))
    .toMatchSnapshot()
})

test('mapStateToProps returns anonymous true when anonymous grading is turned on', () => {
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
      data: {},
      anonymousGradingOn: true,
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
      anonymousGradingOn: false,
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

test('mapSTateToProps returns true when the course has anonymous grading turned on', () => {
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
      enabledFeatures: ['anonymous_grading'],
    },
  }
  state.entities.assignments = {
    '245': {
      data: {},
      anonymousGradingOn: false,
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
