/* @flow */

import template, { type Template } from '../../../utils/template'

export const quiz: Template<Quiz> = template({
  id: '1',
  title: 'Quiz 1',
  html_url: 'http://mobiledev.instructure.com/courses/1/quizzes',
  description: 'This is quiz 1',
  published: true,
  due_at: '2013-01-23T23:59:00-07:00',
  lock_at: null,
  question_count: 12,
  points_possible: 20,
  quiz_type: 'assignment',
  allowed_attempts: -1,
  hide_results: null,
  time_limit: null,
  shuffle_answers: false,
  show_correct_answers: false,
  show_correct_answers_last_attempt: false,
  show_correct_answers_at: null,
  hide_correct_answers_at: null,
  one_question_at_a_time: false,
  scoring_policy: 'keep_latest',
  cant_go_back: false,
  access_code: null,
  assignment_group_id: null,
})
