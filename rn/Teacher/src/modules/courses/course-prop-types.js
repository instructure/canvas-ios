// @flow

import CourseActions from './actions'

type ColorProps = {
  +color: string,
}

export type CourseProps = Course & ColorProps

export type CourseListDataProps = AsyncState & {
  +courses: Array<CourseProps>,
}

export type CourseListProps = CourseListDataProps & typeof CourseActions
