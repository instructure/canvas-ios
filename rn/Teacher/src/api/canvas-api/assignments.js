/* @flow */

import httpClient from './httpClient'

export function refreshAssignmentDetails (courseID: string, assignmentID: string): Promise<ApiResponse<Course[]>> {
  const url = `courses/${courseID}/assignments/${assignmentID}`
  return httpClient().get(url)
}
