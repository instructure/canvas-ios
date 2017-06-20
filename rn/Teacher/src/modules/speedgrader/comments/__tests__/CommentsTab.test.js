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
  ...require('../../../../api/canvas-api/__templates__/attachment'),
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
  }

  let state = templates.appState()
  state.entities.assignments = {
    '245': {
      data: {},
      anonymousGradingOn: false,
      pendingComments: {},
      submissions: { refs: [], pending: 0 },
      gradeableStudents: { refs: [], pending: 0 },
      pending: 0,
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
    attachments: [templates.attachment()],
  })

  const submission = templates.submissionHistory(
    [ text, url, files, media ],
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
      gradeableStudents: { refs: [], pending: 0 },
      pending: 0,
    },
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
    anonymous: true,
    commentRows: [
      {
        key: 'comment-' + studentComment.id,
        name: studentComment.author_name,
        date: new Date(studentComment.created_at),
        avatarURL: 'http://fillmurray.com/499/355',
        from: 'them',
        contents: { type: 'text', message: studentComment.comment },
        pending: 0,
      },
      {
        key: 'comment-' + teacherComment.id,
        name: teacherComment.author_name,
        date: new Date(teacherComment.created_at),
        avatarURL: 'http://fillmurray.com/499/355',
        from: 'me',
        contents: { type: 'text', message: teacherComment.comment },
        pending: 0,
      },
      {
        avatarURL: 'http://www.fillmurray.com/100/100',
        contents: {
          attemptIndex: 3,
          items: [{
            contentID: 'text',
            icon: 1,
            subtitle: 'This is my submission!',
            title: 'Text Submission',
          }],
          submissionID: '32',
          type: 'submission',
        },
        date: new Date('2017-03-17T19:13:25.000Z'),
        from: 'them',
        key: 'submission-4',
        name: 'Donald Trump',
        pending: 0,
      },
      {
        avatarURL: 'http://www.fillmurray.com/100/100',
        contents: {
          attemptIndex: 2,
          items: [
            {
              contentID: 'url',
              icon: 1,
              subtitle: 'https://google.com/homeworks',
              title: 'URL Submission',
            },
          ],
          submissionID: '32',
          type: 'submission',
        },
        date: new Date('2017-03-17T19:12:25.000Z'),
        from: 'them',
        key: 'submission-3',
        name: 'Donald Trump',
        pending: 0,
      },
      {
        avatarURL: 'http://www.fillmurray.com/100/100',
        contents: {
          attemptIndex: 1,
          items: [
            {
              contentID: 'attachment-111',
              icon: 1,
              subtitle: '476.77 KB',
              title: 'Book Report',
            },
          ],
          type: 'submission',
          submissionID: '32',
        },
        date: new Date('2017-03-17T19:11:25.000Z'),
        from: 'them',
        key: 'submission-2',
        name: 'Donald Trump',
        pending: 0,
      },
      {
        avatarURL: 'http://www.fillmurray.com/100/100',
        contents: {
          attemptIndex: 0,
          items: [
            {
              contentID: 'attachment-111',
              icon: 1,
              subtitle: '476.77 KB',
              title: 'Book Report',
            },
          ],
          submissionID: '32',
          type: 'submission',
        },
        date: new Date('2017-03-17T19:10:25.000Z'),
        from: 'them',
        key: 'submission-1',
        name: 'Donald Trump',
        pending: 0,
      },
    ],
  })
})
