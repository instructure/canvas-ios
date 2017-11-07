//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
