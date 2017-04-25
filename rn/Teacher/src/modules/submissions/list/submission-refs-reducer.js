// @flow

import { Reducer } from 'redux'
import { asyncRefsReducer } from '../../../redux/async-refs-reducer'
import { handleActions } from 'redux-actions'
import handleAsync from '../../../utils/handleAsync'
import composeReducers from '../../../redux/compose-reducers'
import Actions from './actions'
import SpeedGraderActions from '../../speedgrader/actions'
import i18n from 'format-message'

const { refreshSubmissions } = Actions
const { excuseAssignment } = SpeedGraderActions

type Response = { +result: { +data: Array<SubmissionWithHistory> } }

function submissionRefsForResponse ({ result }: Response): EntityRefs {
  return result.data.map(submission => submission.id)
}

export const submissionsList: Reducer<AsyncRefs, any> = asyncRefsReducer(
  refreshSubmissions.toString(),
  i18n('There was a problem loading the assignment submissions.'),
  submissionRefsForResponse
)

export const excuseCreate: Reducer<AsyncRefs, any> = handleActions({
  [excuseAssignment.toString()]: handleAsync({
    resolved: (state, { submissionID, result }) => {
      if (submissionID) return state

      let refs = [...state.refs, result.data.id]
      return {
        ...state,
        refs,
      }
    },
  }),
}, {})

export const submissions: Reducer<AsyncRefs, any> = composeReducers(submissionsList, excuseCreate)
