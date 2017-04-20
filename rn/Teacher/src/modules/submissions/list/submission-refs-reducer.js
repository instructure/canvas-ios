// @flow

import { Reducer } from 'redux'
import { asyncRefsReducer } from '../../../redux/async-refs-reducer'
import Actions from './actions'
import i18n from 'format-message'

const { refreshSubmissions } = Actions

type Response = { +result: { +data: Array<SubmissionWithHistory> } }

function submissionRefsForResponse ({ result }: Response): EntityRefs {
  return result.data.map(submission => submission.id)
}

export const submissions: Reducer<AsyncRefs, any> = asyncRefsReducer(
  refreshSubmissions.toString(),
  i18n('There was a problem loading the assignment submissions.'),
  submissionRefsForResponse
)
