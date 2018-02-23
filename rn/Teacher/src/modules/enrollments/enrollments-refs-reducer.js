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
  i18n('There was an error loading the list of enrollments'),
  enrollmentRefsForResponse,
)
