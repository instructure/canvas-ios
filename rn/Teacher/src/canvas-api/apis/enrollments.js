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

import { paginate, exhaust } from '../utils/pagination'
import httpClient from '../httpClient'

export function getCourseEnrollments (courseID: string): Promise<ApiResponse<Array<Enrollment>>> {
  const enrollments = paginate(`courses/${courseID}/enrollments`, {
    params: {
      include: ['avatar_url'],
    },
  })

  return exhaust(enrollments)
}

export function enrollUser (courseID: string, enrollment: CreateEnrollment): Promise<ApiResponse<Enrollment>> {
  return httpClient().post(`courses/${courseID}/enrollments`, { enrollment })
}
