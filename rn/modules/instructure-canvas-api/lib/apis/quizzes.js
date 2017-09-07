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

import { paginate, exhaust } from '../utils/pagination'
import httpClient from '../httpClient'

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

export function getQuizSubmissions (courseID: string, quizID: string): Promise<ApiResponse<QuizSubmission>> {
  const url = `courses/${courseID}/quizzes/${quizID}/submissions`
  let options = {
    params: {
      include: 'submission',
      per_page: 99,
    },
  }
  const submissions = paginate(url, options)
  return exhaust(submissions, ['quiz_submissions', 'submissions'])
}

export function updateQuiz (quiz: Quiz, courseID: string): Promise<ApiResponse<Quiz>> {
  const params = {
    ...quiz,
    one_question_at_a_time: quiz.one_question_at_a_time || 0, // silly Canvas
  }
  const url = `courses/${courseID}/quizzes/${quiz.id}`
  return httpClient().put(url, { quiz: params })
}
