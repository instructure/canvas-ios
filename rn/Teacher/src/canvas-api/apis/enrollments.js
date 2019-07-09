//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// @flow

import { paginate, exhaust } from '../utils/pagination'
import httpClient from '../httpClient'

export function getCourseEnrollments (courseID: string): ApiPromise<Enrollment[]> {
  const enrollments = paginate(`courses/${courseID}/enrollments`, {
    params: {
      include: ['avatar_url'],
    },
  })

  return exhaust(enrollments)
}

export function getUserEnrollments (userID: string): ApiPromise<Enrollment[]> {
  const enrollments = paginate(`users/${userID}/enrollments`, {
    params: {
      include: ['avatar_url'],
    },
  })

  return exhaust(enrollments)
}

export async function getGradesForGradingPeriod (courseID: string, userID: string, gradingPeriodID: string): ApiPromise<Grades> {
  const { data: [ enrollment ] } = await httpClient.get(`courses/${courseID}/enrollments`, {
    params: {
      user_id: userID,
      grading_period_id: gradingPeriodID,
      include: [ 'observed_users' ],
      state: [ 'current_and_concluded' ],
    },
  })
  return enrollment.grades
}

export function enrollUser (courseID: string, enrollment: CreateEnrollment): ApiPromise<Enrollment> {
  return httpClient.post(`courses/${courseID}/enrollments`, { enrollment })
}

export function acceptEnrollment (courseID: string, enrollmentID: string): ApiPromise<Object> {
  return httpClient.post(`courses/${courseID}/enrollments/${enrollmentID}/accept`)
}

export function rejectEnrollment (courseID: string, enrollmentID: string): ApiPromise<Object> {
  return httpClient.post(`courses/${courseID}/enrollments/${enrollmentID}/reject`)
}
