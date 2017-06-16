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

export let defaultState: AssignmentGroupsState = {}

const { refreshAssignmentList,
        updateAssignment,
        refreshAssignment,
        cancelAssignmentUpdate,
        anonymousGrading } = Actions
const { refreshQuiz } = QuizDetailsActions

const assignment = assignment => assignment || {}
const pending = pending => pending || 0
const error = error => error || null
const anonymousGradingOn = anonymous => anonymous || false

const assignmentContent = combineReducers({
  data: assignment,
  submissions,
  gradeableStudents,
  pending,
  error,
  pendingComments,
  anonymousGradingOn,
})

const defaultAssignmentContents: AssignmentContentState = {
  submissions: { refs: [], pending: 0 },
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

export function assignments (state: AssignmentsState = {}, action: any): AssignmentDetailState {
  let newState = state
  if (action.payload && action.payload.assignmentID) {
    const assignmentID = action.payload.assignmentID
    const currentAssignmentState: AssignmentDetailState = state[assignmentID] || { pending: 0, data: {} }
    const assignmentState = assignmentContent(currentAssignmentState, action)
    newState = {
      ...state,
      [assignmentID]: assignmentState,
    }
  }
  return assignmentsData(newState, action)
}
