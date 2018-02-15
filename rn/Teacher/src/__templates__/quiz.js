//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

/* @flow */

import template, { type Template } from '../utils/template'

export const quiz: Template<Quiz> = template({
  id: '1',
  title: 'Quiz 1',
  html_url: 'http://mobiledev.instructure.com/courses/1/quizzes',
  mobile_url: 'canvas-courses://mobiledev.instructure.com/courses/1/quizzes',
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
  all_dates: [],
  can_unpublish: true,
})
