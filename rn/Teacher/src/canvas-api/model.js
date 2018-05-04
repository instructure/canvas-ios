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

export class PageModel extends Model<Page> {
  static keyExtractor (page: PageModel) {
    return page.url
  }

  static newPage = Object.freeze(new PageModel({
    page_id: '',
    url: '',
    html_url: '',
    title: '',
    created_at: new Date().toJSON(),
    updated_at: new Date().toJSON(),
    hide_from_students: false,
    editing_roles: 'teachers',
    body: '',
    published: false,
    front_page: false,
  }))

  id = this.raw.page_id
  url = this.raw.url
  htmlUrl = this.raw.html_url
  title = this.raw.title
  createdAt = new Date(this.raw.created_at)
  updatedAt = new Date(this.raw.updated_at)
  isHiddenFromStudents = this.raw.hide_from_students
  editingRoles = this.raw.editing_roles.split(',').map(r => r.trim()).sort()
  body = this.raw.body
  published = this.raw.published
  isFrontPage = this.raw.front_page
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
