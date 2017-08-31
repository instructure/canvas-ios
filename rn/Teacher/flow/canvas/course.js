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
