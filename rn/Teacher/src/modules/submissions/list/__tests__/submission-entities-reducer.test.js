// @flow

import { submissions } from '../submission-entities-reducer'
import Actions from '../actions'
import SpeedGraderActions from '../../../speedgrader/actions'

const { refreshSubmissions } = Actions
const { excuseAssignment, gradeSubmission, selectSubmissionFromHistory } = SpeedGraderActions
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

test('excuseAssignment does nothing on pending when there is no submissionID', () => {
  let state = { yo: 'yo' }

  const action = {
    type: excuseAssignment.toString(),
    pending: true,
    payload: {},
  }

  let newState = submissions(state, action)
  expect(newState).toEqual(state)
})

test('excuseAssignment does nothing on error when there is no submissionID', () => {
  let state = { yo: 'yo' }

  const action = {
    type: excuseAssignment.toString(),
    error: true,
    payload: {},
  }

  let newState = submissions(state, action)
  expect(newState).toEqual(state)
})

test('excuseAssignment creates the submission entity on success when there is no submissionID', () => {
  let state = {}
  const action = {
    type: excuseAssignment.toString(),
    payload: {
      result: {
        data: templates.submissionHistory([{ id: '1' }]),
      },
    },
  }

  let newState = submissions(state, action)
  expect(newState['1']).toMatchObject({
    submission: action.payload.result.data,
    pending: 0,
    error: null,
  })
})

test('gradeSubmission does nothing on pending when there is no submissionID', () => {
  let state = { yo: 'yo' }

  const action = {
    type: gradeSubmission.toString(),
    pending: true,
    payload: {},
  }

  let newState = submissions(state, action)
  expect(newState).toEqual(state)
})

test('gradeSubmission ups the pending count by one when there is a submissionID', () => {
  let state = {
    '1': {
      submission: templates.submissionHistory([{ id: '1' }]),
      pending: 0,
      error: null,
    },
  }

  const action = {
    type: gradeSubmission.toString(),
    pending: true,
    payload: {
      submissionID: '1',
    },
  }

  let newState = submissions(state, action)
  expect(newState['1'].pending).toEqual(1)
})

test('gradeSubmission does nothing on rejection when there is no submissionID', () => {
  let state = { yo: 'yo' }

  const action = {
    type: gradeSubmission.toString(),
    error: true,
    payload: {},
  }

  let newState = submissions(state, action)
  expect(newState).toEqual(state)
})

test('gradeSubmission decrements the pending count on rejection when there is a submissionID', () => {
  let state = {
    '1': {
      submission: templates.submissionHistory([{ id: '1' }]),
      pending: 1,
      error: null,
    },
  }
  const action = {
    type: gradeSubmission.toString(),
    error: true,
    payload: {
      submissionID: '1',
    },
  }

  let newState = submissions(state, action)
  expect(newState['1'].pending).toEqual(0)
})

test('gradeSubmission creates the submission entity when there is no submissionID', () => {
  let state = {}

  const action = {
    type: gradeSubmission.toString(),
    payload: {
      result: {
        data: templates.submission({ id: '1', grade: '1', score: 1 }),
      },
    },
  }

  let newState = submissions(state, action)
  expect(newState['1']).toMatchObject({
    submission: action.payload.result.data,
    pending: 0,
    error: null,
  })
})

test('gradeSubmission updates the existing submission entity when there is a submissionID', () => {
  let state = {
    '1': {
      submission: templates.submissionHistory([{ id: '1', excused: true }]),
      pending: 1,
      error: null,
    },
  }

  const action = {
    type: gradeSubmission.toString(),
    payload: {
      result: {
        data: templates.submission({ id: '1', grade: '1', score: 1 }),
      },
      submissionID: '1',
    },
  }

  let newState = submissions(state, action)
  expect(newState['1']).toMatchObject({
    submission: {
      grade: '1',
      score: 1,
      excused: false,
    },
    pending: 0,
  })
})

test('selectSubmissionFromHistory adds the selectedIndex to the submission', () => {
  const state = {
    '1': {
      submission: {},
      error: null,
      pending: 0,
    },
  }

  const action = {
    type: selectSubmissionFromHistory.toString(),
    payload: {
      submissionID: '1',
      index: 2,
    },
  }

  let newState = submissions(state, action)
  expect(newState['1']).toMatchObject({
    submission: {},
    pending: 0,
    error: null,
    selectedIndex: 2,
  })
})

test('selectSubmissionFromHistory updates the existing selectedIndex', () => {
  const state = {
    '1': {
      submission: {},
      error: null,
      pending: 0,
      selectedIndex: 0,
    },
  }

  const action = {
    type: selectSubmissionFromHistory.toString(),
    payload: {
      submissionID: '1',
      index: 2,
    },
  }

  let newState = submissions(state, action)
  expect(newState['1']).toMatchObject({
    submission: {},
    pending: 0,
    error: null,
    selectedIndex: 2,
  })
})
