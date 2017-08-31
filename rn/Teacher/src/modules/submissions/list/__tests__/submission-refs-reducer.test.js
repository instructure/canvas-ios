// @flow

import { submissions } from '../submission-refs-reducer'
import Actions from '../actions'
import QuizSubmissionActions from '../../../quizzes/submissions/actions'
import SpeedGraderActions from '../../../speedgrader/actions'

const { refreshSubmissions } = Actions
const { refreshQuizSubmissions } = QuizSubmissionActions
const { excuseAssignment, gradeSubmission } = SpeedGraderActions

const templates = {
  ...require('../../../../__templates__/submissions'),
}

test('it captures submission ids', () => {
  let data = [
    { id: '1' },
    { id: '2' },
  ].map(override => templates.submissionHistory([override]))

  const pending = {
    type: refreshSubmissions.toString(),
    pending: true,
  }
  const resolved = {
    type: refreshSubmissions.toString(),
    payload: { result: { data } },
  }

  const pendingState = submissions(undefined, pending)
  expect(pendingState).toEqual({ refs: [], pending: 1 })
  expect(submissions(pendingState, resolved)).toEqual({
    pending: 0,
    refs: ['1', '2'],
  })
})

test('it captures quiz submission ids', () => {
  let data = [
    templates.submission({ id: '1' }),
    templates.submission({ id: '2' }),
  ]

  const pending = {
    type: refreshQuizSubmissions.toString(),
    pending: true,
  }
  const resolved = {
    type: refreshQuizSubmissions.toString(),
    payload: {
      result: {
        data: {
          submissions: data,
        },
      },
    },
  }

  const pendingState = submissions(undefined, pending)
  expect(pendingState).toEqual({ refs: [], pending: 1 })
  expect(submissions(pendingState, resolved)).toEqual({
    pending: 0,
    refs: ['1', '2'],
  })
})

test('on excuseAssignment it returns the current state when there is a submissionID', () => {
  let state = {
    refs: [],
    pending: 0,
    error: null,
  }

  const action = {
    type: excuseAssignment.toString(),
    payload: {
      result: {
        data: templates.submission({ id: '1' }),
      },
      submissionID: '1',
    },
  }

  let newState = submissions(state, action)
  expect(newState).toEqual(state)
})

test('excuseAssignment adds the new submission id to the refs', () => {
  let state = {
    refs: [],
    pending: 0,
    error: null,
  }

  const action = {
    type: excuseAssignment.toString(),
    payload: {
      result: {
        data: templates.submission({ id: '1' }),
      },
    },
  }

  let newState = submissions(state, action)
  expect(newState.refs.length).toEqual(1)
  expect(newState.refs[0]).toEqual('1')
})

test('on gradeSubmission it returns the current state when there is a submissionID', () => {
  let state = {
    refs: [],
    pending: 0,
    error: null,
  }

  const action = {
    type: gradeSubmission.toString(),
    payload: {
      result: {
        data: templates.submission({ id: '1' }),
      },
      submissionID: '1',
    },
  }

  let newState = submissions(state, action)
  expect(newState).toEqual(state)
})

test('on gradeSubmission it adds the new submission id to the refs', () => {
  let state = {
    refs: [],
    pending: 0,
    error: null,
  }

  const action = {
    type: gradeSubmission.toString(),
    payload: {
      result: {
        data: templates.submission({ id: '1' }),
      },
    },
  }

  let newState = submissions(state, action)
  expect(newState.refs.length).toEqual(1)
  expect(newState.refs[0]).toEqual('1')
})
