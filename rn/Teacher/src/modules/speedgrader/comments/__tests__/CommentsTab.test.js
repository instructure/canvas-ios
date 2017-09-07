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

// @flow

import 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'
import { CommentsTab, mapStateToProps } from '../CommentsTab'
import { setSession } from 'instructure-canvas-api'
import DrawerState from '../../utils/drawer-state'

const templates = {
  ...require('../../../../redux/__templates__/app-state'),
  ...require('../../../../__templates__/submissions'),
  ...require('../../../../__templates__/session'),
  ...require('../../../../__templates__/attachment'),
}

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
    key: 'submission',
    name: 'Dim Whitted',
    date: new Date('2017-03-17T19:40:25Z'),
    avatarURL: 'http://fillmurray.com/220/400',
    from: 'them',
    contents: { type: 'submission', items: [] },
  },
]

test('comments render properly', () => {
  const tree = renderer.create(
    <CommentsTab commentRows={comments} drawerState={new DrawerState()}/>
  ).toJSON()
  expect(tree).toMatchSnapshot()
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
    [ teacherComment, studentComment ],
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
