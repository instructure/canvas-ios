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

// @flow

export type Quiz = {
  id: string,
  assignment_id?: ?string,
  title: string,
  html_url: string,
  mobile_url: string,
  description: string,
  due_at: ?string,
  lock_at: ?string,
  points_possible: ?number,
  question_count: number,
  published: boolean,
  quiz_type: 'practice_quiz' | 'assignment' | 'graded_survey' | 'survey',
  allowed_attempts: number,
  hide_results: null | 'always' | 'until_after_last_attempt',
  time_limit: ?number,
  shuffle_answers: boolean,
  show_correct_answers: boolean,
  show_correct_answers_last_attempt: boolean,
  show_correct_answers_at: ?string,
  hide_correct_answers_at: ?string,
  one_question_at_a_time: boolean,
  scoring_policy: 'keep_average' | 'keep_latest' | 'keep_highest',
  cant_go_back: boolean,
  access_code: ?string,
  assignment_group_id: ?string,
  all_dates?: AssignmentDate[],
  can_unpublish: boolean,
}

export type QuizSubmission = {
  id: string,
  quiz_id: string,
  user_id: string,
  submission_id: string,
  started_at?: ?string,
  finished_at?: ?string,
  end_at?: ?string,
  attempt: number,
  extra_attempts: number,
  extra_time: number, // minutes
  manually_unlocked: boolean,
  time_spent?: ?number, // seconds
  score?: ?number, // The score of the quiz submission, if graded.
  score_before_regrade: number,
  kept_score: number,
  fudge_points: number,
  has_seen_results: boolean,
  workflow_state: 'untaken' | 'pending_review' | 'complete' | 'settings_only' | 'preview',
  overdue_and_needs_submission: boolean,
}
