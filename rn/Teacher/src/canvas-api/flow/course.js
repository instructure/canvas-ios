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

export type CourseHome =
  | 'feed'
  | 'wiki'
  | 'modules'
  | 'assignments'
  | 'syllabus'

export type Course = {
  id: string,
  account_id: string,
  name: string,
  course_code: string,
  short_name?: string,
  image_download_url?: ?string,
  is_favorite?: boolean,
  default_view: CourseHome,
  enrollments?: ?Enrollment[],
  sections?: Section[],
  access_restricted_by_date?: boolean,
  end_at?: ?string,
  workflow_state: CourseWorkflowState,
  term: ?CourseTerm,
  permissions?: ?CoursePermissions,
}

export type CourseTerm = {
  id: string,
  created_at: string,
  end_at?: ?string,
  start_at?: ?string,
  name: string,
}

export type CourseWorkflowState = 'unpublished' | 'available' | 'completed' | 'deleted'

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

export type CoursePermissions = {
  create_announcement?: boolean,
  create_discussion_topic?: boolean,
}
