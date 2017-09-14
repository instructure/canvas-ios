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

// @flow

export type RubricRating = {
  points: number,
  id: string,
  description: string,
}

export type Rubric = {
  points: number,
  id: string,
  outcome_id?: string,
  vendor_guid?: string,
  description: string,
  long_description: string,
  ratings: Array<RubricRating>,
}

export type RubricSettings = {
  id: string,
  points_possible: number,
  title: string,
  free_form_criterion_comments: boolean,
}

export type RubricAssessment = {
  points?: number,
  comments: string,
}

export type AssignmentGroup = {
  id: string,
  name: string,
  position: number,
  group_weight: number,
  sis_source_id: string,
  integration_data: any,
  assignments: Assignment[],
  rules?: any,
}

export type GradingType = 'pass_fail' | 'percent' | 'letter_grade' | 'gpa_scale' | 'points'

export type Assignment = {
  id: string,
  name: string,
  description: ?string,
  created_at: string,
  updated_at: string,
  due_at: ?string,
  lock_at?: ?string,
  unlock_at?: ?string,
  all_dates?: AssignmentDate[],
  has_overrides: boolean,
  overrides?: AssignmentOverride[],
  course_id: string,
  published: true,
  unpublishable: false,
  only_visible_to_overrides: boolean,
  points_possible: number,
  needs_grading_count: number,
  submission_types: string[],
  html_url: string,
  position: number,
  grading_type: GradingType,
  rubric: ?Array<Rubric>,
  rubric_settings: ?RubricSettings,
  rubric_assessment: {
    [string]: RubricAssessment,
  },
  group_category_id: ?string,
  grade_group_students_individually: boolean,
  quiz_id?: string,
  discussion_topic?: Disussion,
  external_tool_tag_attributes?: { url: ?string },
}

export type AssignmentDate = {
  // (Optional, missing if 'base' is present) id of the assignment override this date
  id?: string,
  // (Optional, present if 'id' is missing) whether this date represents the
  base?: boolean,
  title: string,
  due_at: string,
  unlock_at: string,
  lock_at: string,
}

export type AssignmentOverride = {
  id: string,
  assignment_id: string,
  student_ids: string[],
  group_id: string,
  course_section_id: string,
  title: string,
  due_at: string,
  all_day: boolean,
  all_date_date: string,
  unlock_at: string,
  lock_at: string,
}
