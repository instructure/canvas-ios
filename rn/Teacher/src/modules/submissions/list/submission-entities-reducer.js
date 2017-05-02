// @flow

import { Reducer } from 'redux'
import Actions from './actions'
import { handleActions } from 'redux-actions'
import handleAsync from '../../../utils/handleAsync'
import SpeedGraderActions from '../../speedgrader/actions'

const { refreshSubmissions } = Actions
const { excuseAssignment, selectSubmissionFromHistory, gradeSubmission, gradeSubmissionWithRubric } = SpeedGraderActions

export const submissions: Reducer<SubmissionsState, any> = handleActions({
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

  [excuseAssignment.toString()]: handleAsync({
    pending: (state, { submissionID }) => {
      if (!submissionID) { return state }
      return {
        ...state,
        [submissionID]: {
          ...state[submissionID],
          submission: {
            ...state[submissionID].submission,
            excused: true,
          },
        },
      }
    },
    resolved: (state, { submissionID, result }) => {
      if (submissionID) return state

      return {
        ...state,
        [result.data.id]: {
          submission: result.data,
          pending: 0,
          error: null,
        },
      }
    },
    rejected: (state, { submissionID }) => {
      if (!submissionID) { return state }
      return {
        ...state,
        [submissionID]: {
          ...state[submissionID],
          submission: {
            ...state.submission,
            excused: false,
          },
        },
      }
    },
  }),
  [selectSubmissionFromHistory.toString()]: (state, { payload }) => {
    const id = payload.submissionID
    let entity = { ...state[id], selectedIndex: payload.index }
    return {
      ...state,
      ...{ [id]: entity },
    }
  },
  [gradeSubmission.toString()]: handleAsync({
    pending: (state, { submissionID }) => {
      if (!submissionID) return state

      return {
        ...state,
        [submissionID]: {
          ...state[submissionID],
          pending: state[submissionID].pending + 1,
        },
      }
    },
    resolved: (state, { submissionID, result }) => {
      let id = submissionID || result.data.id
      let submissionState = submissionID
        ? state[submissionID]
        : { pending: 1, submission: result.data, error: null }

      return {
        ...state,
        [id]: {
          ...submissionState,
          submission: {
            ...submissionState.submission,
            grade: result.data.grade,
            score: result.data.score,
            excused: false,
          },
          pending: submissionState.pending - 1,
        },
      }
    },
    rejected: (state, { submissionID }) => {
      if (!submissionID) return state

      return {
        ...state,
        [submissionID]: {
          ...state[submissionID],
          pending: state[submissionID].pending - 1,
        },
      }
    },
  }),
  [gradeSubmissionWithRubric.toString()]: handleAsync({
    pending: (state, { submissionID }) => {
      if (!submissionID) return state

      return {
        ...state,
        [submissionID]: {
          ...state[submissionID],
          rubricGradePending: true,
        },
      }
    },
    resolved: (state, { submissionID, rubricAssessment, result }) => {
      let id = submissionID || result.data.id
      let submissionState = submissionID
        ? state[submissionID]
        : { pending: 0, submission: result.data, error: null }

      return {
        ...state,
        [id]: {
          ...submissionState,
          rubricGradePending: false,
          submission: {
            ...submissionState.submission,
            rubric_assessment: rubricAssessment,
          },
        },
      }
    },
    rejected: (state, { submissionID }) => {
      if (!submissionID) return state

      return {
        ...state,
        [submissionID]: {
          ...state[submissionID],
          rubricGradePending: false,
        },
      }
    },
  }),
}, {})
