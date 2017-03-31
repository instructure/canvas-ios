// @flow

type ColorProps = {
  +color: string,
}

export type CourseProps = Course & ColorProps

export type CourseListDataProps = AsyncState & {
  +courses: Array<CourseProps>,
}

export type CourseListActionProps = {
  +refreshCourses: () => Promise<Course[]>,
  +updateCourseColor: () => Promise<*>,
  +refreshGradingPeriods: () => Promise<*>,
}

export type CourseListProps = CourseListDataProps & CourseListActionProps
