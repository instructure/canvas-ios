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
})
