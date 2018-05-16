//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow

import { Reducer } from 'redux'
import Actions from './actions'
import { handleActions } from 'redux-actions'
import handleAsync from '../../../utils/handleAsync'
import SpeedGraderActions from '../../speedgrader/actions'

const { refreshSubmissions, getUserSubmissions } = Actions
const { excuseAssignment, selectSubmissionFromHistory,
  gradeSubmission, gradeSubmissionWithRubric, selectFile } = SpeedGraderActions

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
            selectedAttachmentIndex: 0,
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
          lastGradedAt: Date.now(),
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
    let entity = { ...state[id], selectedIndex: payload.index, selectedAttachmentIndex: 0 }
    return {
      ...state,
      ...{ [id]: entity },
    }
  },
  [selectFile.toString()]: (state, { payload }) => {
    const id = payload.submissionID
    let entity = { ...state[id], selectedAttachmentIndex: payload.index }
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

      const {
        grade,
        score,
        entered_grade,
        entered_score,
        grade_matches_current_submission,
        late,
        points_deducted,
      } = result.data

      return {
        ...state,
        [id]: {
          ...submissionState,
          submission: {
            ...submissionState.submission,
            grade,
            score,
            entered_grade,
            entered_score,
            grade_matches_current_submission,
            late,
            points_deducted,
            excused: false,
          },
          pending: submissionState.pending - 1,
          lastGradedAt: Date.now(),
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
          lastGradedAt: Date.now(),
          submission: {
            ...submissionState.submission,
            grade: result.data.grade,
            score: result.data.score,
            grade_matches_current_submission: result.data.grade_matches_current_submission,
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
  [getUserSubmissions.toString()]: handleAsync({
    resolved: (state, { result }) => {
      const incoming = result.data
        .reduce((incoming, submission) => ({
          ...incoming,
          [submission.id]: {
            submission,
            pending: 0,
            error: null,
            selectedAttachmentIndex: 0,
          },
        }), {})
      return { ...state, ...incoming }
    },
  }),
}, {})
