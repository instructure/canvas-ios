// @flow
import { NativeModules } from 'react-native'
import pendingComments from '../pending-comments-reducer'
import PendingActions from '../actions'
import SubmissionActions from '../../../submissions/list/actions'

const { PushNotifications } = NativeModules
const t = {
  ...require('../../../../api/canvas-api/__templates__/submissions'),
}

const { makeAComment, deletePendingComment } = PendingActions
const { refreshSubmissions } = SubmissionActions

const pending: PendingCommentState = {
  pending: 1,
  localID: 'a24b6b08-d5a5-4cc3-b4b7-6199dd1756b8',
  timestamp: '2017-05-17T05:59:00Z',
  comment: { type: 'text', message: 'Hello!' },
}

const completed: PendingCommentState = {
  pending: 0,
  commentID: '34',
  localID: 'a24b6b08-d5a5-4cc3-b4b7-6199dd1756b8',
  timestamp: '2017-05-17T05:59:00Z',
  comment: { type: 'text', message: 'Hello!' },
  error: undefined,
}

const failed: PendingCommentState = {
  pending: 0,
  localID: 'a24b6b08-d5a5-4cc3-b4b7-6199dd1756b8',
  timestamp: '2017-05-17T05:59:00Z',
  comment: { type: 'text', message: 'Hello!' },
  error: '😭',
}

beforeEach(() => jest.resetAllMocks())

test('reduces pending comments', () => {
  const action = {
    type: makeAComment.toString(),
    pending: true,
    payload: {
      userID: '32',
      timestamp: pending.timestamp,
      localID: pending.localID,
      comment: pending.comment,
    },
  }
  expect(pendingComments({}, action)).toEqual({
    '32': [pending],
  })
})

test('reduces completed comments', () => {
  const submission = t.submissionHistory([t.submission()], [t.submissionComment({
    id: completed.commentID,
  })])

  const action = {
    type: makeAComment.toString(),
    payload: {
      userID: '99',
      localID: pending.localID,
      result: { data: submission },
    },
  }

  expect(pendingComments(
    { '99': [pending] },
    action
  )).toEqual(
    { '99': [completed] },
  )
})

test('passes on error on failure', () => {
  const action = {
    type: makeAComment.toString(),
    error: true,
    payload: {
      localID: pending.localID,
      userID: '55',
      error: new Error(failed.error),
    },
  }

  expect(pendingComments(
    { '55': [pending] },
    action
  )).toEqual(
    { '55': [failed] },
  )
})

test('schedules a push notification when a comment fails to send', () => {
  const action = {
    type: makeAComment.toString(),
    error: true,
    payload: {
      localID: pending.localID,
      userID: '55',
      error: new Error(failed.error),
    },
  }

  pendingComments({ '55': [pending] }, action)

  expect(PushNotifications.scheduleLocalNotification).toHaveBeenCalled()
})

test('removes completed comments on refreshSubmissions', () => {
  const action = {
    type: refreshSubmissions.toString(),
    payload: {},
  }

  expect(pendingComments(
    { '33': [completed], '44': [completed, pending] },
    action
  )).toEqual(
    { '33': [], '44': [pending] },
  )
})

test('deletePendingComments removes the pending comment', () => {
  const action = {
    type: deletePendingComment.toString(),
    payload: {
      userID: '1',
      localID: pending.localID,
    },
  }

  expect(pendingComments(
    { '1': [pending] },
    action
  )).toEqual(
    { '1': [] }
  )
})
