// @flow

import { Reducer } from 'redux'
import Actions from './actions'
import { handleActions } from 'redux-actions'
import handleAsync from '../../../utils/handleAsync'
import SpeedGraderActions from '../../speedgrader/actions'

const { refreshSubmissions } = Actions
const { excuseAssignment } = SpeedGraderActions

export const submissionsData: Reducer<SubmissionsState, any> = handleActions({
  [refreshSubmissions.toString()]: handleAsync({
    resolved: (state, { result }) => {
      const incoming = result.data
        .reduce((incoming, submission) => ({
          ...incoming,
          [submission.id]: {
            submission,
            pending: 0,
            error: null,
          },
        }), {})
      return { ...state, ...incoming }
    },
  }),
}, {})

export const submission: Reducer<SubmissionsState, any> = handleActions({
  [excuseAssignment.toString()]: handleAsync({
    pending: (state, { submissionID }) => {
      if (!submissionID) { return state }
      return {
        ...state,
        submission: {
          ...state.submission,
          excused: true,
        },
      }
    },
    rejected: (state, { submissionID }) => {
      if (!submissionID) { return state }
      return {
        ...state,
        submission: {
          ...state.submission,
          excused: false,
        },
      }
    },
  }),
}, { pending: 0, error: null })

export function submissions (state: SubmissionsState = {}, action: any): SubmissionsState {
  let newState = state
  if (action.payload && action.payload.submissionID) {
    const submissionID = action.payload.submissionID
    const currentSubmissionState: SubmissionState = state[submissionID] || {}
    const submissionState = submission(currentSubmissionState, action)
    newState = {
      ...state,
      [submissionID]: submissionState,
    }
  }
  return submissionsData(newState, action)
}
