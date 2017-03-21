// @flow

import type { CourseProps, CourseListDataProps } from '../course-prop-types'
import localeSort from '../../../utils/locale-sort'

export function mapStateToProps (state: CoursesAppState): CourseListDataProps {
  const allCourses: CoursesState = state.entities.courses
  const { pending, error, courseRefs } = state.favoriteCourses
  const courses: Array<CourseProps> = courseRefs
    .map(ref => allCourses[ref])
    .map(({ course, color }) => ({ ...course, color }))
    .sort((c1, cs2) => localeSort(c1.name, cs2.name))

  return { pending, error, courses }
}
