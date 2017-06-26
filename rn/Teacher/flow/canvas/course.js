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
  name: string,
  course_code: string,
  short_name?: string,
  image_download_url?: ?string,
  is_favorite?: boolean,
  default_view: CourseHome,
  term: Term,
  enrollments?: ?CourseEnrollment[],
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
