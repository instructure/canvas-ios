/* @flow */

import httpClient from './httpClient'
import { cloneDeep } from 'lodash'
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
