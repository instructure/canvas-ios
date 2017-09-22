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
export type EnrollmentType =
  'StudentEnrollment' |
  // I believe `StudentViewEnrollment` is a legacy thing which
  // teachers could use to view their course as a student.
  'StudentViewEnrollment' |
  'TeacherEnrollment' |
  'TaEnrollment' |
  'DesignerEnrollment' |
  'ObserverEnrollment'

export type EnrollmentState = 'active' | 'invited' | 'inactive'

export type Enrollment = {
  id: string,
  user_id: string,
  user: User,
  type: EnrollmentType,
  enrollment_state: EnrollmentState,
  course_id: string,
  last_activity_at: string,
  course_section_id: string,
  computed_current_grade: string,
}

export type CreateEnrollment = {
  user_id: string,
  type: 'StudentEnrollment' | 'TeacherEnrollment' | 'TAEnrollment' | 'ObserverEnrollment' | 'DesignerEnrollment',
  enrollment_state?: 'active' | 'invited' | 'inactive',
  course_section_id?: string,
  limit_privileges_to_course_section?: boolean,
  notify?: boolean,
  self_enrollment_code?: string,
  self_enrolled?: boolean,
  associated_user_id?: string
}