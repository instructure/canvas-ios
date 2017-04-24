/* @flow */

import httpClient from './httpClient'
import { cloneDeep } from 'lodash'

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
