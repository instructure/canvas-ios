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

export function updateQuiz (quiz: Quiz, courseID: string): Promise<ApiResponse<Quiz>> {
  const params = {
    ...quiz,
    one_question_at_a_time: quiz.one_question_at_a_time || 0, // silly Canvas
  }
  const url = `courses/${courseID}/quizzes/${quiz.id}`
  return httpClient().put(url, { quiz: params })
}
