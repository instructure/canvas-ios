//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// @flow
export class Model<Data> {
  raw: Data

  constructor (raw: Data) {
    this.raw = raw
  }
}

export class CourseModel extends Model<Course> {
  static keyExtractor (course: CourseModel) {
    return course.id
  }

  id = this.raw.id
  accountID = this.raw.account_id
  name = this.raw.name
  courseCode = this.raw.course_code
  shortName = this.raw.short_name
  imageDownloadUrl = this.raw.image_download_url
  isFavorite = this.raw.is_favorite
  defaultView = this.raw.default_view
  enrollments = this.raw.enrollments
  sections = this.raw.sections
  accessRestrictedByDate = this.raw.access_restricted_by_date
  endAt = this.raw.end_at && new Date(this.raw.end_at)
  workflowState = this.raw.workflow_state
  term = this.raw.term
  permissions = this.raw.permissions
}

export class ToDoModel extends Model<ToDoItem> {
  static keyExtractor (todo: ToDoModel) {
    return todo.htmlUrl
  }

  type = this.raw.type
  assignment = this.raw.assignment
  quiz = this.raw.quiz
  ignoreUrl = this.raw.ignore
  ignorePermanentlyUrl = this.raw.ignore_permanently
  htmlUrl = this.raw.html_url
  needsGradingCount = this.raw.needs_grading_count
  contextType = this.raw.context_type
  courseID = this.raw.course_id
  groupID = this.raw.group_id
}
