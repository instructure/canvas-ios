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
}

export type QuizSubmission = {
  id: string,
  quiz_id: string,
  user_id: string,
  submission_id: string,
  started_at: ?string,
  finished_at: ?string,
  end_at: ?string,
  attempt: number,
  extra_attempts: number,
  extra_time: number, // minutes
  manually_unlocked: boolean,
  time_spent: ?number, // seconds
  score: ?number, // The score of the quiz submission, if graded.
  score_before_regrade: number,
  kept_score: number,
  fudge_points: number,
  has_seen_results: boolean,
  workflow_state: 'untaken' | 'pending_review' | 'complete' | 'settings_only' | 'preview',
  overdue_and_needs_submission: boolean,
}
