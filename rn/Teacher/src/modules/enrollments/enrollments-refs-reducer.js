// @flow

import { Reducer } from 'redux'
import Actions from './actions'
import { asyncRefsReducer } from '../../redux/async-refs-reducer'
import i18n from 'format-message'

const { refreshEnrollments } = Actions

type EnrollmentsResponse = {
  +result: { +data: Array<Enrollment> },
}

export function enrollmentRefsForResponse ({ result }: EnrollmentsResponse): Array<string> {
  return result.data.map(enrollment => enrollment.id)
}

export const enrollments: Reducer<AsyncRefs, any> = asyncRefsReducer(
  refreshEnrollments.toString(),
  i18n('There was a error loading the list of enrollments'),
  enrollmentRefsForResponse,
)
