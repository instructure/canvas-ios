/* @flow */

import { paginate, exhaust } from '../utils/pagination'

export function getQuizzes (courseID: string): Promise<ApiResponse<Quiz[]>> {
  const url = `courses/${courseID}/quizzes`
  const options = {
    params: {
      per_page: 99,
    },
  }
  let quizzes = paginate(url, options)
  return exhaust(quizzes)
}
