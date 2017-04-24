// @flow

import { submissions } from '../submission-entities-reducer'
import Actions from '../actions'
import SpeedgraderActions from '../../../speedgrader/actions'

const { refreshSubmissions } = Actions
const { excuseAssignment } = SpeedgraderActions
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
    '1': data[0],
    '2': data[1],
  })
})

test('excuseAssignment optimistically updates', () => {
  let state = {
    '1': templates.submissionHistory([{ id: '1', excused: false }]),
  }
  const action = {
    type: excuseAssignment.toString(),
    pending: true,
    payload: { submissionID: '1' },
  }

  let newState = submissions(state, action)
  expect(newState['1'].excused).toBeTruthy()
})

test('excuseAssignment reverts on failure', () => {
  let state = {
    '1': templates.submissionHistory([{ id: '1', excused: true }]),
  }

  const action = {
    type: excuseAssignment.toString(),
    error: true,
    payload: { submissionID: '1' },
  }

  let newState = submissions(state, action)
  expect(newState['1'].excused).toBeFalsy()
})
