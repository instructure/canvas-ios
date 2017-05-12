// @flow

import 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'
import { CommentsTab, mapStateToProps } from '../CommentsTab'
import { setSession } from '../../../../api/session'
import DrawerState from '../../utils/drawer-state'

const templates = {
  ...require('../../../../redux/__templates__/app-state'),
  ...require('../../../../api/canvas-api/__templates__/submissions'),
  ...require('../../../../api/canvas-api/__templates__/session'),
}

const comments = [
  {
    key: 'comment-1',
    name: 'Mrs. Fig',
    date: new Date('2017-03-17T19:15:25Z'),
    avatarURL: 'http://fillmurray.com/332/555',
    from: 'me',
    contents: { type: 'comment', message: 'Well?!' },
  },
  {
    key: 'comment-2',
    name: 'Dim Whitted',
    date: new Date('2017-03-17T19:23:25Z'),
    avatarURL: 'http://fillmurray.com/220/400',
    from: 'them',
    contents: { type: 'comment', message: '…' },
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
    contents: { type: 'submission' },
  },
]

test('comments render properly', () => {
  const tree = renderer.create(
    <CommentsTab commentRows={comments} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('mapStateToProps returns no comments for no submissionID', () => {
  const props = {
    courseID: '123',
    assignmentID: '245',
    userID: '55',
    submissionID: undefined,
    drawerState: new DrawerState(),
  }

  let state = templates.appState()

  expect(mapStateToProps(state, props)).toEqual({
    commentRows: [],
  })
})

test('mapStateToProps returns no comments for no submissionID', () => {
  const props = {
    courseID: '123',
    assignmentID: '245',
    userID: '55',
    submissionID: undefined,
    drawerState: new DrawerState(),
  }

  let state = templates.appState()

  expect(mapStateToProps(state, props)).toEqual({
    commentRows: [],
  })
})

test('mapStateToProps returns comments rows', () => {
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

  const submission = {
    ...templates.submissionHistory(),
    submission_comments: [teacherComment, studentComment],
  }

  const appState = templates.appState()
  appState.entities.submissions = {
    [submission.id]: { submission, pending: 0 },
  }

  const ownProps = {
    courseID: '100',
    assignmentID: '200',
    userID: student.id,
    submissionID: submission.id,
    drawerState: new DrawerState(),
  }

  const session = templates.session()
  session.user.id = teacherComment.author_id
  setSession(session)

  expect(mapStateToProps(appState, ownProps)).toEqual({
    commentRows: [
      {
        key: 'comment-' + studentComment.id,
        name: studentComment.author_name,
        date: new Date(studentComment.created_at),
        avatarURL: 'http://fillmurray.com/499/355',
        from: 'them',
        contents: { type: 'comment', message: studentComment.comment },
      },
      {
        key: 'comment-' + teacherComment.id,
        name: teacherComment.author_name,
        date: new Date(teacherComment.created_at),
        avatarURL: 'http://fillmurray.com/499/355',
        from: 'me',
        contents: { type: 'comment', message: teacherComment.comment },
      },
    ],
  })
})
