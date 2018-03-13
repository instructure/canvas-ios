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
  title = this.raw.title
  createdAt = new Date(this.raw.created_at)
  updatedAt = new Date(this.raw.updated_at)
  isHiddenFromStudents = this.raw.hide_from_students
  editingRoles = this.raw.editing_roles.split(',').map(r => r.trim()).sort()
  body = this.raw.body
  published = this.raw.published
  isFrontPage = this.raw.front_page
}
