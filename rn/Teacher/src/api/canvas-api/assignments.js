/* @flow */

import httpClient from './httpClient'

export function getAssignmentDetails (courseID: number, assignmentID: number): Promise<ApiResponse<Course[]>> {
  const url = `courses/${courseID}/assignments/${assignmentID}`
  return httpClient().get(url)
}
