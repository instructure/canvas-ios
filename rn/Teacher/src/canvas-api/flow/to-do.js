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

export type ToDoItem = {
  type: 'grading' | 'submitting',
  assignment?: Assignment,
  quiz?: Quiz,
  ignore: string,
  ignore_permanently: string,
  html_url: string,
  needs_grading_count?: number,
  context_type: 'course' | 'group',
  course_id: ?string,
  group_id: ?string,
}
