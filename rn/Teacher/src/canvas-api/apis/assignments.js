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

import httpClient from '../httpClient'
import cloneDeep from 'lodash/cloneDeep'
import { paginate, exhaust } from '../utils/pagination'

export function getAssignment (courseID: string, assignmentID: string): ApiPromise<Assignment> {
  const url = `courses/${courseID}/assignments/${assignmentID}`
  const options = {
    params: {
      include: ['overrides'],
      all_dates: true,
    },
  }

  return httpClient().get(url, options)
}

export function updateAssignment (courseID: string, assignment: Assignment): ApiPromise<Assignment> {
  // For whatever reason, overrides has a different name when you try to update it
  const updatedAssignment = cloneDeep(assignment)
  if (updatedAssignment.overrides) {
    updatedAssignment.assignment_overrides = updatedAssignment.overrides
    delete updatedAssignment.overrides
  }

  const url = `courses/${courseID}/assignments/${assignment.id}`
  return httpClient().put(url, {
    assignment: updatedAssignment,
  })
}

export function getAssignmentGradeableStudents (courseID: string, assignmentID: string): ApiPromise<UserDisplay[]> {
  const url = `courses/${courseID}/assignments/${assignmentID}/gradeable_students`

  let options = {
    params: {
      per_page: 99,
    },
  }
  const students = paginate(url, options)
  return exhaust(students)
}
