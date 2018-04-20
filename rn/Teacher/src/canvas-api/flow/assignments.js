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
  ratings: RubricRating[],
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

export type GradingType = 'pass_fail' | 'percent' | 'letter_grade' | 'gpa_scale' | 'points' | 'not_graded'

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
  submission_types: SubmissionType[],
  html_url: string,
  position: number,
  grading_type: GradingType,
  rubric: ?Rubric[],
  rubric_settings: ?RubricSettings,
  rubric_assessment: {
    [string]: RubricAssessment,
  },
  group_category_id: ?string,
  grade_group_students_individually: boolean,
  quiz_id?: string,
  discussion_topic?: Discussion,
  external_tool_tag_attributes?: { url: ?string },
  submission?: Submission,
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
