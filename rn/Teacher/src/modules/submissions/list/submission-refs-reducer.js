// @flow

import { Reducer } from 'redux'
import { asyncRefsReducer } from '../../../redux/async-refs-reducer'
import { handleActions } from 'redux-actions'
import handleAsync from '../../../utils/handleAsync'
import composeReducers from '../../../redux/compose-reducers'
import Actions from './actions'
import SpeedGraderActions from '../../speedgrader/actions'
import QuizSubmissionActions from '../../quizzes/submissions/actions'
import i18n from 'format-message'

const { refreshSubmissions } = Actions
const { excuseAssignment, gradeSubmission } = SpeedGraderActions
const { refreshQuizSubmissions } = QuizSubmissionActions

type Response = { result: { data: Array<SubmissionWithHistory> } }
type QuizResponse = { result: { data: { submissions: Array<Submission> }}}

function submissionRefsForResponse ({ result }: Response): EntityRefs {
  return result.data.map(submission => submission.id)
}

export const submissionsList: Reducer<AsyncRefs, any> = asyncRefsReducer(
  refreshSubmissions.toString(),
  i18n('There was a problem loading the assignment submissions.'),
  submissionRefsForResponse
)

function quizSubmissionRefsForResponse ({ result }: QuizResponse): EntityRefs {
  return result.data.submissions.map(({ id }) => id)
}

export const quizSubmissionsList: Reducer<AsyncRefs, any> = asyncRefsReducer(
  refreshQuizSubmissions.toString(),
  i18n('There was a problem loading the quiz submissions.'),
  quizSubmissionRefsForResponse
)

function addRef (state, { submissionID, result }) {
  if (submissionID) return state

  let refs = [...state.refs, result.data.id]
  return {
    ...state,
    refs,
  }
}

export const refsChanges: Reducer<AsyncRefs, any> = handleActions({
  [excuseAssignment.toString()]: handleAsync({
    resolved: addRef,
  }),
  [gradeSubmission.toString()]: handleAsync({
    resolved: addRef,
  }),
}, {})

export const submissions: Reducer<AsyncRefs, any> = composeReducers(submissionsList, quizSubmissionsList, refsChanges)
