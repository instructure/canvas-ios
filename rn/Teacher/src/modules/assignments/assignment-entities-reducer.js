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

import { Reducer, combineReducers } from 'redux'
import { handleActions } from 'redux-actions'
import Actions from './actions'
import handleAsync from '../../utils/handleAsync'
import { submissions } from '../submissions/list/submission-refs-reducer'
import { gradeableStudentsRefs as gradeableStudents } from './assignment-gradeable-students-reducer'
import flatMap from 'lodash/flatMap'
import fromPairs from 'lodash/fromPairs'
import cloneDeep from 'lodash/cloneDeep'
import pendingComments from '../speedgrader/comments/pending-comments-reducer'
import { default as QuizDetailsActions } from '../quizzes/details/actions'
import { default as DiscussionDetailsActions } from '../discussions/details/actions'
import { default as SubmissionActions } from '../submissions/list/actions'

export let defaultState: AssignmentGroupsState = {}

const { refreshAssignmentList,
  updateAssignment,
  refreshAssignment,
  refreshAssignmentDetails,
  cancelAssignmentUpdate,
  anonymousGrading } = Actions
const { refreshQuiz } = QuizDetailsActions
const { refreshDiscussionEntries } = DiscussionDetailsActions
const { refreshSubmissionSummary, getUserSubmissions } = SubmissionActions

const assignment = assignment => assignment || {}
const pending = pending => pending || 0
const error = error => error || null
const anonymousGradingOn = anonymous => anonymous || false
const submissionSummaryReducer = data => data || { error: null, pending: 0, data: { graded: 0, ungraded: 0, not_submitted: 0 } }

const assignmentContent = combineReducers({
  data: assignment,
  submissions,
  submissionSummary: submissionSummaryReducer,
  gradeableStudents,
  pending,
  error,
  pendingComments,
  anonymousGradingOn,
})

const defaultAssignmentContents: AssignmentContentState = {
  submissions: { refs: [], pending: 0 },
  submissionSummary: { pending: 0, error: null, data: { graded: 0, ungraded: 0, not_submitted: 0 } },
  gradeableStudents: { refs: [], pending: 0 },
  pendingComments: {},
}

