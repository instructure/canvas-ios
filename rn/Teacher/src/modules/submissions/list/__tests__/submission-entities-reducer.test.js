// @flow

import { submissions } from '../submission-entities-reducer'
import Actions from '../actions'
import SpeedGraderActions from '../../../speedgrader/actions'

const { refreshSubmissions, getUserSubmissions } = Actions
const { excuseAssignment, gradeSubmission,
  selectSubmissionFromHistory, gradeSubmissionWithRubric, selectFile } = SpeedGraderActions
const templates = {
  ...require('../../../../__templates__/submissions'),
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
      selectedAttachmentIndex: 0,
    },
    '2': {
      submission: data[1],
      pending: 0,
      error: null,
      selectedAttachmentIndex: 0,
    },
  })
})

test('it captures entities from getUserSubmissions', () => {
  let data = [
    { id: '1' },
    { id: '2' },
  ].map(override => templates.submissionHistory([override]))

  const action = {
    type: getUserSubmissions.toString(),
    payload: { result: { data } },
  }

  expect(submissions({}, action)).toEqual({
    '1': {
      submission: data[0],
      pending: 0,
      error: null,
      selectedAttachmentIndex: 0,
    },
    '2': {
      submission: data[1],
      pending: 0,
      error: null,
      selectedAttachmentIndex: 0,
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
      submission: templates.submissionHistory([{ id: '1', excused: true, grade_matches_current_submission: false }]),
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
      grade_matches_current_submission: true,
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

test('selectSubmissionFromHistory zeros-out the existing selectedAttachmentIndex', () => {
  const state = {
    '1': {
      submission: {},
      error: null,
      pending: 0,
      selectedIndex: 0,
      selectedAttachmentIndex: 1,
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
    selectedAttachmentIndex: 0,
  })
})

test('selectFile adds the selectedAttachmentIndex to the submission', () => {
  const state = {
    '1': {
      submission: {},
      error: null,
      pending: 0,
      selectedIndex: 0,
    },
  }

  const action = {
    type: selectFile.toString(),
    payload: {
      submissionID: '1',
      index: 2,
    },
  }

  let newState = submissions(state, action)
  expect(newState['1']).toMatchObject({
    submission: {},
    pending: 0,
    selectedIndex: 0,
    error: null,
    selectedAttachmentIndex: 2,
  })
})

test('selectFile updates the existing selectedAttachmentIndex', () => {
  const state = {
    '1': {
      submission: {},
      error: null,
      pending: 0,
      selectedIndex: 0,
      selectedAttachmentIndex: 0,
    },
  }

  const action = {
    type: selectFile.toString(),
    payload: {
      submissionID: '1',
      index: 2,
    },
  }

  let newState = submissions(state, action)
  expect(newState['1']).toMatchObject({
    submission: {},
    pending: 0,
    selectedIndex: 0,
    error: null,
    selectedAttachmentIndex: 2,
  })
})

test('gradeSubmissionWithRubric returns current state when there is no submissionID', () => {
  const state = { yo: 'yo' }
  const action = {
    type: gradeSubmissionWithRubric.toString(),
    pending: true,
    payload: {},
  }

  let newState = submissions(state, action)
  expect(newState).toEqual(state)
})

test('gradeSubmissionWithRubric updates pending when there is a submissionID', () => {
  const state = {
    '1': {
      rubricGradePending: false,
    },
  }
  const action = {
    type: gradeSubmissionWithRubric.toString(),
    pending: true,
    payload: {
      submissionID: '1',
    },
  }

  let newState = submissions(state, action)
  expect(newState['1'].rubricGradePending).toEqual(true)
})

test('gradeSubmissionWithRubric creates the submission if there is no submissionID', () => {
  let state = {}
  const action = {
    type: gradeSubmissionWithRubric.toString(),
    payload: {
      result: {
        data: templates.submission({ id: '1' }),
      },
    },
  }

  let newState = submissions(state, action)
  expect(newState['1']).toEqual({
    submission: action.payload.result.data,
    pending: 0,
    error: null,
    rubricGradePending: false,
  })
})

test('gradeSubmissionWithRubric sets the rubricGradePending to false when there is a submissionID', () => {
  let submission = templates.submission({ id: '1', grade: 100, score: 100 })
  let state = {
    '1': {
      submission,
      pending: 0,
      rubricGradePending: false,
      error: null,
    },
  }
  let action = {
    type: gradeSubmissionWithRubric.toString(),
    payload: {
      result: {
        data: submission,
      },
      submissionID: '1',
    },
  }

  let newState = submissions(state, action)
  expect(newState['1'].rubricGradePending).toEqual(false)
  expect(newState['1'].submission.grade).toEqual(100)
  expect(newState['1'].submission.score).toEqual(100)
})

test('gradeSubmissionWithRubric returns current state if there is no submissionID', () => {
  let state = { yo: 'yo' }
  let action = {
    type: gradeSubmissionWithRubric.toString(),
    error: true,
    payload: {},
  }

  let newState = submissions(state, action)
  expect(newState).toEqual(state)
})

test('gradeSubmissionWithRubric returns state with rubricGradePending set to false when there is a submissionID', () => {
  let state = {
    '1': {
      rubricGradePending: true,
    },
  }
  let action = {
    type: gradeSubmissionWithRubric.toString(),
    error: true,
    payload: {
      submissionID: '1',
    },
  }

  let newState = submissions(state, action)
  expect(newState['1'].rubricGradePending).toEqual(false)
})
