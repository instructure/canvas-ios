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

export type CourseHome =
  | 'feed'
  | 'wiki'
  | 'modules'
  | 'assignments'
  | 'syllabus'

export type Term = {
  name: string,
}

export type Course = {
  id: string,
  account_id: string,
  name: string,
  course_code: string,
  short_name?: string,
  image_download_url?: ?string,
  is_favorite?: boolean,
  default_view: CourseHome,
  term: Term,
  enrollments?: ?CourseEnrollment[],
  sections?: Section[],
}

export type CustomColors = {
  custom_colors: {
    [string]: string,
  },
}

export type UpdateCustomColorResponse = {
  hexcode: string,
}

export type Favorite = {
  context_id: string,
  context_type: string,
}

export type CourseEnrollment = {
  enrollment_state: string,
  role: string,
  role_id: string,
  type: string,
  user_id: string,
}

export type CreateCourse = {
  course: {
    name: string,
    course_code: string,
    start_at?: string,
    end_at?: string,
    license?: string,
    is_public?: boolean,
    is_public_to_auth_users?: boolean,
    public_syllabus?: boolean,
    public_description?: string,
    allow_student_wiki_edits?: boolean,
    allow_wiki_comments?: boolean,
    allow_student_forum_attachments?: boolean,
    open_enrollment?: boolean,
    self_enrollment?: boolean,
    restrict_enrollments_to_course_dates?: boolean,
    term_id?: number,
    sis_course_id?: string,
    integration_id?: string,
    hide_final_grades?: boolean,
    apply_assignment_group_weights?: boolean,
    time_zone?: string,
    syllabus_body?: string,
    grading_standard_id?: number,
    course_format?: string,
  },
  offer?: boolean,
  enroll_me?: boolean,
  enable_sis_reactivation?: boolean,
}