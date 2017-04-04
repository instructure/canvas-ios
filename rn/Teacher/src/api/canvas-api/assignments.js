/* @flow */

import httpClient from './httpClient'

export function updateAssignment (courseID: string, assignment: Assignment): Promise<ApiResponse<Assignment>> {
  const url = `courses/${courseID}/assignments/${assignment.id}`
  return httpClient().put(url, {
    assignment,
  })
}
