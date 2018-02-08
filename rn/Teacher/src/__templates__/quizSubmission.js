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
import { user } from './users'
import { quiz } from './quiz'

export const quizSubmission: Template<QuizSubmission> = template({
  id: '32',
  quiz_id: quiz().id,
  user_id: user().id,
  finished_at: '2017-04-05T15:12:45Z',
  kept_score: 5,
  workflow_state: 'complete',
  submission_id: '1',
  attempt: 1,
  extra_attempts: 0,
  extra_time: 0,
  manually_unlocked: false,
  score_before_regrade: 0,
  fudge_points: 0,
  has_seen_results: false,
  overdue_and_needs_submission: false,
})
