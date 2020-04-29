//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// @flow

import { paginate, exhaust } from '../utils/pagination'
import httpClient from '../httpClient'

export function getQuizzes (courseID: string): ApiPromise<Quiz[]> {
  const url = `courses/${courseID}/quizzes`
  const options = {
    params: {
      per_page: 100,
    },
  }
  let quizzes = paginate(url, options)
  return exhaust(quizzes)
}

export function getQuiz (courseID: string, quizID: string): ApiPromise<Quiz> {
  const url = `courses/${courseID}/quizzes/${quizID}`
  return httpClient.get(url)
}

export function getQuizSubmissions (courseID: string, quizID: string): ApiPromise<QuizSubmission[]> {
  const url = `courses/${courseID}/quizzes/${quizID}/submissions`
  let options = {
    params: {
      include: [ 'submission' ],
      per_page: 100,
    },
  }
  const submissions = paginate(url, options)
  return exhaust(submissions, ['quiz_submissions', 'submissions'])
}

export function updateQuiz (quiz: Quiz, courseID: string): ApiPromise<Quiz> {
  const params = {
    ...quiz,
    one_question_at_a_time: quiz.one_question_at_a_time || 0, // silly Canvas
  }
  const url = `courses/${courseID}/quizzes/${quiz.id}`
  return httpClient.put(url, { quiz: params })
}
