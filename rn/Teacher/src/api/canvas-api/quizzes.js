/* @flow */

import { paginate, exhaust } from '../utils/pagination'
import httpClient from './httpClient'

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

export function getQuiz (courseID: string, quizID: string): Promise<ApiResponse<Quiz>> {
  const url = `courses/${courseID}/quizzes/${quizID}`
  return httpClient().get(url)
}
