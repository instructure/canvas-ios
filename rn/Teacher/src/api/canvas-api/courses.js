/* @flow */

import httpClient from './httpClient'
import type { ApiResponse } from './apiResponse'

export function getCourses (): Promise<ApiResponse<Array<Course>>> {
  return httpClient().get('courses')
}
