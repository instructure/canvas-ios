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

import httpClient from '../httpClient'
import cloneDeep from 'lodash/cloneDeep'
import { paginate, exhaust } from '../utils/pagination'

export function getAssignments (courseID: string, include: string[] = []): ApiPromise<Assignment[]> {
  const url = `courses/${courseID}/assignments`
  const options = { params: { include } }
  return exhaust(paginate(url, options))
}

export function getAssignment (courseID: string, assignmentID: string): ApiPromise<Assignment> {
  const url = `courses/${courseID}/assignments/${assignmentID}`
  const options = {
    params: {
      include: ['overrides', 'observed_users'],
      all_dates: 'true',
    },
  }

  return httpClient.get(url, options)
}

export function updateAssignment (courseID: string, assignment: Assignment): ApiPromise<Assignment> {
  // For whatever reason, overrides has a different name when you try to update it
  const updatedAssignment = cloneDeep(assignment)
  if (updatedAssignment.overrides) {
    updatedAssignment.assignment_overrides = updatedAssignment.overrides
    delete updatedAssignment.overrides
  }

  const url = `courses/${courseID}/assignments/${assignment.id}`
  return httpClient.put(url, {
    assignment: updatedAssignment,
  })
}

export function getAssignmentGradeableStudents (courseID: string, assignmentID: string): ApiPromise<UserDisplay[]> {
  const url = `courses/${courseID}/assignments/${assignmentID}/gradeable_students`

  let options = {
    params: {
      per_page: 100,
    },
  }
  const students = paginate(url, options)
  return exhaust(students)
}
