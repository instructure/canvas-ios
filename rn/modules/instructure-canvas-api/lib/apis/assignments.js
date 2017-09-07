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

/* @flow */

import httpClient from '../httpClient'
import cloneDeep from 'lodash/cloneDeep'
import { paginate, exhaust } from '../utils/pagination'

export function getAssignment (courseID: string, assignmentID: string): Promise<ApiResponse<Assignment>> {
  const url = `courses/${courseID}/assignments/${assignmentID}`
  const options = {
    params: {
      include: ['overrides'],
      all_dates: true,
    },
  }

  return httpClient().get(url, options)
}

export function updateAssignment (courseID: string, assignment: Assignment): Promise<ApiResponse<Assignment>> {
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

export function getAssignmentGradeableStudents (courseID: string, assignmentID: string): Promise<ApiResponse<UserDisplay>> {
  const url = `courses/${courseID}/assignments/${assignmentID}/gradeable_students`

  let options = {
    params: {
      per_page: 99,
    },
  }
  const students = paginate(url, options)
  return exhaust(students)
}
