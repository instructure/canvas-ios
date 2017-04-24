// @flow

import { submissions } from '../submission-entities-reducer'
import Actions from '../actions'
import SpeedGraderActions from '../../../speedgrader/actions'

const { refreshSubmissions } = Actions
const { excuseAssignment } = SpeedGraderActions
const templates = {
  ...require('../../../../api/canvas-api/__templates__/submissions'),
}

test('it captures entities', () => {
  let data = [
    { id: 1 },
    { id: 2 },
  ].map(override => templates.submissionHistory([override]))

  const action = {
    type: refreshSubmissions.toString(),
    payload: { result: { data } },
  }

  expect(submissions({}, action)).toEqual({
    '1': {
      submission: data[0],
      pending: 0,
      error: null,
    },
    '2': {
      submission: data[1],
      pending: 0,
      error: null,
    },
  })
})

test('excuseAssignment optimistically updates', () => {
  let state = {
    '1': {
      submission: templates.submissionHistory([{ id: '1', excused: false }]),
      pending: 0,
      error: null,
    },
  }
  const action = {
    type: excuseAssignment.toString(),
    pending: true,
    payload: { submissionID: '1' },
  }

  let newState = submissions(state, action)
  expect(newState['1'].submission.excused).toBeTruthy()
})

test('excuseAssignment reverts on failure', () => {
  let state = {
    '1': {
      submission: templates.submissionHistory([{ id: '1', excused: true }]),
      pending: 0,
      error: null,
    },
  }

  const action = {
    type: excuseAssignment.toString(),
    error: true,
    payload: { submissionID: '1' },
  }

  let newState = submissions(state, action)
  expect(newState['1'].submission.excused).toBeFalsy()
})
