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

import formatter from '../formatter'

const template = {
  ...require('../../../__templates__/quiz'),
}

let quiz: Quiz
beforeEach(() => {
  quiz = template.quiz()
})

test('quizType', () => {
  quiz.quiz_type = 'practice_quiz'
  testFormatter(quiz, 'quizType', 'Practice Quiz')

  quiz.quiz_type = 'assignment'
  testFormatter(quiz, 'quizType', 'Graded Quiz')

  quiz.quiz_type = 'graded_survey'
  testFormatter(quiz, 'quizType', 'Graded Survey')

  quiz.quiz_type = 'survey'
  testFormatter(quiz, 'quizType', 'Ungraded Survey')
})

test('shuffleAnswers', () => {
  quiz.shuffle_answers = false
  testFormatter(quiz, 'shuffleAnswers', 'No')

  quiz.shuffle_answers = true
  testFormatter(quiz, 'shuffleAnswers', 'Yes')
})

test('timeLimit', () => {
  quiz.time_limit = null
  testFormatter(quiz, 'timeLimit', 'No Time Limit')

  quiz.time_limit = 1
  testFormatter(quiz, 'timeLimit', '1 Minute')

  quiz.time_limit = 2
  testFormatter(quiz, 'timeLimit', '2 Minutes')
})

test('allowedAttempts', () => {
  quiz.allowed_attempts = -1
  testFormatter(quiz, 'allowedAttempts', 'Unlimited')

  quiz.allowed_attempts = 0
  testFormatter(quiz, 'allowedAttempts', 0)

  quiz.allowed_attempts = 100
  testFormatter(quiz, 'allowedAttempts', 100)
})

test('viewResponses', () => {
  quiz.hide_results = null
  testFormatter(quiz, 'viewResponses', 'Always')

  quiz.hide_results = 'always'
  testFormatter(quiz, 'viewResponses', 'No')

  quiz.hide_results = 'until_after_last_attempt'
  testFormatter(quiz, 'viewResponses', 'After Last Attempt')
})

describe('showCorrectAnswers', () => {
  beforeEach(() => {
    quiz.hide_results = null
    quiz.show_correct_answers = false
    quiz.show_correct_answers_at = null
    quiz.hide_correct_answers_at = null
    quiz.show_correct_answers_last_attempt = false
  })

  it('only applies if hide_results is null', () => {
    quiz.hide_results = null
    quiz.show_correct_answers = true
    testFormatter(quiz, 'showCorrectAnswers', 'Always')

    quiz.show_correct_answers = false
    testFormatter(quiz, 'showCorrectAnswers', 'No')

    quiz.hide_results = 'always'
    quiz.show_correct_answers = true
    testFormatter(quiz, 'showCorrectAnswers', null)

    quiz.show_correct_answers = false
    testFormatter(quiz, 'showCorrectAnswers', null)
  })

  it('uses show date', () => {
    quiz.show_correct_answers = true
    quiz.show_correct_answers_at = '2013-01-23T23:59:00-07:00'
    testFormatter(quiz, 'showCorrectAnswers', 'After Jan 23, 2013 at 11:59 PM')
  })

  it('uses hide date', () => {
    quiz.show_correct_answers = true
    quiz.hide_correct_answers_at = '2013-01-23T23:59:00-07:00'
    testFormatter(quiz, 'showCorrectAnswers', 'Until Jan 23, 2013 at 11:59 PM')
  })

  it('uses show and hide dates', () => {
    quiz.show_correct_answers = true
    quiz.show_correct_answers_at = '2013-01-23T23:59:00-07:00'
    quiz.hide_correct_answers_at = '2013-01-24T23:59:00-07:00'
    testFormatter(quiz, 'showCorrectAnswers', 'Jan 23, 2013 at 11:59 PM to Jan 24, 2013 at 11:59 PM')
  })

  it('uses last attempt if allowed_attempts is more than 0', () => {
    quiz.show_correct_answers = true
    quiz.allowed_attempts = -1
    quiz.show_correct_answers_last_attempt = true
    testFormatter(quiz, 'showCorrectAnswers', 'Always')

    quiz.allowed_attempts = 5
    testFormatter(quiz, 'showCorrectAnswers', 'After Last Attempt')

    quiz.allowed_attempts = 0
    testFormatter(quiz, 'showCorrectAnswers', 'Always')
  })
})

test('oneQuestionAtATime', () => {
  quiz.one_question_at_a_time = true
  testFormatter(quiz, 'oneQuestionAtATime', 'Yes')

  quiz.one_question_at_a_time = false
  testFormatter(quiz, 'oneQuestionAtATime', 'No')
})

test('scoringPolicy', () => {
  quiz.scoring_policy = 'keep_average'
  testFormatter(quiz, 'scoringPolicy', 'Average')

  quiz.scoring_policy = 'keep_latest'
  testFormatter(quiz, 'scoringPolicy', 'Latest')

  quiz.scoring_policy = 'keep_highest'
  testFormatter(quiz, 'scoringPolicy', 'Highest')
})

test('cantGoBack', () => {
  quiz.cant_go_back = false
  testFormatter(quiz, 'cantGoBack', 'No')

  quiz.cant_go_back = true
  testFormatter(quiz, 'cantGoBack', 'Yes')
})

function testFormatter (quiz: Quiz, property: string, value: ?string | ?number) {
  expect(formatter(quiz)[property]).toEqual(value)
}