const assignmentsData: Reducer<AssignmentsState, any> = handleActions({
  [refreshAssignmentList.toString()]: handleAsync({
    resolved: (state, { result, courseID }) => {
      const assignments = flatMap(result.data, group => group.assignments)
      const updated = fromPairs(assignments.map(assignment => {
        return [
          assignment.id, {
            ...defaultAssignmentContents,
            ...state[assignment.id],
            data: assignment,
          },
        ]
      }))

      return {
        ...state,
        ...updated,
      }
    },
  }),
  [refreshAssignment.toString()]: handleAsync({
    resolved: (state, { result, courseID, assignmentID }) => {
      const assignmentState = cloneDeep(state[assignmentID] || {})
      assignmentState.data = result.data
      return {
        ...state,
        ...{
          [assignmentID]: assignmentState,
        },
      }
    },
  }),
  [refreshAssignmentDetails.toString()]: handleAsync({
    resolved: (state, { result: [assignment, dials], courseID, assignmentID }) => {
      const assignmentState = cloneDeep(state[assignmentID] || {})
      assignmentState.data = assignment.data
      return {
        ...state,
        [assignmentID]: {
          ...assignmentState,
          submissionSummary: { data: dials && dials.data, pending: 0, error: null },
        },
      }
    },
    rejected: (state, { courseID, assignmentID, error }) => {
      return {
        ...state,
        [assignmentID]: {
          ...state[assignmentID],
          submissionSummary: { data: { graded: 0, ungraded: 0, not_submitted: 0 }, pending: 0, error: error },
        },
      }
    },
    pending: (state, { courseID, assignmentID }) => {
      let summaryEntity = (state[assignmentID] || {}).submissionSummary || {}
      return {
        ...state,
        [assignmentID]: {
          ...state[assignmentID],
          submissionSummary: { ...summaryEntity, pending: (summaryEntity.pending || 0) + 1, error: null },
        },
      }
    },
  }),
  [updateAssignment.toString()]: handleAsync({
    pending: (state, { updatedAssignment, originalAssignment }) => ({
      ...state,
      [updatedAssignment.id]: {
        ...state[updatedAssignment.id],
        error: null,
        pending: (state[updatedAssignment.id] && state[updatedAssignment.id].pending || 0) + 1,
        data: {
          ...updatedAssignment,
        },
      },
    }),
    resolved: (state, { result, updatedAssignment, originalAssignment }) => ({
      ...state,
      [updatedAssignment.id]: {
        ...state[updatedAssignment.id],
        error: null,
        pending: state[updatedAssignment.id] && state[updatedAssignment.id].pending ? Math.max(0, state[updatedAssignment.id].pending - 1) : 0,
        data: updatedAssignment,
      },
    }),
    rejected: (state, { updatedAssignment, originalAssignment, error }) => {
      let id = originalAssignment.id
      let entity = { ...state[id] }
      entity.data = originalAssignment
      entity.pending = (entity.pending || 0) - 1
      entity.error = error
      return {
        ...state,
        ...{ [id]: entity },
      }
    },
  }),
  [cancelAssignmentUpdate.toString()]: (state, { payload }) => {
    const assignment = payload.originalAssignment
    let id = assignment.id
    let entity = { ...state[id], error: null }
    entity.data = assignment
    return {
      ...state,
      ...{ [id]: entity },
    }
  },
  [refreshQuiz.toString()]: handleAsync({
    resolved: (state, { result: [quiz, groups, assignment] }) => {
      if (!assignment || !assignment.data) return state
      return {
        ...state,
        [assignment.data.id]: {
          ...state[assignment.data.id],
          data: {
            ...(state[assignment.data.id] && state[assignment.data.id].data),
            ...assignment.data,
          },
        },
      }
    },
  }),
  [refreshDiscussionEntries.toString()]: handleAsync({
    resolved: (state, { result: [view, discussion, assignment] }) => {
      if (!assignment || !assignment.data) return state
      return {
        ...state,
        [assignment.data.id]: {
          ...state[assignment.data.id],
          data: {
            ...(state[assignment.data.id] && state[assignment.data.id].data),
            ...assignment.data,
          },
        },
      }
    },
  }),
  [refreshSubmissionSummary.toString()]: handleAsync({
    resolved: (state, { result, courseID, assignmentID }) => {
      return {
        ...state,
        [assignmentID]: {
          ...state[assignmentID],
          submissionSummary: { data: result.data, pending: 0, error: null },
        },
      }
    },
    rejected: (state, { courseID, assignmentID, error }) => {
      return {
        ...state,
        [assignmentID]: {
          ...state[assignmentID],
          submissionSummary: { data: { graded: 0, ungraded: 0, not_submitted: 0 }, pending: 0, error: error },
        },
      }
    },
    pending: (state, { courseID, assignmentID }) => {
      let summaryEntity = (state[assignmentID] || {}).submissionSummary || {}
      return {
        ...state,
        [assignmentID]: {
          ...state[assignmentID],
          submissionSummary: { data: { graded: 0, ungraded: 0, not_submitted: 0 }, pending: (summaryEntity.pending || 0) + 1, error: null },
        },
      }
    },
  }),
  [anonymousGrading.toString()]: (state, { payload }) => {
    let { assignmentID, anonymous } = payload
    return {
      ...state,
      [assignmentID]: {
        ...state[assignmentID],
        anonymousGradingOn: anonymous,
      },
    }
  },
}, defaultState)

const submissionsData: Reducer<AssignmentsState, any> = handleActions({
  [getUserSubmissions.toString()]: (state, action) => {
    if (action.pending || action.error) return state

    let newState = { ...state }
    let result = action.payload.result.data
    result.forEach(submission => {
      let assignmentID = submission.assignment_id
      newState[assignmentID] = assignmentContent(newState[assignmentID], action)
      newState[assignmentID] = {
        ...newState[assignmentID],
        submissions: {
          ...newState[assignmentID].submissions,
          refs: [...new Set([...newState[assignmentID].submissions.refs, submission.id])],
        },
      }
    })
    return newState
  },
}, defaultState)

export function assignments (state: AssignmentsState = {}, action: any): AssignmentsState {
  let newState = state
  if (action.payload && action.payload.assignmentID) {
    const assignmentID = action.payload.assignmentID
    const currentAssignmentState: AssignmentDetailState = state[assignmentID] || {
      pending: 0,
      data: {},
      anonymousGradingOn: false,
    }
    const assignmentState = assignmentContent(currentAssignmentState, action)
    newState = {
      ...state,
      [assignmentID]: assignmentState,
    }
  }
  newState = submissionsData(newState, action)

  return assignmentsData(newState, action)
}
